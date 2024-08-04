import 'package:flutter/material.dart';
import 'package:my_project/constants/routes.dart';
import 'package:my_project/services/auth/auth_exceptions.dart';
import 'package:my_project/services/auth/auth_service.dart';
import 'package:my_project/services/auth/bloc/auth_bloc.dart';
import 'package:my_project/services/auth/bloc/auth_events.dart';
import 'package:my_project/services/auth/bloc/auth_state.dart';
import 'package:my_project/utilities/dialongs/error_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) async{
              if(state is AuthStateLoggedOut){
                if(state.exception is UserNotFoundAuthException){
                  await showErrorDialog(context, 'user not found');
                }
                else if(state.exception is WrongPasswordAuthException){
                  await showErrorDialog(context, 'Wrong Credintials');
                }
                else if(state.exception is GenericAuthException){
                  await showErrorDialog(context, 'Authintication error');
                }
                else if(state.exception != null){
                  await showErrorDialog(context, 'Error: ${state.exception}');
                }
              }
            },
            child: TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                context.read<AuthBloc>().add(AuthEventLogIn(email, password));
              },
              child: const Text('Login'),
            ),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text("Not register yet? Register here!"))
        ],
      ),
    );
  }
}
