import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class StorageService {

  final FirebaseStorage _firebasestorage = FirebaseStorage.instance;

  StorageService();

  Future<String?> upLoadUserPip({
    required File file,
    required String uid,
  }) async {
  Reference fileRef = _firebasestorage
      .ref('users/pfps')
      .child('$uid${p.extension(file.path)}');
  UploadTask task = fileRef.putFile(file);
  return task.then((p) {
    if (p.state == TaskState.success) {
      return fileRef.getDownloadURL();
        }
    return null;
      },
    );
  }

  Future<String?> uploadImageToChat({required File file, required String chatID}) async {
    Reference fileRef = _firebasestorage.ref('chats/$chatID')
        .child('${DateTime.now().toIso8601String()}${p.extension(file.path)}');
    UploadTask task = fileRef.putFile(file);
    return task.then((p) {
      if (p.state == TaskState.success) {
        return fileRef.getDownloadURL();
      }
      return null;
    },
    );
  }
}