import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:smartsleep/auth/authentication_event.dart';
import 'package:smartsleep/auth/authentication_state.dart';
import 'package:smartsleep/auth/user_repository.dart';
import 'package:smartsleep/model/Token.dart';
import 'package:smartsleep/utils/HttpInterceptor.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;
  final HttpClient httpClient;

  AuthenticationBloc({@required this.userRepository,this.httpClient})
      : super(AuthenticationUninitialized());

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    yield AuthenticationLoading();

    if (event is AppStarted) {
      final tokenStr = await userRepository.getToken();
      if (tokenStr.isNotEmpty) {
          userRepository.token.setter(Token.fromJson(jsonDecode(tokenStr)));

          Request introspect = new Request('POST', Uri.parse(HttpClient.baseURI + '/1.1/oauth2/introspect'));
          introspect.body = "token="+userRepository.token.accessToken;
          final response = await httpClient.noRefreshRequest(introspect);

          if(response.statusCode==HttpStatus.ok) { // Response is active : true or false
            // check active
            bool active = jsonDecode(response.body)['active'];

            if(active){
              yield AuthenticationAuthenticated();
            }else{
              this.add(TokenRefresh());
            }

          }else if(response.statusCode==HttpStatus.unauthorized) { // If Not Authorized, No need to check Response Refresh
            this.add(TokenRefresh());
          }

        } else {
          yield AuthenticationUnauthenticated();
        }
    }

    if(event is DeepLinkCode){
      final response = await httpClient.authRequest(httpClient.accessTokenRequest(event.code));
      userRepository.token.setter(Token.fromJson(jsonDecode(response.body)));
      userRepository.persistToken(response.body);
      yield AuthenticationAuthenticated();
    }

    if(event is TokenRefresh){
      final refreshResponse = await httpClient.send(httpClient.refreshTokenRequest()).then((refreshResponseStream) => Response.fromStream(refreshResponseStream));

      if(refreshResponse.statusCode==200){
        userRepository.token.setter(Token.fromJson(jsonDecode(refreshResponse.body)));
        userRepository.persistToken(refreshResponse.body);
        yield AuthenticationAuthenticated();
      }else{
        userRepository.deleteToken();
        yield AuthenticationUnauthenticated();
      }
    }

    if (event is LoggedOut) {
      httpClient.noRefreshRequest(httpClient.revokeTokenRequest());
      userRepository.deleteToken();
      yield AuthenticationUnauthenticated();
    }
  }

}
