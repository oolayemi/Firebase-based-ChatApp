import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:placeholder/models/firebase_user.dart';
import 'package:placeholder/provider/image_upload_provider.dart';
import 'package:placeholder/resources/chat_methods.dart';

class StorageMethods {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  late Reference _storageReference;

  FirebaseUser user = FirebaseUser();
  final ChatMethods _chatMethods = ChatMethods();

  Future<String?> uploadImageToStorage(File image) async {
    try {
      _storageReference = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}');

      UploadTask _storageUploadTask = _storageReference.putFile(image);

      var url = await (await _storageUploadTask).ref.getDownloadURL();

      return url;
    } catch (e) {
      print(e);
      return null;
    }
  }

  void uploadImage(
      { required File image,
      required String? receiverId,
      required String? senderId,
      required ImageUploadProvider imageUploadProvider}) async {
    imageUploadProvider.setToLoading();
    String? url = await uploadImageToStorage(image);

    imageUploadProvider.setToIdle();

    _chatMethods.setImageMsg(url, receiverId, senderId);
  }
}
