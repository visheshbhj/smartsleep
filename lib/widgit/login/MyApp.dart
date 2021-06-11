import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartsleep/auth/authentication_bloc.dart';
import 'package:smartsleep/auth/authentication_state.dart';
import 'package:smartsleep/auth/user_repository.dart';
import 'package:smartsleep/model/StringModel.dart';
import 'package:smartsleep/utils/HttpInterceptor.dart';
import 'package:smartsleep/widgit/alarm_list/AlarmListWidgit.dart';
import 'package:smartsleep/widgit/loading.dart';

import 'LoginState.dart';

class MyApp extends StatelessWidget {

  final UserRepository userRepository;
  final HttpClient httpClient;
  final StringModel stringModel;

  MyApp({this.userRepository,this.httpClient, this.stringModel});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state is AuthenticationAuthenticated) {
              return AlarmListWidget(httpClient: httpClient,stringModel: stringModel,);
            }
            if (state is AuthenticationUnauthenticated) {
              return LoginBlocState(userRepository: userRepository);
            }
            if (state is AuthenticationLoading) {
              return LoadingIndicator();
            }
            return LoginBlocState(userRepository: userRepository);
        },
      ),
    );
  }
}