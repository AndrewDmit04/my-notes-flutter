import 'package:my_project/services/auth/auth_provider.dart';
import 'package:my_project/services/auth/auth_user.dart';
import 'package:my_project/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider{
  final AuthProvider provider;
  const AuthService(this.provider);
  
  factory AuthService.firebase() => AuthService(FireBaseAuthProvider());


  @override
  Future<AuthUser> createUser({required String email, required String password,}) =>
    provider.createUser(email: email, password: password);


  
  @override
  AuthUser? get currentUser => provider.currentUser;
  
  @override
  Future<AuthUser> logIn({required String email, required String password,}) => provider.logIn(email: email, password: password);
  
  @override
  Future<void> logout() => provider.logout();
  
  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();
  
  @override
  Future<void> initialize() => provider.initialize();
  
  @override
  Future<void> sendPasswordReset({required String email}) => provider.sendPasswordReset(email: email);
  

}