
import 'package:flutter/material.dart';
import 'package:my_project/utilities/dialongs/generic_dialog.dart';

Future<bool> showLogOutDiallog(BuildContext context){
  return showGenericDialog(
    context: context, 
    title: 'Log out', 
    content: 'Are tou sure you want to log out?', 
    optionsBuilder: ()=>{
      'cancel' : false,
      'Log out' : true,
    }).then((value) => value ?? false); 
}