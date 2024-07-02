import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

const dbName = "notes.db";
const noteTable = 'note';
const userTable = 'user';
const idColum = "id";
const emailColumn = "email";
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
class DatabaseAlreadyOpenException implements Exception{}
class UnableToGetDocumentDirectory implements Exception{}
class DatabaseIsNotOpen implements Exception{}
class CouldNotDeleteUser implements Exception{}
class UserAlreadyExisists implements Exception{}
class CouldNotFindUser implements Exception{}

class NotesService{
  
  Database? _db; 

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: "email:?",
      whereArgs: [email.toLowerCase()],
    );
    if(results.isEmpty){
      throw CouldNotFindUser();
    }
    else{
      return DatabaseUser.fromRow(results.first);
    }

  }

  Future<DataBaseUSer> createUser({required String email}) async{
    final db = _getDatabaseOrThrow(); 
    final results = await db.query(
      userTable,
      limit:1,
      where: 'email:?', 
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
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable, 
      where: 'email=?', 
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
  String toString() => 'Note, ID = $id, userId = $userId, isSynchedWithCloud = $isSynchedCloud'; 

  @override bool operator==(covariant DataBaseNote other ) => id == other.id;
  
  @override
  int get hashCode => id.hashCode;
}

