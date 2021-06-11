part of 'login_bloc.dart';


abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginButtonPressed extends LoginEvent {}

class LoginDeepLinkListen extends LoginEvent {
  final String code;

  LoginDeepLinkListen(this.code);

  @override
  List<Object> get props => [this.code];
}

class LoginDeepLinkInitial extends LoginEvent {}
class LoginDeepLinkFinished extends LoginEvent {}
class LoginDeepLinkBrowserClose extends LoginEvent {}

class LoginEventLoading extends LoginEvent {}
