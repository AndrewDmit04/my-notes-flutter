import 'package:flutter/material.dart';
import 'package:my_project/utilities/dialongs/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context, 
  String text
){
  return showGenericDialog(
    context: context, 
    title: "An error occured", 
    content: text, 
    optionsBuilder: () => {
      'OK' : null,
    });
}