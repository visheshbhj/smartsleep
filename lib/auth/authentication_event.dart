import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthenticationEvent {}

class DeepLinkCode extends AuthenticationEvent {
  final String code;

  const DeepLinkCode({this.code});

  @override
  List<Object> get props => [code];

  @override
  String toString() => 'DeepLinkCode { code: $code }';

}

class LoggedIn extends AuthenticationEvent {
  final String token;

  const LoggedIn({@required this.token});

  @override
  List<Object> get props => [token];

  @override
  String toString() => 'LoggedIn { token: $token }';
}

class TokenRefresh extends AuthenticationEvent {}

class LoggedOut extends AuthenticationEvent {}
