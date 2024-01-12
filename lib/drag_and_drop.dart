import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:some_space/drag_and_drop_content/drag_and_drop_picture.dart';
import 'package:some_space/picture_drop_stack.dart';

import 'drag_and_drop_content/dnd_content_interface.dart';

final storage = FirebaseFirestore.instance.collection("drag_and_drops");

enum DNDState { uploaded, created, edited, deleted }

double maxScale = 2;
double minScale = 0.4;

class DragAndDrop extends StatefulWidget {
  DNDState uploadedState = DNDState.created;

  double x = 70;
  double y = 70;

  double _x = 0;
  double _y = 0;

  double scaleX = 0.7;
  double scaleY = 0.7;

  String? group;

  int priority = 0;

  late PictureDropStack stack;

  bool editable = false;

  late _DragAndDropState state;
  QueryDocumentSnapshot? documentSnapshot;
  DocumentReference? docRef;

  DNDContent? dndContent;

  late String type;

  Future<void> saveDocument() async {
    if (uploadedState == DNDState.deleted && docRef != null) {
      docRef!.delete();
      dndContent!.delete();
    } else if (uploadedState == DNDState.edited) {
      if (docRef != null) {
        docRef!.update(toCoordJson());
      }
    } else if (uploadedState == DNDState.created) {
      await dndContent!.save();
      docRef = await storage.add(toJson());
      uploadedState = DNDState.uploaded;
    }
    state.reload();
  }

  DragAndDrop copy() {
    return DragAndDrop.copy(this);
  }

  DragAndDrop.copy(DragAndDrop dnd, {super.key}) {
    y = dnd.y;
    x = dnd.x;
    scaleX = dnd.scaleX;
    scaleY = dnd.scaleY;

    _x = x - 100 * scaleX;
    _y = y - 100 * scaleY;

    group = dnd.group;
    priority = dnd.priority;
    stack = dnd.stack;
    editable = dnd.editable;
    state = dnd.state;
    documentSnapshot = dnd.documentSnapshot;
    dndContent = dnd.dndContent;
    type = dnd.type;
    uploadedState = dnd.uploadedState;
    docRef = dnd.docRef;
  }

  DragAndDrop(this.group, this.stack, this.type, {super.key}) {
    _x = x - 100 * scaleX;
    _y = y - 100 * scaleY;
    editable = true;
    uploadedState = DNDState.created;
    print("create dnd");
    switch (type) {
      case 'picture':
        dndContent = DNDPicture(false);
    }
  }

  DragAndDrop.fromDocumentSnapshot(this.documentSnapshot, this.stack, {super.key}) {



    uploadedState = DNDState.uploaded;
    docRef = documentSnapshot!.reference;

    type = documentSnapshot!['type'];
    x = documentSnapshot!['x'];
    y = documentSnapshot!['y'];

    scaleX = documentSnapshot!['scale_x'];
    scaleY = documentSnapshot!['scale_y'];

    _x = x - 100 * scaleX;
    _y = y - 100 * scaleY;
    group = documentSnapshot!['group'];
    priority = documentSnapshot!['priority'];

    switch (type) {
      case 'picture':
        dndContent = DNDPicture.from_firebase(documentSnapshot!['content'], true);
        break;
      default:
        throw Exception('No such type');
    }
  }

  void reload() {
    state.reload();
  }

  Map<String, dynamic> toCoordJson() {
    return {
      "x": x,
      'y': y,
      'scale_x': scaleX,
      'scale_y': scaleY,
      'priority': priority,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'scale_x': scaleX,
      'scale_y': scaleY,
      'group': group,
      'priority': priority,
      'type': type,
      'content': dndContent!.docId,
      'url': '',
      'additional': '',
    };
  }

  @override
  State<StatefulWidget> createState() => _DragAndDropState();
}

class _DragAndDropState extends State<DragAndDrop> {
  void reload() {
    setState(() {});
  }

  double _baseScaleFactor1 = 0.7;
  double _baseScaleFactor2 = 0.7;

  @override
  Widget build(BuildContext context) {
    widget.state = this;
    if (widget.uploadedState == DNDState.deleted) {
      return Container();
    }
    return Positioned(
      left: widget._x,
      top: widget._y,
      child: Stack(
        children: [
          Container(
            color: Colors.grey,
            child: !widget.editable
                ? SizedBox(
                    width: 200 * widget.scaleX,
                    height: 200 * widget.scaleY,
                    child: widget.dndContent)
                : Center(
                    child: GestureDetector(
                      onScaleStart: (details) {
                        _baseScaleFactor1 = widget.scaleX;
                        _baseScaleFactor2 = widget.scaleY;
                      },
                      onDoubleTap: () {
                        widget.stack.onTop(widget);
                        if (widget.uploadedState == DNDState.uploaded) {
                          print('make edited1');
                          widget.uploadedState = DNDState.edited;
                        }
                      },
                      onScaleUpdate: (details) {
                        setState(() {
                          widget.scaleX =
                              min(max(_baseScaleFactor1 * details.horizontalScale, minScale), maxScale);
                          widget.scaleY =
                              min(max(_baseScaleFactor2 * details.verticalScale, minScale), maxScale);

                          widget.x += details.focalPointDelta.dx;
                          widget.y += details.focalPointDelta.dy;

                          widget._x = widget.x - 100 * widget.scaleX;
                          widget._y = widget.y - 100 * widget.scaleY;

                          if (widget.uploadedState == DNDState.uploaded) {
                            print('make edited2');
                            widget.uploadedState = DNDState.edited;
                          }
                        });
                      },
                      child: SizedBox(
                          width: min(max(200 * widget.scaleX, 100), 500),
                          height: min(max(200 * widget.scaleY, 100), 500),
                          child: widget.dndContent),
                    ),
                  ),
          ),
          !widget.editable
              ? Container()
              : Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete_forever_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          widget.uploadedState = DNDState.deleted;
                        });
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

