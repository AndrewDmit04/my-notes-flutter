import 'package:flutter/material.dart';
import 'package:my_project/constants/routes.dart';
import 'package:my_project/services/auth/auth_exceptions.dart';
import 'package:my_project/services/auth/auth_service.dart';
import 'package:my_project/utilities/dialongs/error_dialog.dart';
import 'dart:developer' as devtools show log;




class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
   appBar: AppBar(title: const Text("Register"),),
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
                      await AuthService.firebase().createUser(
                      email: email, 
                      password: password);
                    final user = AuthService.firebase().currentUser;
                    AuthService.firebase().sendEmailVerification();
                    Navigator.of(context).pushNamed(verifyEmailRoute);
                  }
                  on WeakPasswordAuthException{
                    await showErrorDialog(context, 'weak password');
                  }
                  on EMailAlreadyInUseAuthException{
                    await showErrorDialog(context, 'email alreadyj in use');
                  }
                  on InvalidEmailAuthException{
                    await showErrorDialog(context, 'invalid email');
                  }
                  on GenericAuthException{
                    await showErrorDialog(context, 'register error');
                  }
                }, 
                child: const Text('Register'),
              ),
              TextButton(
                onPressed: (){
                  Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                }, 
                child: const Text("Alredy registered? go login!"))
            ],
          ),
 );
  }
}