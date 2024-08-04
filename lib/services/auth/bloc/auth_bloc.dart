import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/services/auth/bloc/auth_events.dart';
import 'package:my_project/services/auth/bloc/auth_state.dart';
import '../auth_provider.dart';


class AuthBloc extends Bloc<AuthEvent,AuthState>{
  AuthBloc(AuthProvider provider) : super(const AuthStateUnintialized(isLoading: true)){
    //send emailVerrifaction
    on<AuthEventSendEmailVeriefication>((event,emit) async{
      await provider.sendEmailVerification();
      emit(state);
    });
    on<AuthEventShouldRegister>((event,emit){
      emit(const AuthStateRegistering(isLoading: false, exception: null));
    });
    //register
    on<AuthEventRegister>((event,emit)async{
        final email = event.email;
        final password = event.passowrd;

        try{
          await provider.createUser(email: email, password: password);
          await provider.sendEmailVerification(); 
          emit(const AuthStateNeedsVerification(isLoading: false));
        }
        on Exception catch(e){
          emit(AuthStateRegistering(exception: e, isLoading: false));
        }
    });
    
    //intilize
    on<AuthEventInitialize>((event,emit) async{
      await provider.initialize();
      final user = provider.currentUser;
      if(user == null){
        emit(const AuthStateLoggedOut(
          exception: null, 
          isLoading: false, 
          isloadingText: 'please wait while I log you in'));
      }
      else if (!user.isEmailVerified){
        emit(const AuthStateNeedsVerification(isLoading: false));
      }
      else{
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    });
    //login
    on<AuthEventLogIn>((event,emit)async{
      emit(const AuthStateLoggedOut(exception: null, isLoading: true));
  
      try{
        final user = await provider.logIn(email: event.email, password: event.password);
        
        if(!user.isEmailVerified){
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
          emit(const AuthStateNeedsVerification(isLoading: false));
        }
        else{
          emit(const AuthStateLoggedOut(exception: null, isLoading: false,));
          emit(AuthStateLoggedIn(user: user, isLoading: false));
        }
      }
      on Exception catch(e){
        emit(AuthStateLoggedOut(exception: e, isLoading: false,));
        
      }

    });
    on<AuthEventLogOut>((event,emit)async{
      try{
        await provider.logout();
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      }
      on Exception catch(e){
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });
  }

}