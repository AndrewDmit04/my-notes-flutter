import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_project/services/cloud/cloud_note.dart';
import 'package:my_project/services/cloud/cloud_storage_constants.dart';
import 'package:my_project/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage{
  
  final notes = FirebaseFirestore.instance.collection('notes');

  Future<void> deleteNote({required String documentId})async{
    try{
      await notes.doc(documentId).delete();
    }
    catch(e){
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote({
    required String documentId, 
    required String text
  })async{
    try{
      await notes.doc(documentId).update({textFieldName: text});
    }
    catch(e){
      throw CouldNotUpdateNoteException();
    }
  }
  
  Future<CloudNote> createNewNote({required String ownerUserID}) async{
    final document = await notes.add({
      ownerUserIDFieldName: ownerUserID,
      textFieldName: '',
    });
    final fetchedNode = await document.get();
    return CloudNote(
      documentId: fetchedNode.id, 
      ownerUserId: ownerUserID, 
      text: ''
    );
  }
  
  
  
  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) =>
    notes.snapshots().map((event) => event.docs
    .map((doc) => CloudNote.fromSnapshot(doc))
    .where((note)=> note.ownerUserId == ownerUserId));
  


  Future<Iterable<CloudNote>> getNotes({required String ownerUserID})async{
    try{
      return await notes.where(
        ownerUserIDFieldName,
        isEqualTo: ownerUserID,
        ).get()
        .then(
          (value) => value.docs.map(
            (doc) => CloudNote.fromSnapshot(doc)
          ),
        );

    }
    catch(e){
      throw CouldNoteGetAllNotesException();
    }
  }

  static final FirebaseCloudStorage _shared = 
    FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
