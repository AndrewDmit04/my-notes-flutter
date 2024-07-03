
import 'package:flutter/material.dart';
import 'package:my_project/constants/routes.dart';
import 'package:my_project/enums/menu_action.dart';
import 'package:my_project/services/auth/auth_service.dart';
import 'package:my_project/services/crud/notes_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;
  @override
  void initState(){
    _notesService = NotesService();
    _notesService.open();
    super.initState();
  }

  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Notes"),
        actions:[
          IconButton(
            onPressed: (){
              Navigator.of(context).pushNamed(newNoteRoute);
            }
          , icon: const Icon(Icons.add)),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async{
              switch(value){
                case MenuAction.logout:
                  final shoudlLogout = await showLogOutDiallog(context);
                  if (shoudlLogout){
                    await AuthService.firebase().logout();
                    Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (_) => false);
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
      body: FutureBuilder(
        future: _notesService.getorCreateUSer(email: userEmail),
        builder:(context, snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes, 
                builder: (context,snapshot){
                  switch(snapshot.connectionState){
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      return const Text("Waiting for all notes...");
                    default: 
                      return const CircularProgressIndicator();
                  }
                }
              );
            default:
              return const CircularProgressIndicator();
          }

        },

      ),

    );
  }
}

Future<bool> showLogOutDiallog(BuildContext context){
  return showDialog<bool>(
    context: context, 
    builder: (context){
      return AlertDialog(
        title: const Text("Sign out"),
        content: const Text("are you sure you want to sign out"),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.of(context).pop(false);
            }, 
            child: const Text("Cancel")),
            TextButton(
            onPressed: (){
              Navigator.of(context).pop(true);
            }, 
            child: const Text("Log Out"))
        ],
      );
    }
  ).then((value) => value ?? false );
}