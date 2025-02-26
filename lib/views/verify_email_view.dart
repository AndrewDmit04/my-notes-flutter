import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/constants/routes.dart';
import 'package:my_project/services/auth/auth_service.dart';
import 'package:my_project/services/auth/bloc/auth_bloc.dart';
import 'package:my_project/services/auth/bloc/auth_events.dart';

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
            onPressed: (){
              context.read<AuthBloc>().add(const AuthEventSendEmailVeriefication());
            }, 
            child: const Text("send email verification")),

          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(const AuthEventLogOut());
            },
            child: const Text('restart'),)
        ],),
    );
  }
}