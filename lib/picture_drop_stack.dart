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
  final storage = FirebaseFirestore.instance.collection("drag_and_drops");
  int lastId = 0;
  int top = 1;
  List<DragAndDrop> list = [];
  List<DragAndDrop> listEditible = [];
  SpaceEditorState? editor;
  late SpaceViewerState viewer;
  String group;

  void add(DragAndDrop dragAndDrop) {
    listEditible.add(dragAndDrop);
    onTop(dragAndDrop);
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
        print(listEditible[i].uploadedState);
        if (listEditible[i].uploadedState == DNDState.edited || listEditible[i].uploadedState == DNDState.created){
          print('saving');
          list.add(listEditible[i].copy());
          list.last.saveDocument();
          list.last.editable = false;
          listEditible[i].uploadedState = DNDState.uploaded;
        }
        else if (listEditible[i].uploadedState == DNDState.uploaded){
          list.add(listEditible[i].copy());
          list.last.editable = false;
        }
        else{
          listEditible[i].saveDocument();
        }
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
    // list.sort((a, b) => a.priority.compareTo(b.priority));
    listEditible.sort((a, b) => a.priority.compareTo(b.priority));
    if (editor != null) {
      editor!.reload();
    }
    // viewer.reload();
  }

  void onTop(DragAndDrop dnd) {
    dnd.priority = listEditible.last.priority + 5;
    sort();
    for (int i = 0; i < listEditible.length; ++i){
      if (listEditible[i].priority != i) {
        listEditible[i].priority = i;
        listEditible[i].uploadedState = DNDState.edited;
      }
    }
    editor!.reload();
  }

  Future<void> fillList(edit) async {
    var a = await storage.where('group', isEqualTo: group).get();
    Image img;
    for (var doc in a.docs) {
      list.add(DragAndDrop.fromDocumentSnapshot(doc, this));
    }
    sort();
    viewer.reload();
  }

  PictureDropStack(this.group, {bool edit = false}) {
    fillList(edit);
  }
}
