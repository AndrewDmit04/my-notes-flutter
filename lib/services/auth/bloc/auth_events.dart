

import 'package:flutter/widgets.dart';

@immutable
abstract class AuthEvent{
  const AuthEvent(); 
}

class AuthEventInitialize extends AuthEvent{
  const AuthEventInitialize();
}
class AuthEventForgotPassword extends AuthEvent{
  final String? email; 
  const AuthEventForgotPassword({this.email});
}

class AuthEventLogIn extends AuthEvent{
  final String email;
  final String password;
  const AuthEventLogIn(this.email, this.password);
}

class AuthEventLogOut extends AuthEvent{
  const AuthEventLogOut();
}

class AuthEventSendEmailVeriefication extends AuthEvent{
  const AuthEventSendEmailVeriefication();
}

class AuthEventRegister extends AuthEvent{
  final String email;
  final String passowrd;
  const AuthEventRegister(this.email, this.passowrd);
}

class AuthEventShouldRegister extends AuthEvent{
  const AuthEventShouldRegister();
}