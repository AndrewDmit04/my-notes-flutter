import 'package:flutter/material.dart';
import 'package:my_project/utilities/dialongs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context){
  return showGenericDialog(
    context: context, 
    title: 'Sharing', 
    content: 'You Cannot shaare an empty note!', 
    optionsBuilder: ()=>{
      'OK' : null,
    });
}