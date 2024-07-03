import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:my_project/services/crud/crud_exception.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

const dbName = "notes.db";
const noteTable = 'note';
const userTable = 'user';
const idColum = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSynchedWithCloud = 'is_synched_with_cloud';

const createUserTable = '''
  CREATE TABLE IF NOT EXISTS "user" (
  "id"	INTEGER NOT NULL,
  "email"	TEXT NOT NULL UNIQUE,
   PRIMARY KEY("id" AUTOINCREMENT)
      );
''';
const createNoteTable = '''
      CREATE TABLE IF NOT EXISTS "note" (
      "id"	INTEGER NOT NULL,
      "user_id"	INTEGER NOT NULL,
      "text"	TEXT,
      "is_synched_with_cloud"	INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY("user_id") REFERENCES "user"("id"),
      PRIMARY KEY("id" AUTOINCREMENT)
    );
''';

class NotesService{
  
  Database? _db; 

  List<DataBaseNote> _notes = []; 

  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance(){
    _notesStreamController = StreamController<List<DataBaseNote>>.broadcast(
      onListen: (){
        _notesStreamController.sink.add(_notes); 
      },
    );
  }
  factory NotesService() =>_shared; 

  late final StreamController<List<DataBaseNote>> _notesStreamController;
  Stream<List<DataBaseNote>> get allNotes => _notesStreamController.stream;

  Future<DataBaseUSer> getorCreateUSer({required String email}) async{
    try{
      final user = await getUser(email: email);
      return user;
    }
    on CouldNotFindUser{
      final createdUser = await createUser(email: email);
      return createdUser; 
    }
    catch(e){
      rethrow;
    }
  }

  Future<void> _cacheNotes() async{
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DataBaseNote> updateNote({required DataBaseNote note, required String text}) async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    await getNote(id: note.id);

    final updatedCount = await db.update(noteTable, {
      textColumn: text, 
      isSynchedWithCloud: 0,
    });

    if(updatedCount == 0){
      throw CouldNotUpdateNote();
    }
    else{
      final updatedNote =  await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id); 
      _notes.add(updatedNote); 
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }
  
  Future<Iterable<DataBaseNote>> getAllNotes()async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow(); 

    final notes = await db.query(noteTable);

    return notes.map((n)=>DataBaseNote.fromRow(n));
  }

  Future<DataBaseNote> getNote({required int id}) async{
    await _ensureDbIsOpen();
    final db =  _getDatabaseOrThrow();

    final notes = await db.query(
        noteTable,
        limit: 1, 
        where: 'id=?',
        whereArgs: [id],
      );

    if(notes.isEmpty){
        throw CouldNotFindNote();
    }
    else{
        final note = DataBaseNote.fromRow(notes.first); 
        _notes.removeWhere((note) => note.id == id);
        _notes.add(note); 
        _notesStreamController.add(_notes);
        return note;
     }
  }

  Future<int> deleteAllNotes() async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletetions = await db.delete(noteTable); 
    _notes = []; 
    _notesStreamController.add(_notes);
    return numberOfDeletetions;
  }

  Future<void> deleteNote({required int id}) async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final deleteCount = await db.delete(
      noteTable, 
      where: 'id=?',
      whereArgs: [id],
    );
    if(deleteCount == 0){
      throw CouldNotDeleteNote();
    }
    else{
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
    
  }

  Future<DataBaseNote> createNote({required DataBaseUSer owner})async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final dbUser = await getUser(email:owner.email); 

    if(dbUser != owner){
      throw CouldNotFindUser();
    }

    const text = '';

    final NoteId = await db.insert(
      noteTable,{
        userIdColumn: owner.id,
        textColumn: text, 
        isSynchedWithCloud: 1,
      } 
    );

    final note = DataBaseNote(
      id: NoteId,
      userId: owner.id, 
      text: text, 
      isSynchedCloud: true, 
      );
    
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note; 


  }

  Future<DataBaseUSer> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );
    if(results.isEmpty){
      throw CouldNotFindUser();
    }
    else{
      return DataBaseUSer.fromRow(results.first);
    }

  }

  Future<DataBaseUSer> createUser({required String email}) async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow(); 
    final results = await db.query(
      userTable,
      limit:1,
      where: 'email = ?', 
      whereArgs: [email.toLowerCase()]
    );
    if(results.isNotEmpty){
        throw UserAlreadyExisists;
    }
    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DataBaseUSer(
      id:userId, 
    email: email);
  }

  Future<void> deleteUser({required String email}) async{
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable, 
      where: 'email = ?', 
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1){
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow(){
    final db = _db;
    if(db == null){
      throw DatabaseIsNotOpen();
    }
    else{
      return db;
    }

  }

  Future<void> close() async{
    final db = _db;
    if(db == null){
      throw DatabaseIsNotOpen();
    }
    else{
      await db.close();
      _db = null; 
    }
  }
  
  Future<void> _ensureDbIsOpen() async{
    try{
      await open();
    }on DatabaseAlreadyOpenException{

    }
  }

  Future<void> open() async{
    if(_db != null){
      throw DatabaseAlreadyOpenException(); 
    }
    try{
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path,dbName);
      final db = await openDatabase(dbPath);
      _db = db; 

      //create user table
      await db.execute(createUserTable);

      //create note table
      await db.execute(createNoteTable);
      await _cacheNotes();

    }
    on MissingPlatformDirectoryException{
      throw UnableToGetDocumentDirectory();
    }
  }

}

@immutable
class DataBaseUSer{
  final int id; 
  final String email; 
  const DataBaseUSer({
    required this.id,
    required this.email});

  DataBaseUSer.fromRow(Map<String, Object?> map) 
  :id = map[idColum] as int, 
  email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email =$email'; 

  @override bool operator==(covariant DataBaseUSer other ) => id == other.id;
  
  @override
  int get hashCode => id.hashCode;
  
}

class DataBaseNote{
  final int id; 
  final int userId;
  final String text;
  final bool isSynchedCloud;

  const DataBaseNote({required this.id, required this.userId, required this.text, required this.isSynchedCloud});

  DataBaseNote.fromRow(Map<String, Object?> map) 
  :id = map[idColum] as int, 
  userId = map[userIdColumn] as int,
  text = map[textColumn] as String, 
  isSynchedCloud = (map[isSynchedWithCloud] as int) == 1 ? true : false; 

  @override
  String toString() => 'Note, ID = $id, userId = $userId, isSynchedWithCloud = $isSynchedCloud, text=$text'; 

  @override bool operator==(covariant DataBaseNote other ) => id == other.id;
  
  @override
  int get hashCode => id.hashCode;
}

