import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/constants/routes.dart';
import 'package:my_project/helpers/loading/loading_screen.dart';
import 'package:my_project/services/auth/bloc/auth_bloc.dart';
import 'package:my_project/services/auth/bloc/auth_events.dart';
import 'package:my_project/services/auth/bloc/auth_state.dart';
import 'package:my_project/services/auth/firebase_auth_provider.dart';
import 'package:my_project/views/forgot_password_view.dart';
import 'package:my_project/views/login_view.dart';
import 'package:my_project/views/notes/create_update_note_view.dart';
import 'package:my_project/views/notes/notes_view.dart';
import 'package:my_project/views/register_view.dart';
import 'package:my_project/views/verify_email_view.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade100),
        useMaterial3: true,
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FireBaseAuthProvider()),
        child: const HomePage(), 
      ),
      routes: {
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(), 
      },
    ));
}
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context,state){
        if(state.isLoading){
          LoadingScreen().show(
            context: context,
             text: state.loadingText ?? 'Please wait a moment');
        }
        else{
          LoadingScreen().hide();
        }
      },
      builder: (context,state){
      if(state is AuthStateLoggedIn){
        return const NotesView();
      }
      else if(state is AuthStateNeedsVerification){
        return const VerifyEmailView();
      }
      else if(state is AuthStateLoggedOut){
        return const LoginView();
      }
      else if(state is AuthStateForgotPassword){
        return const ForgotPasswordView();
      }
      else if(state is AuthStateRegistering){
        return const RegisterView();
      }
      else{
        return const Scaffold(
          body: CircularProgressIndicator()
        );
      }

    });
  }
}







