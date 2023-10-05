import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:some_space/drag_and_drop.dart';
import 'main.dart';

PictureDropStack? stack;

class PictureDropStack {
  final storage = FirebaseFirestore.instance.collection("pictures_test");
  int lastId = 0;
  List<DragAndDrop> list = [];
  late HomeScreenState parent;
  String group;

  static Future<List<DragAndDrop>> getList() async {
    print("hello!!!!!!!!!!!!!!");
    final storage = FirebaseFirestore.instance.collection("pictures_test");
    List<DragAndDrop> listTmp = [];
    var a = await storage.get();
    Image? img;
    print(a.docs.length);
    for (var doc in a.docs) {
      print(doc.id + "???");
      if (doc['url'] != "-") {
        print(doc.id + "<<<");
        print(doc['url']);
        img = Image.network(doc['url']!);
      } else {}
      listTmp.add(DragAndDrop.fromDocumentSnapshot(img, doc));
    }
    return listTmp;
  }

  void add(DragAndDrop dragAndDrop) {
    dragAndDrop.id = lastId++;
    list.add(dragAndDrop);
    dragAndDrop.addDocument();
  }

  void remove(DragAndDrop dragAndDrop) {
    dragAndDrop.docRef.delete();
    FirebaseStorage.instance.ref()
        .child('images/picture_'+dragAndDrop.docRef.id).delete();
    for (int i = 0; i < list.length; ++i){
      print(list[i].docRef.id + " ---- " + dragAndDrop.docRef.id);
      if (list[i].docRef.id == dragAndDrop.docRef.id){
        print(list[i]);
        list.removeAt(i);
        break;
      }
    }

    parent.reload();
  }

  void sort() {}

  Future<void> fillList() async {
    var a = await storage.where('group', isEqualTo: group).get();
    Image? img;
    print(a.docs.length);
    for (var doc in a.docs) {
      img = Image.network(doc['url']!);

      list.add(DragAndDrop.fromDocumentSnapshot(img, doc));
    }
    parent.reload();
  }

  PictureDropStack(this.group) {
    fillList();
  }
}
