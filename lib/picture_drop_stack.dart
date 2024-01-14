import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:some_space/authentication/authentication_service.dart';
import 'package:some_space/drag_and_drop.dart';
import 'package:some_space/space.dart';
import 'package:some_space/space_editor.dart';
import 'package:some_space/space_viewer.dart';

class PictureDropStack {
  final storage = FirebaseFirestore.instance.collection("drag_and_drops");
  int lastId = 0;
  int top = 1;
  List<DragAndDrop> list = [];
  List<DragAndDrop> listEditable = [];
  SpaceEditorState? editor;
  late SpaceViewerState viewer;
  String group;

  void add(DragAndDrop dragAndDrop) {
    listEditable.add(dragAndDrop);
    onTop(dragAndDrop);
    if (editor != null) {
      editor!.reload();
    }
  }

  void exitEditState({bool saveChanges = true}) {
    if (saveChanges) {
      list = [];
      for(int i = 0; i < listEditable.length; ++i){
        if (listEditable[i].uploadedState == DNDState.edited || listEditable[i].uploadedState == DNDState.created){
          list.add(listEditable[i].copy());
          list.last.saveDocument();
          list.last.editable = false;
          listEditable[i].uploadedState = DNDState.uploaded;
        }
        else if (listEditable[i].uploadedState == DNDState.uploaded){
          list.add(listEditable[i].copy());
          list.last.editable = false;
        }
        else{
          listEditable[i].saveDocument();
        }
      }
    }
    sort();

    viewer.reload();
  }

  void openEditState() {
    print("going to edit");
    listEditable = [];
    for(int i = 0; i < list.length; ++i){
      listEditable.add(list[i].copy());
      listEditable[i].editable = true;
      print("${list[i].x} ${list[i].y}");
    }
    // editor!.reload();
    viewer.reload();
  }

  void sort({bool sortEditable = true}) {
    // list.sort((a, b) => a.priority.compareTo(b.priority));
    if (sortEditable) {
      listEditable.sort((a, b) => a.priority.compareTo(b.priority));
      if (editor != null) {
        editor!.reload();
      }
    }
    else{
      list.sort((a, b) => a.priority.compareTo(b.priority));
      viewer.reload();
    }
    // viewer.reload();
  }

  void onTop(DragAndDrop dnd) {
    dnd.priority = listEditable.last.priority + 5;
    sort();
    for (int i = 0; i < listEditable.length; ++i){
      if (listEditable[i].priority != i) {
        listEditable[i].priority = i;
        if (listEditable[i].uploadedState != DNDState.created) {
          listEditable[i].uploadedState = DNDState.edited;
        }
      }
    }
    editor!.reload();
  }

  Future<void> fillList(edit) async {
    var a = await storage.where('group', isEqualTo: group).get();
    for (var doc in a.docs) {
      list.add(DragAndDrop.fromDocumentSnapshot(doc, this));
    }
    sort(sortEditable: false);
    viewer.reload();
  }

  PictureDropStack(this.group, {bool edit = false}) {
    fillList(edit);
  }
}
