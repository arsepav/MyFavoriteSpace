
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

enum ContentState { inProgress, valid, invalid, uploaded, deleted }

class DNDContent extends Widget{
  ContentState state = ContentState.inProgress;
  bool editable = false;
  String? docId;

  Future<DocumentReference> save() async {
    throw UnimplementedError();
  }
  Future<void> delete() async {
    throw UnimplementedError();
  }

  @override
  Element createElement() {
    // TODO: implement createElement
    throw UnimplementedError();
  }
  /*
  DNDContent.new(this.editable);

  DNDContent.from_firebase(this.id, this.editable);
  */
}
