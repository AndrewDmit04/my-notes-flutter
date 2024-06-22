import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_project/firebase_options.dart';



class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(title: const Text("login")),
       body: Column(
            children: [
              TextField(
                controller: _email,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Enter your email here',
                ),
              ),
              TextField(
                controller: _password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  hintText: 'Enter your password here',
                ),
              ),
              TextButton(
                onPressed: () async{
                  
                  final email = _email.text;
                  final password = _password.text; 
       
                    try{
                      final userCredintial = 
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email, 
                      password: password
                      );
                      print(userCredintial);
                    }
                    on FirebaseAuthException catch (e){
                      if (e.code == 'user-not-found'){
                        print("user not found");
                      }
                      else{
                        print("somethong else happend");
                        print(e);
                      }
       
                    }
       
                }, 
                child: const Text('login'),
              ),
              TextButton(
                onPressed: (){
                  Navigator.of(context).pushNamedAndRemoveUntil
                  ('/register/', 
                  (route) => false);
                }, 
                child: Text("Not register yet? Register here!"))
            ],
          ),
     );
  }
  


  
  

}
