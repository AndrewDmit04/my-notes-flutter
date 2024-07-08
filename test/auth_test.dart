import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/services/auth/auth_exceptions.dart';
import 'package:my_project/services/auth/auth_provider.dart';
import 'package:my_project/services/auth/auth_user.dart';



void main(){
  group('Mock Authentection', (){
    final provider = MockAuthProvider();
    test('Should not be intilized to begin with',(){
      expect(provider.isInitialized, false);
    });

    // test('Cannot log out if not itilized',(){
    //   expect(provider.logout(),
    //   throwsA(const TypeMatcher<NotInitilizedException>()),
    //   );
    // });

    test("should be able to be intilized",()async{
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test("user should be null after Initizlition",(){
      expect(provider.currentUser, null);
    });

    test('Should be able to intilize in time',() async{
      await provider.initialize();
      expect(provider.isInitialized, true);
    },timeout: const Timeout(Duration(seconds: 2)));

    test('Create user should delefate to logIn function',() async{
      final badEmailUser = provider.createUser(email: 'foo@bar.com', password: 'anypassword');
      expect(badEmailUser, throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final badPassword = provider.createUser(email: 'someone@bar.com', password: 'foobar');
      expect(badPassword,throwsA(TypeMatcher<WrongPasswordAuthException>()));

      final user = await provider.createUser(email: 'foo', password: 'bar');
      expect(provider.currentUser,user );
      expect(user.isEmailVerified, false);
    });

    test('logged in user should be able to be verrified',(){
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, false);

    });

    test("Should be able to log out and log in again",()async{
      await provider.logout();
      await provider.logIn(email: 'email', password: 'provider');

      final user = provider.currentUser; 
      expect(user,isNotNull);
    });



  });


}
class NotInitilizedException implements Exception{}

class MockAuthProvider implements AuthProvider{
  AuthUser? _user; 
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;
  
  @override
  Future<AuthUser> createUser({required String email, required String password}) async{
    if(!isInitialized) throw NotInitilizedException;
    await Future.delayed(const Duration(seconds:1));
    return logIn(
      email : email,
      password: password,
    );


  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async{
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true; 

  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if(!isInitialized) throw NotInitilizedException;
    if(email == 'foo@bar.com') throw UserNotFoundAuthException();
    if(password == 'foobar') throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false, email: 'foo@bar.com',id:'my_id'); 
    _user = user; 
    return Future.value(user);

  }

  @override
  Future<void> logout() async{
    if(!isInitialized) throw NotInitilizedException;
    if(_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null; 
  }

  @override
  Future<void> sendEmailVerification() async{
    if(!isInitialized) throw NotInitilizedException;
    await Future.delayed(const Duration(seconds: 1));
    _user = AuthUser(isEmailVerified: true, email: 'foo@bar.com',id:'my_id');


  }


}