
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/constants/routes.dart';
import 'package:my_project/enums/menu_action.dart';
import 'package:my_project/services/auth/auth_service.dart';
import 'package:my_project/services/auth/bloc/auth_bloc.dart';
import 'package:my_project/services/auth/bloc/auth_events.dart';
import 'package:my_project/services/cloud/cloud_note.dart';
import 'package:my_project/services/cloud/firebase_cloud_storage.dart';
import 'package:my_project/utilities/dialongs/logout_dialog.dart';
import 'package:my_project/views/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;
  @override
  void initState(){
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Notes"),
        actions:[
          IconButton(
            onPressed: (){
              Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
            }
          , icon: const Icon(Icons.add)),
          PopupMenuButton<MenuAction>(
            onSelected: (value)async{
              switch(value){
                case MenuAction.logout:
                  final shoudlLogout = await showLogOutDiallog(context);
                  if (shoudlLogout){
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  }
                  break;
                  
              }
            },
            itemBuilder: (context){ 
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('log out'),
                ),
              ];
            },
            
            ),

        ]

        ),
      body: StreamBuilder(
                stream: _notesService.allNotes(ownerUserId: userId), 
                builder: (context,snapshot){
                  switch(snapshot.connectionState){
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if(snapshot.hasData){
                        final allNotes = snapshot.data as Iterable<CloudNote>;
                        return NotesListView(
                          notes: allNotes, 
                          onDeleteNote: (note)async{
                            await _notesService.deleteNote(documentId: note.documentId);
                          },
                          onTap: (note){
                            Navigator.of(context).pushNamed(
                              createOrUpdateNoteRoute,
                              arguments: note, 
                            );


                          },);
                          

                      }
                      else{
                        return const CircularProgressIndicator();
                      }
                    default: 
                      return const CircularProgressIndicator();
                  }
                }
              )

    );
  }
}

