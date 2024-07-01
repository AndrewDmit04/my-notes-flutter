import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_project/constants/routes.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("verifyEmail")),
      body: Column(children: [
          const Text("we've sent you an email verification. Please open it in order to verify your account"),
          const Text("If you haven't received a verification email yet, press the button below"),
          TextButton(
            onPressed: ()async{
              final user = FirebaseAuth.instance.currentUser;
              await user?.sendEmailVerification();
            }, 
            child: const Text("send email verification")),

          TextButton(
            onPressed: () async{
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
            },
            child: const Text('restart'),)
        ],),
    );
  }
}