
import 'package:flutter/widgets.dart';
import 'package:my_project/services/auth/auth_user.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class AuthState{
  final bool isLoading;
  final String? loadingText;
  const AuthState({
    required this.isLoading, 
    this.loadingText = 'please wait a moment',
  });
}

class AuthStateUnintialized extends AuthState{
  const AuthStateUnintialized({required bool isLoading}) : super(isLoading:isLoading);
}

class AuthStateRegistering extends AuthState{
  final Exception? exception;
  const AuthStateRegistering({required this.exception, required bool isLoading}) : super(isLoading: isLoading);
}

class AuthStateLoggedIn extends AuthState{
  final AuthUser user;
  const AuthStateLoggedIn({required this.user, required bool isLoading}) : super(isLoading: isLoading);
}

class AuthStateNeedsVerification extends AuthState{
  const AuthStateNeedsVerification({required bool isLoading}) : super(isLoading: isLoading);
}

class AuthStateLoggedOut extends AuthState with EquatableMixin{
  final Exception? exception;
  const AuthStateLoggedOut({
    required this.exception,
    required bool isLoading,
    String? isloadingText
  }) :super(isLoading: isLoading, loadingText: isloadingText);
  
  @override
  List<Object?> get props => [exception,isLoading];
}

class AuthStateForgotPassword extends AuthState{
  final Exception? exception;
  final bool hasSentEmail;
  const AuthStateForgotPassword({
    required this.exception,
    required this.hasSentEmail,
    required bool isLoading}) : super(isLoading: isLoading);
}






