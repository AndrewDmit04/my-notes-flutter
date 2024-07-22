import 'package:flutter/material.dart';
import 'package:my_project/services/auth/auth_service.dart';
import 'package:my_project/utilities/generics/get_arguments.dart';
import 'package:my_project/services/cloud/cloud_note.dart';
import 'package:my_project/services/cloud/cloud_storage_exceptions.dart';
import 'package:my_project/services/cloud/firebase_cloud_storage.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController; 

  void _textControlelrListener() async{
    final note = _note; 
    if(note == null){
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(documentId: note.documentId, text: text);
  }

  void _setupTextControllerListener(){
    _textController.removeListener(_textControlelrListener);
    _textController.addListener(_textControlelrListener);
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async{
    
    final widgetNote = context.getArgument<CloudNote>();
    
    if(widgetNote != null){
      _note = widgetNote; 
      _textController.text = widgetNote.text;
      return widgetNote; 
    }
    
    final existingNote = _note; 
    if(existingNote != null){
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email;
    final userId = currentUser.id; 
    final newNote = await _notesService.createNewNote(ownerUserID: userId);
    _note = newNote; 
    return newNote; 
  }
  
  void _deleteNoteIfTextIsEmpty(){
    final note = _note; 
    if(note != null && _textController.text.isEmpty){
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  void _saveNoteIfTextNotEmpty() async{
    final note = _note; 
    final text = _textController.text;
    if(note != null && text.isNotEmpty){
      await _notesService.updateNote(documentId: note.documentId, text: text,);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }
  @override
  void initState(){
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
    // _note = await createNewNote();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Note"),
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder:(context,snapshot){
          switch(snapshot.connectionState){     
            case ConnectionState.done:
              _setupTextControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(hintText: "Start typing your note...",),

              );
              

            default:
              return const CircularProgressIndicator();

          }
        },
        
        )

    );
  }
}