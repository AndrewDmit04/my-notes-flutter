
import 'package:flutter/material.dart';
import 'package:my_project/utilities/dialongs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context){
  return showGenericDialog(
    context: context, 
    title: 'Delete', 
    content: 'Are tou sure you want to Delete this item?', 
    optionsBuilder: ()=>{
      'cancel' : false,
      'Yes' : true,
    }).then((value) => value ?? false); 
}