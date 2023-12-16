import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:some_space/drag_and_drop_content/drag_and_drop_picture.dart';
import 'package:some_space/picture_drop_stack.dart';

import 'drag_and_drop_content/dnd_content_interface.dart';
import 'image_picker.dart';

final storage = FirebaseFirestore.instance.collection("drag_and_drops");

enum DNDState { uploaded, created, edited, deleted }

class DragAndDrop extends StatefulWidget {
  DNDState uploadedState = DNDState.edited;

  double x = 0;
  double y = 0;
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
    print(uploadedState);
    if (uploadedState == DNDState.deleted && docRef != null) {
      docRef!.delete();
      dndContent!.delete();
    } else if (uploadedState == DNDState.edited) {
      print("updating1");
      if (docRef != null) {
        print("updating2");
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

  DragAndDrop.copy(DragAndDrop dnd) {
    y = dnd.y;
    x = dnd.x;
    scaleX = dnd.scaleX;
    scaleY = dnd.scaleY;
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

  DragAndDrop.new(this.group, this.stack, this.type) {
    editable = true;
    uploadedState = DNDState.created;
    switch (type) {
      case 'picture':
        dndContent = DNDPicture(false);
    }
  }

  DragAndDrop.fromDocumentSnapshot(this.documentSnapshot, this.stack) {

    uploadedState = DNDState.uploaded;
    docRef = documentSnapshot!.reference;

    type = documentSnapshot!['type'];
    x = documentSnapshot!['x'];
    y = documentSnapshot!['y'];
    scaleX = documentSnapshot!['scale_x'];
    scaleY = documentSnapshot!['scale_y'];
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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    widget.state = this;
    if (widget.uploadedState == DNDState.deleted) {
      return Container();
    }
    return Positioned(
      left: widget.x,
      top: widget.y,
      child: Stack(
        children: [
          Container(
            color: Colors.grey,
            child: !widget.editable
                ? SizedBox(
                    width: min(max(200 * widget.scaleX, 100), 500),
                    height: min(max(200 * widget.scaleY, 100), 500),
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
                          widget.uploadedState = DNDState.edited;
                        }
                      },
                      onScaleUpdate: (details) {
                        setState(() {
                          widget.scaleX =
                              _baseScaleFactor1 * details.horizontalScale;
                          widget.scaleY =
                              _baseScaleFactor2 * details.verticalScale;
                          widget.x = widget.x + details.focalPointDelta.dx;
                          widget.y += details.focalPointDelta.dy;
                          if (widget.uploadedState == DNDState.uploaded) {
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

/*


class DragAndDrop extends StatefulWidget {

  bool deleted = false;
  double x = 0;
  double y = 0;
  String url = "https://upload.wikimedia.org/wikipedia/commons/3/3d/%D0%9D%D0%B5%D1%82_%D0%B8%D0%B7%D0%BE%D0%B1%D1%80%D0%B0%D0%B6%D0%B5%D0%BD%D0%B8%D1%8F.jpg";
  double scale = 0.7;
  double scaleX = 0.7;
  double scaleY = 0.7;
  String? group;
  int priority = 0;
  late PictureDropStack stack;
  bool editable = false;
  bool uploaded = false;
  File? imageFile;

  bool imageLoaded = true;

  late Image image;

  late DateTime time;

  late _DragAndDropState state;
  DocumentReference? docRef;

  DragAndDrop copy(){
    return DragAndDrop.copy(this);
  }

  doesImageExist() async {
    try {
      final response = await http.head(Uri.parse(url));
      if (response.statusCode == 404){
        deleted = true;
      }
    } catch (e) {
      return false;
    }
  }

  bool operator>(DragAndDrop dnd){
    return time.compareTo(dnd.time) > 0;
  }

  int compareTo(DragAndDrop dnd){
    return time.compareTo(dnd.time);
  }

  void reload(){
    state.reload();
  }

  Map<String, dynamic> toCoordJson() {
    return {
      "x": x,
      'y': y,
      'scale': scale,
      "time": Timestamp.fromDate(time),
      'priority' : priority,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      "x": x,
      "y": y,
      "url": url,
      "scale": scale,
      "group": group,
      "time": Timestamp.fromDate(time),
      "priority": priority,
    };
  }

  void saveDocument() async {
    if (deleted){
      docRef!.delete();
      FirebaseStorage.instance
          .ref()
          .child('images/picture_${docRef!.id}')
          .delete();
    }
    if (uploaded){
      if (docRef != null) {
        docRef!.update(toCoordJson());
      }
    }
    else {
      docRef = await storage.add(toJson());
      url = await uploadImage(imageFile!, docRef!.id);
      await docRef!.update({'url': url});
      imageLoaded = true;
      state.reload();
      print("Картинка загружена!");
    }
  }

  DragAndDrop.fromDocumentSnapshot(this.image, DocumentSnapshot ds, this.stack, this.imageLoaded, this.editable, {super.key}) {
    Timestamp myTimeStamp = ds['time'];
    time = myTimeStamp.toDate();
    docRef = ds.reference;
    y = ds['y'];
    x = ds['x'];
    scale = ds['scale'];
    group = ds['group'] ?? "test";
    priority = ds['priority'];
    url = ds['url'];
    doesImageExist();
    uploaded = true;
  }

  DragAndDrop.copy(DragAndDrop dnd) {
    imageLoaded = dnd.imageLoaded;
    group = dnd.group;
    imageFile = dnd.imageFile;
    stack = dnd.stack;
    imageLoaded = dnd.imageLoaded;
    x = dnd.x;
    y = dnd.y;
    url = dnd.url;
    scale = dnd.scale;
    priority = dnd.priority;
    editable = dnd.editable;
    uploaded = dnd.uploaded;
    imageLoaded = dnd.imageLoaded;
    image = dnd.image;
    time = dnd.time;
    docRef = dnd.docRef;
  }



  DragAndDrop(this.group, this.imageFile, this.stack, this.imageLoaded, {this.editable = true, super.key}) {
    time = DateTime.now();
    x = 0;
    y = 0;
    if (imageFile != null) {
      image = Image.file(imageFile!, fit: BoxFit.cover,);
    }
    stack.onTop(this);
  }

  @override
  State<StatefulWidget> createState() => _DragAndDropState();
}

class _DragAndDropState extends State<DragAndDrop> {

  void reload(){
    setState(() {});
  }

  double _baseScaleFactor = 0.7;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    widget.state = this;
    if (widget.deleted){
      return Container();
    }
    return Positioned(
      left: widget.x,
      top: widget.y,
      child: Stack(
        children: [
          Container(
            color: Colors.grey,
            child: !widget.editable ? SizedBox(width: min(max(200 * widget.scale, 100), widget.image.width?? 500),child: widget.image)
                : Center(
              child: GestureDetector(
                onScaleStart: (details) {
                  _baseScaleFactor = widget.scale;
                },
                onDoubleTap: (){
                  widget.stack.onTop(widget);
                },
                onScaleUpdate: (details) {
                  setState(() {
                    widget.scale = _baseScaleFactor * details.scale;
                    widget.x = widget.x + details.focalPointDelta.dx;
                    widget.y += details.focalPointDelta.dy;
                  });
                },
                child: SizedBox(width: min(max(200 * widget.scale, 100), widget.image.width ?? 500),child: widget.image),
              ),
            ),
          ),
          !widget.editable ? Container() : Positioned(
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
                    widget.deleted = true;
                  });
                },
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: widget.imageLoaded || widget.editable ? Container() : const CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}

*/
