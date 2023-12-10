import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:some_space/picture_drop_stack.dart';

import 'image_picker.dart';


class DragAndDrop extends StatefulWidget {
  final storage = FirebaseFirestore.instance.collection("pictures_test");
  bool deleted = false;
  double _x = 0;
  double _y = 0;
  String url = "https://upload.wikimedia.org/wikipedia/commons/3/3d/%D0%9D%D0%B5%D1%82_%D0%B8%D0%B7%D0%BE%D0%B1%D1%80%D0%B0%D0%B6%D0%B5%D0%BD%D0%B8%D1%8F.jpg";
  int imageIndex = 0;
  double scale = 0.7;
  String? group;
  int prioty = 0;
  PictureDropStack stack;

  bool imageLoaded;
  
  late Image image;

  bool operator>(DragAndDrop dnd){
    return time.compareTo(dnd.time) > 0;
  }

  int compareTo(DragAndDrop dnd){
    return time.compareTo(dnd.time);
  }

  late DateTime time;

  late _DragAndDropState state;

  void reload(){
    state.reload();
  }

  DocumentReference? docRef;
  late int id;

  Map<String, dynamic> toCoordJson() {
    return {
      "x": _x,
      'y': _y,
      'scale': scale,
      "time": Timestamp.fromDate(time),
      'priority' : prioty,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      "x": _x,
      "y": _y,
      "url": url,
      "scale": scale,
      "group": group,
      "time": Timestamp.fromDate(time),
      "priority": prioty,
    };
  }

  void addDocument(File imgFile) async {
    docRef = await storage.add(toJson());
    url = await uploadImage(imgFile ,docRef!.id);
    await docRef!.update({'url' : url});
    imageLoaded = true;
    reload();
  }


  DragAndDrop.fromDocumentSnapshot(this.image, DocumentSnapshot ds, this.stack, this.imageLoaded, {super.key}) {
    Timestamp myTimeStamp = ds['time'];
    time = myTimeStamp.toDate();
    docRef = ds.reference;
    _y = ds['y'];
    _x = ds['x'];
    scale = ds['scale'];
    group = ds['group'] ?? "test";
    prioty = ds['priority'];
    url = ds['url'];

  }



  DragAndDrop(this.group, File imgFile, this.stack, this.imageLoaded, {super.key}) {
    time = DateTime.now();
    _x = 0;
    _y = 0;
    image = Image.file(imgFile);
    addDocument(imgFile);
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
    widget.state = this;
    if (widget.deleted){
      return Container();
    }
    return Positioned(
      left: widget._x,
      top: widget._y,
      child: Stack(
        children: [
          Container(
            color: Colors.grey,
            child: Center(
              child: GestureDetector(
                onScaleStart: (details) {
                  _baseScaleFactor = widget.scale;
                  if (widget.docRef != null) {
                    widget.docRef!.update(widget.toCoordJson());
                  }
                },
                onDoubleTap: (){
                  widget.stack.onTop(widget);
                  if (widget.docRef != null) {
                    widget.docRef!.update(widget.toCoordJson());
                  }
                },
                onScaleUpdate: (details) {
                  setState(() {
                    widget.scale = _baseScaleFactor * details.scale;
                    widget._x += details.focalPointDelta.dx;
                    widget._y += details.focalPointDelta.dy;
                  });
                  if (widget.docRef != null) {
                    widget.docRef!.update(widget.toCoordJson());
                  }
                },
                child: SizedBox(width: min(max(200 * widget.scale, 100), widget.image.width ?? 800),child: widget.image),
              ),
            ),
          ),
          Positioned(
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
                    widget.stack.remove(widget);
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
