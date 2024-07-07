import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_project/services/crud/notes_service.dart';
import 'package:my_project/utilities/dialongs/delete_dialog.dart';

typedef DeleteNoteCallback = void Function(DataBaseNote note);

class NotesListView extends StatelessWidget {

  final List<DataBaseNote> notes; 
  final DeleteNoteCallback onDeleteNote;
  const NotesListView({super.key, required this.notes, required this.onDeleteNote});

  @override
  Widget build(BuildContext context) {

    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context,index){
      final note = notes[index];
      return ListTile(
        title: Text(
               note.text,
               maxLines: 1,
               softWrap: true,
               overflow: TextOverflow.ellipsis,
             ),
        trailing: IconButton(
          onPressed: () async{
            final shouldDelete = await showDeleteDialog(context); 
            if(shouldDelete){
              onDeleteNote(note); 
            }
          }, 
          icon: Icon(Icons.delete),),

           );
         },
       );
  }
}