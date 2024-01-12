import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:some_space/drag_and_drop_content/dnd_content_interface.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'package:some_space/image_picker.dart';

final storage = FirebaseFirestore.instance.collection("pictures");


class DNDPicture extends StatefulWidget implements DNDContent {
  late Image image;
  File? imageFile;
  String downloadUrl = '';

  DocumentSnapshot<Map<String, dynamic>>? docSnapshot;

  late _DNDPictureState listener;

  ContentState state = ContentState.inProgress;

  bool valid = false;

  String? docId;

  Map<String, dynamic> toJson() {
    return {
      'download_url' : downloadUrl,
    };
  }

  @override
  Future<DocumentReference> save() async {
    print("state");
    print(state);
    if (state != ContentState.valid){
      throw Exception("Trying to save not valid picture");
    }
    var docRef = await storage.add(toJson());
    downloadUrl = await uploadImage(imageFile!, docRef.id);
    await docRef.update(toJson());
    state = ContentState.uploaded;
    docId = docRef.id;
    return docRef;
  }

  Future<void> delete() async {
    if (state != ContentState.uploaded){
      throw Exception("Trying to delete not uploaded doc");
    }
    await docSnapshot!.reference.delete();
    await FirebaseStorage.instance
        .ref()
        .child('images/picture_${docId}')
        .delete();

    state = ContentState.deleted;
  }

  Future<void> getImage(bool pick) async {
    if (pick) {
      print("pick!");
      imageFile = await pickImage();
      print("pick2");
      if (imageFile != null) {
        print("not null");
        image = Image.file(imageFile!, fit: BoxFit.cover);
        state = ContentState.valid;
      }
      else {
        print("null");
        state = ContentState.invalid;
      }
    }
    else {
      print("DOCID:::");
      print(docId);
      docSnapshot = await storage.doc(docId).get();
      downloadUrl = docSnapshot!['download_url'];
      image = Image.network(downloadUrl, fit: BoxFit.cover);
      state = ContentState.uploaded;
    }
    listener.notify();
  }

  DNDPicture.new(this.editable, {super.key}) {
    print("DND picture");
    getImage(true);
  }

  DNDPicture.from_firebase(this.docId, this.editable, {super.key}) {
    getImage(false);
  }

  @override
  State<StatefulWidget> createState() => _DNDPictureState();

  @override
  bool editable;

  @override
  String? id;
}


class _DNDPictureState extends State<DNDPicture> {

  void notify() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    widget.listener = this;

    switch (widget.state) {
      case ContentState.inProgress:
        return const CircularProgressIndicator();
      case ContentState.valid:
      case ContentState.uploaded:
        return widget.image;
      case ContentState.invalid:
        return ErrorWidget("Does not have an image");
      case ContentState.deleted:
        return ErrorWidget("Image deleted");
    }
  }

}