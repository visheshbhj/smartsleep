import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:smartsleep/auth/authentication_bloc.dart';
import 'package:smartsleep/auth/authentication_event.dart';
import 'package:smartsleep/auth/user_repository.dart';

part 'login_state.dart';
part 'login_event.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  LoginBloc({
    @required this.userRepository,
    @required this.authenticationBloc,
  })  : assert(userRepository != null),
        assert(authenticationBloc != null),super(LoginInitial());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {

    if (event is LoginButtonPressed) {
      try {
        userRepository.deepLink();
        add(LoginDeepLinkInitial());
      } catch (error) {
        yield LoginFailure(error: error.toString());
      }
    }

    if(event is LoginDeepLinkInitial) {
      yield LoginStateLoading();
      
      UserRepository.codeChannel.receiveBroadcastStream().listen((code) =>
      code == 'BROWSER_RESUME'
          ? this.add(LoginDeepLinkBrowserClose())
          : authenticationBloc.add(DeepLinkCode(code: code)));
    }

    if(event is LoginDeepLinkBrowserClose){
      yield LoginInitial();
    }

  }

}
