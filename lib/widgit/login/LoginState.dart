import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartsleep/auth/authentication_bloc.dart';
import 'package:smartsleep/auth/user_repository.dart';
import 'package:smartsleep/widgit/login/bloc/login_bloc.dart';

import '../loading.dart';

class LoginBlocState extends StatelessWidget {

  final UserRepository userRepository;

  LoginBlocState({this.userRepository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: BlocProvider(
        create: (context) {
          return LoginBloc(
            authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
            userRepository: userRepository,
          );
        },
        child: LoginView(),
      ),
    );
  }

}

class LoginView extends StatefulWidget {

  @override
  _LoginViewState createState() => _LoginViewState();

}

class _LoginViewState extends State<LoginView> {

  @override
  Widget build(BuildContext context) {

    _onLoginButtonPressed() {
      BlocProvider.of<LoginBloc>(context).add(LoginButtonPressed(),);
    }

    return BlocListener <LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          Scaffold.of(context).showSnackBar(SnackBar(content: Text('${state.error}'),backgroundColor: Colors.red,),);
        }
    },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          if(state is LoginStateLoading){
            return LoadingIndicator();
          }else{
            return Center(child: RaisedButton(onPressed: _onLoginButtonPressed, child: Text('Login'),),);
          }
      },
    ),
    );
  }
}