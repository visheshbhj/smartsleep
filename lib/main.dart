library master;

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart';
import 'package:smartsleep/auth/user_repository.dart';
import 'package:smartsleep/model/StringModel.dart';
import 'package:smartsleep/model/Token.dart';
import 'package:smartsleep/utils/HttpInterceptor.dart';
import 'package:smartsleep/utils/bloc/BlocDelegate.dart';
import 'package:smartsleep/widgit/login/MyApp.dart';
import 'auth/authentication_bloc.dart';
import 'auth/authentication_event.dart';

void main() {
  final String deepURI = "";
  final String clientID = "";
  final String clientSecret = "";
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleBlocDelegate();
  final tokenStore = Token();
  final userRepository = UserRepository(tokenStore,"fit_alarm_token",deepURI);
  final httpClient = HttpClient(new Client(), userRepository,clientID,clientSecret);
  final stringModel = StringModel();
  Hive.initFlutter();
  //Hive.registerAdapter(NativeAlarmsTypeAdapter());

  runApp(
    BlocProvider<AuthenticationBloc>(
      create: (context) {
        return AuthenticationBloc(userRepository: userRepository,httpClient: httpClient)..add(AppStarted());
      },
      child: MyApp(userRepository: userRepository,httpClient: httpClient,stringModel: stringModel,),
    ),
  );
}
