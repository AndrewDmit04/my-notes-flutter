import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/services/auth/bloc/auth_events.dart';
import 'package:my_project/services/auth/bloc/auth_state.dart';
import '../auth_provider.dart';


class AuthBloc extends Bloc<AuthEvent,AuthState>{
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()){
    //intilize
    on<AuthEventInitialize>((event,emit) async{
      await provider.initialize();
      final user = provider.currentUser;
      if(user == null){
        emit(const AuthStateLoggedOut());
      }
      else if (!user.isEmailVerified){
        emit(const AuthStateNeedsVerification());
      }
      else{
        emit(AuthStateLoggedIn(user));
      }
    });
    //login
    on<AuthEventLogIn>((event,emit)async{
      emit(const AuthStateLoading());
      try{
        final user = await provider.logIn(email: event.email, password: event.password);
        emit(AuthStateLoggedIn(user));
      }
      on Exception catch(e){
        emit(AuthStateLoginFailure(e));
      }

    });
    on<AuthEventLogOut>((event,emit)async{
      try{
        emit(const AuthStateLoading());
        await provider.logout();
        emit(const AuthStateLoggedOut());
      }
      on Exception catch(e){
        emit(AuthStateLogoutFailure(e));
      }
    });
  }

}