
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/services/auth/bloc/auth_bloc.dart';
import 'package:my_project/services/auth/bloc/auth_events.dart';
import 'package:my_project/services/auth/bloc/auth_state.dart';
import 'package:my_project/utilities/dialongs/error_dialog.dart';
import 'package:my_project/utilities/dialongs/password_reset_email_sent_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState(){
    _controller = TextEditingController();
    super.initState();
  }
  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc,AuthState>(
      listener: (context,state)async{
        if(state is AuthStateForgotPassword){
          if(state.hasSentEmail){
            _controller.clear();
            await showPasswordResetSendDialog(context);
          }
          if(state.exception != null){
            await showErrorDialog(context, 'We could not process your request, please make sure you are a registered user');
          }

        }
      },
      child: Scaffold(
        appBar: AppBar(title:const Text('Forgot password')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('If you forgot your password type your email in below'),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Your email adress here ....'),

              ),

            TextButton(
              onPressed: (){
                final email = _controller.text;
                context.read<AuthBloc>().add(AuthEventForgotPassword(email: email));
              },
              child: const Text("Send me password rest link")
            ),
            TextButton(
              onPressed: (){
                context.read<AuthBloc>().add(const AuthEventLogOut());
              },
              child: const Text("go back to login page")
            )
            ],
          ),
        )
      )
    );
  }
}