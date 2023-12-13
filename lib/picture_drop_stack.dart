import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:some_space/drag_and_drop.dart';
import 'package:some_space/space.dart';
import 'package:some_space/space_editor.dart';
import 'package:some_space/space_viewer.dart';

// PictureDropStack? stack;
// List<Image?> images = [];
// List<PhotoPicker?> imagePickers = [];

class PictureDropStack {
  final storage = FirebaseFirestore.instance.collection("pictures_test");
  int lastId = 0;
  int top = 1;
  List<DragAndDrop> list = [];
  List<DragAndDrop> listEditible = [];
  SpaceEditorState? editor;
  late SpaceViewerState viewer;
  String group;

  void add(DragAndDrop dragAndDrop) {
    listEditible.add(dragAndDrop);
    sort();
    if (editor != null) {
      editor!.reload();
    }
  }

  void exitEditState({bool saveChanges = true}) {
    print("going from edit");
    if (saveChanges) {
      list = [];
      print(listEditible.length);
      for(int i = 0; i < listEditible.length; ++i){
        if (!listEditible[i].deleted) {
          list.add(listEditible[i]);
          list[list.length-1].editable = false;
          //list[list.length-1].reload();
          print("${list[i].x} ${list[i].y}");
          list[list.length-1].priority++;
        }
        list[i].saveDocument();

      }
    }
    sort();

    viewer.reload();
  }

  void openEditState() {
    print("going to edit");
    listEditible = [];
    for(int i = 0; i < list.length; ++i){
      listEditible.add(list[i].copy());
      listEditible[i].editable = true;
      print("${list[i].x} ${list[i].y}");
    }
    // editor!.reload();
    viewer.reload();
  }

  void sort() {
    list.sort((a, b) => a.priority.compareTo(b.priority));
    listEditible.sort((a, b) => a.priority.compareTo(b.priority));
    if (editor != null) {
      editor!.reload();
    }
    // viewer.reload();
  }

  void onTop(DragAndDrop dnd) {
    dnd.priority = top++;
    sort();
    editor!.reload();
  }

  Future<void> fillList(edit) async {
    var a = await storage.where('group', isEqualTo: group).get();
    Image img;
    // print(a.docs.length);
    for (var doc in a.docs) {
      top = max(top, doc['priority'] + 1);
      img = Image.network(
        doc['url']!,
        fit: BoxFit.cover,
      );
      // print(img);
      list.add(DragAndDrop.fromDocumentSnapshot(img, doc, this, true, edit));
    }
    sort();
    viewer.reload();
  }

  PictureDropStack(this.group, {bool edit = false}) {
    fillList(edit);
  }
}
