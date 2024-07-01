import 'package:flutter/material.dart';
import 'package:my_project/constants/routes.dart';
import 'package:my_project/services/auth/auth_service.dart';
import 'package:my_project/views/login_view.dart';
import 'package:my_project/views/notes_view.dart';
import 'package:my_project/views/register_view.dart';
import 'package:my_project/views/verify_email_view.dart';
import 'dart:developer' as devtools show log;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade100),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        loginRoute:(context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
      },
    ));
}
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return  FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder:(context,snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.done:
              final user = (AuthService.firebase().currentUser);
              if (user != null){
                if(user.isEmailVerified){
                  return const NotesView();
                }
                else{
                  return const VerifyEmailView();
                }
              }else{
                return const LoginView();
              }

              
            default:
              return const CircularProgressIndicator();
          }
        } 
        ,);
  }
}







