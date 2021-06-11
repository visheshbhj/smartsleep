import 'dart:async';

import 'package:flutter/services.dart';
import 'package:smartsleep/model/Token.dart';

class UserRepository {

  static const platform = const MethodChannel('app://smartsleep/channel');
  //static const tokenChannel = const EventChannel('app://smartsleep/token');
  static const codeChannel = const EventChannel('app://smartsleep/code');

  Token token;
  String deepLinkURI;

  UserRepository(Token token,String tokenStore,String uri){
    this.token = token;
    this.deepLinkURI = uri;
    platform.invokeMethod("initializeSharedPreferences",tokenStore);
  }

  Future<void> deepLink() async {
    await platform.invokeMethod("initiateDeepLink",this.deepLinkURI);
  }

  Future<void> authenticate() async {
    await Future.delayed(Duration(seconds: 1));
    return 'token';
  }

  Future<void> deleteToken() async {
    platform.invokeMethod('removeToken');
  }

  Future<void> persistToken(String token) async {
    return await platform.invokeMethod('storeToken',token);
  }

  Future<String> getToken() async {
    return await platform.invokeMethod('getToken');
  }

  Future<String> getCode() async {
    return await platform.invokeMethod('getCode');
  }

}
