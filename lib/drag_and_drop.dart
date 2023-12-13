import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:some_space/picture_drop_stack.dart';

import 'image_picker.dart';


class DragAndDrop extends StatefulWidget {
  final storage = FirebaseFirestore.instance.collection("pictures_test");
  bool deleted = false;
  double x = 0;
  double y = 0;
  String url = "https://upload.wikimedia.org/wikipedia/commons/3/3d/%D0%9D%D0%B5%D1%82_%D0%B8%D0%B7%D0%BE%D0%B1%D1%80%D0%B0%D0%B6%D0%B5%D0%BD%D0%B8%D1%8F.jpg";
  double scale = 0.7;
  String? group;
  int priority = 0;
  PictureDropStack stack;
  bool editable = false;
  bool uploaded = false;
  File? imageFile;

  bool imageLoaded;

  late Image image;

  late DateTime time;

  late _DragAndDropState state;
  DocumentReference? docRef;

  DragAndDrop copy(){
    var tmp = DragAndDrop(group, imageFile, stack, imageLoaded, key: key,);
    tmp.x = this.x;
    tmp.y = this.y;
    tmp.url = this.url;
    tmp.scale = this.scale;
    tmp.priority = this.priority;
    tmp.editable = this.editable;
    tmp.uploaded = this.uploaded;
    tmp.imageLoaded = this.imageLoaded;
    tmp.image = this.image;
    tmp.time = this.time;
    tmp.docRef = this.docRef;
    return tmp;
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
    }
  }

  //TODO copy-constructor

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



  DragAndDrop(this.group, this.imageFile, this.stack, this.imageLoaded, {super.key}) {
    time = DateTime.now();
    x = 0;
    y = 0;
    if (imageFile != null) {
      image = Image.file(imageFile!, fit: BoxFit.cover,);
    }
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
            child: !widget.editable ? SizedBox(width: min(max(200 * widget.scale, 100), widget.image.width ?? 500),child: widget.image)
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
              child: widget.imageLoaded ? Container() : const CircularProgressIndicator(),
            ),
          ),

        ],
      ),
    );
  }
}
/*
class DND{
  double x = 0;
  double y = 0;
  double scale = 0.7;

  int priority = 0;

  File? imageFile;
  Image image;

  PictureDropStack stack;

  String url;

  String group;

  DND(this.image, this.url, this.group, this.stack);

  DND.fromReference(this.image, this.url, this.group, this.stack, this.x, this.y, this.scale, this.priority);

  Map<String, dynamic> toJson() {
    return {
      "x": x,
      "y": y,
      "url": url,
      "scale": scale,
      "group": group,
      "priority": priority,
    };
  }
}

class DNDEditable extends StatefulWidget{
  DND dnd;

  DNDEditable(this.dnd);

  @override
  State<StatefulWidget> createState() => _DNDEditableState();
}

class _DNDEditableState extends State<DNDEditable> {
  @override
  Widget build(BuildContext context) {
    // widget.state = this;
    // if (widget.dnd.deleted){
    //  return Container();
    // }
    double _baseScaleFactor = widget.dnd.scale;
    return Positioned(
      left: widget.dnd.x,
      top: widget.dnd.y,
      child: Stack(
        children: [
          Container(
            color: Colors.grey,
            child: Center(
              child: GestureDetector(
                onScaleStart: (details) {
                  _baseScaleFactor = widget.dnd.scale;
                },
                onDoubleTap: (){
                  widget.dnd.stack.onTop(widget);
                },
                onScaleUpdate: (details) {
                  setState(() {
                    widget.dnd.scale = _baseScaleFactor * details.scale;
                    widget.dnd._x = widget.dnd._x + details.focalPointDelta.dx;
                    widget.dnd._y += details.focalPointDelta.dy;
                  });
                },
                child: SizedBox(width: min(max(200 * widget.dnd.scale, 100), widget.dnd.image.width ?? 500),child: widget.dnd.image),
              ),
            ),
          ),
          !widget.dnd.editable ? Container() : Positioned(
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
                    widget.dnd.deleted = true;
                    widget.dnd.stack.remove(widget);
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
              child: widget.dnd.imageLoaded ? Container() : const CircularProgressIndicator(),
            ),
          ),

        ],
      ),
    );
  }

}
*/