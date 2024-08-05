import 'package:flutter/widgets.dart';
import 'package:my_project/utilities/dialongs/generic_dialog.dart';

Future<void> showPasswordResetSendDialog(BuildContext context){
  return showGenericDialog(
    context: context, 
    title: 'Password Reset', 
    content: 'We have sent a password reset link. Please check your email for more information.', 
    optionsBuilder: () => { 'OK' : null}, );
}