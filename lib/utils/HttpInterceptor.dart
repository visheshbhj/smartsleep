import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:smartsleep/auth/user_repository.dart';
import 'package:smartsleep/model/Token.dart';

class HttpClient extends BaseClient{

  Client client;
  UserRepository userRepository;

  HttpClient(this.client,this.userRepository,this._clientID,this._clientSecret);

  static String baseURI = 'https://api.fitbit.com';
  String _clientID;
  String _clientSecret;

  Future<Response> authRequest(Request request){
   bool refreshed = false;
   Future<Response> futureResponseAfterRefresh;

    Future<Response> futureResponse = send(request).then((responseStream) => Response.fromStream(responseStream));

    futureResponse.then((response){

      if(response.statusCode==HttpStatus.unauthorized){// If Not Authorized

        send(refreshTokenRequest()).then((refreshResponseStream) => Response.fromStream(refreshResponseStream)).then((refreshResponse){

          if(refreshResponse.statusCode==200){
            String body = refreshResponse.body;
            userRepository.token.setter(Token.fromJson(jsonDecode(body)));
            userRepository.persistToken(body);
          }else{
            userRepository.deleteToken();
          }
        });

        Request newRequest = new Request(request.method, request.url);
        futureResponseAfterRefresh = send(newRequest).then((responseStream) => Response.fromStream(responseStream));  //https://stackoverflow.com/questions/51096991/dart-http-bad-state-cant-finalize-a-finalized-request-when-retrying-a-http
      }else{  //If Authorized
        print('********************** START **********************');
        print('URI '+response.request.url.toString());
        print('REQUEST HEADERS '+response.request.headers.toString());
        print('RESPONSE HEADERS '+response.headers.toString());
        print('STATUS CODE '+response.statusCode.toString());
        print('************ RESPONSE BODY ************');
        print(response.body);
        print('********************** END **********************');
      }
    });

    if(refreshed){
      return futureResponseAfterRefresh;
    }else{
      return futureResponse;
    }
  }

  Future<Response> noRefreshRequest(Request request){
    return send(request).then((responseStream) => Response.fromStream(responseStream));
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    if(request.url.path=='/oauth2/token' || request.url.path=='/oauth2/revoke'){
      request.headers[HttpHeaders.contentTypeHeader] = 'application/x-www-form-urlencoded';
      request.headers[HttpHeaders.authorizationHeader] = 'Basic ' +base64.encode(utf8.encode(_clientID + ":"+_clientSecret));
    }else if(request.url.path=='/1.1/oauth2/introspect') {
      request.headers[HttpHeaders.contentTypeHeader] = 'application/x-www-form-urlencoded';
      request.headers[HttpHeaders.authorizationHeader] = 'Bearer ' +userRepository.token.accessToken;
    }else{
      request.headers[HttpHeaders.authorizationHeader] = 'Bearer ' +userRepository.token.accessToken;
    }
    return client.send(request);
  }

  Request accessTokenRequest(String code){
    Request request = new Request('POST', Uri.parse(baseURI+'/oauth2/token'));
    request.body='client_id='+_clientID+'&grant_type=authorization_code&redirect_uri=app://smartsleep&code='+code;
    return request;
  }

  Request refreshTokenRequest(){
    Request request = new Request('POST', Uri.parse(baseURI+'/oauth2/token'));
    request.body='grant_type=refresh_token&refresh_token='+userRepository.token.refreshToken;
    return request;
  }

  Request revokeTokenRequest(){
    Request request = new Request('POST', Uri.parse(baseURI+'/oauth2/revoke'));
    request.body='refresh_token='+userRepository.token.refreshToken;
    return request;
  }

}