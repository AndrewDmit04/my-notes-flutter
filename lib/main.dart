import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_project/firebase_options.dart';
import 'package:my_project/views/register_view.dart';

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
    ));
}
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home page",
        style:TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder:(context,snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.done:
              final user = (FirebaseAuth.instance.currentUser);

              if (user?.emailVerified ?? false){
                print("you are verified");
              }
              else{
                print("you need to verify");
              }
              return const Text("Done");
            default:
              return const Text("loading");
          }
        } 
        ,)

    );
  }
}




