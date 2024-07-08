class CloudStorageException implements Exception{
  const CloudStorageException();
}
//C in Crud
class CouldNotCreateNoteException extends CloudStorageException{}

//R in Crud
class CouldNoteGetAllNotesException extends CloudStorageException{}

//U in crud
class CouldNotUpdateNoteException extends CloudStorageException{}

//D in crud
class CouldNotDeleteNoteException extends CloudStorageException{}
