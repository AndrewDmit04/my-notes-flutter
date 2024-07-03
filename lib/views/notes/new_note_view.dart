import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_project/services/auth/auth_service.dart';
import 'package:my_project/services/crud/notes_service.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  DataBaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textController; 

  void _textControlelrListener() async{
    final note = _note; 
    if(note == null){
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(note: note, text: text);
  }

  void _setupTextControllerListener(){
    _textController.removeListener(_textControlelrListener);
    _textController.addListener(_textControlelrListener);
  }

  Future<DataBaseNote> createNewNote() async{
    final existingNote = _note; 
    if(existingNote != null){
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createNote(owner: owner);
  }
  void _deleteNoteIfTextIsEmpty(){
    final note = _note; 
    if(note != null && _textController.text.isEmpty){
      _notesService.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfTextNotEmpty() async{
    final note = _note; 
    if(note != null && _textController.text.isNotEmpty){
      await _notesService.updateNote(note: note, text: _textController.text);
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
    _notesService = NotesService();
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
        future: createNewNote(),
        builder:(context,snapshot){
          switch(snapshot.connectionState){     
            case ConnectionState.done:
              _note = snapshot.data as DataBaseNote;
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