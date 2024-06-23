import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_project/firebase_options.dart';
import 'package:my_project/views/login_view.dart';
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
        '/login/':(context) => const LoginView(),
        '/register/': (context) => const RegisterView(),
      },
    ));
}
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return  FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder:(context,snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.done:
              final user = (FirebaseAuth.instance.currentUser);
              if (user != null){
                if(user.emailVerified){
                  return const NotesView();
                }
                else{
                  return const VerifyEmailView();
                }
              }else{
                return const LoginView();
              }

              
            default:
              return const Text("loading");
          }
        } 
        ,);
  }
}
enum MenuAction{logout}

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main UI"),
        actions:[
          PopupMenuButton<MenuAction>(
            onSelected: (value) async{
              switch(value){
                
                case MenuAction.logout:
                  final shoudlLogout = await showLogOutDiallog(context);
                  devtools.log(shoudlLogout.toString());
                  if (shoudlLogout){
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil('/login/', (_) => false);
                  }
                  break;
                  
              }
            },
            itemBuilder: (context){ 
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('log out'),
                ),
              ];
            },
            
            )
        ]

        ),
      body: const Text("hello world!")

    );
  }
}

Future<bool> showLogOutDiallog(BuildContext context){
  return showDialog<bool>(
    context: context, 
    builder: (context){
      return AlertDialog(
        title: const Text("Sign out"),
        content: const Text("are you sure you want to sign out"),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.of(context).pop(false);
            }, 
            child: const Text("Cancel")),
            TextButton(
            onPressed: (){
              Navigator.of(context).pop(true);
            }, 
            child: const Text("Log Out"))
        ],
      );
    }
  ).then((value) => value ?? false );
}




