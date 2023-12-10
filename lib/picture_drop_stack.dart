import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:some_space/drag_and_drop.dart';
import 'package:some_space/space.dart';

// PictureDropStack? stack;
// List<Image?> images = [];
// List<PhotoPicker?> imagePickers = [];

class PictureDropStack {
  final storage = FirebaseFirestore.instance.collection("pictures_test");
  int lastId = 0;
  int top = 1;
  List<DragAndDrop> list = [];
  late SpaceState parent;
  String group;
  void add(DragAndDrop dragAndDrop) {
    dragAndDrop.id = lastId++;
    dragAndDrop.imageIndex = lastId++;
    list.add(dragAndDrop);

    sort();
    parent.reload();
  }

  void remove(DragAndDrop dragAndDrop) {
    dragAndDrop.docRef!.delete();
    FirebaseStorage.instance.ref()
        .child('images/picture_${dragAndDrop.docRef!.id}').delete();
    list.remove(dragAndDrop);
  }

  void sort() {
    list.sort((a, b) => a.prioty.compareTo(b.prioty));
    parent.reload();
  }

  void onTop(DragAndDrop dnd){
    dnd.prioty = top++;
    sort();
    parent.reload();
  }

  Future<void> fillList() async {
    var a = await storage.where('group', isEqualTo: group).get();
    Image? img;
    print(a.docs.length);
    for (var doc in a.docs) {
      top = max(top, doc['priority'] + 1);
      img = Image.network(doc['url']!);
      list.add(DragAndDrop.fromDocumentSnapshot(img, doc, this, true));
    }
    sort();
    parent.reload();
  }

  PictureDropStack(this.group) {
    fillList();
  }
}
