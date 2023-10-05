import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:some_space/picture_drop_stack.dart';
import 'package:some_space/main.dart';

import 'image_picker.dart';

class DragAndDrop extends StatefulWidget {
  final storage = FirebaseFirestore.instance.collection("pictures_test");
  double _x = 0;
  double _y = 0;
  String url = "https://upload.wikimedia.org/wikipedia/commons/3/3d/%D0%9D%D0%B5%D1%82_%D0%B8%D0%B7%D0%BE%D0%B1%D1%80%D0%B0%D0%B6%D0%B5%D0%BD%D0%B8%D1%8F.jpg";
  Image? img;
  double scale = 0.7;
  String? group;

  late DocumentReference docRef;
  late int id;

  void updateUrl(String url){
    this.url = url;
    print(url);
    docRef.update({'url' : url});
  }

  Map<String, dynamic> toCoordJson() {
    return {
      "x": _x,
      'y': _y,
      'scale': scale,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      "x": _x,
      "y": _y,
      "url": url,
      "scale": scale,
      "group": group,
    };
  }


  void addDocument() async {
    docRef = await storage.add(toJson());
  }


  DragAndDrop.fromDocumentSnapshot(this.img, DocumentSnapshot ds,) {
    this.docRef = ds.reference;
    _y = ds['y'];
    _x = ds['x'];
    scale = ds['scale'];
    group = ds['group'] ?? "test";
  }

  DragAndDrop(this.group) {
    _x = 0;
    _y = 0;
  }

  @override
  State<StatefulWidget> createState() => _DragAndDropState();
}

class _DragAndDropState extends State<DragAndDrop> {
  double _baseScaleFactor = 0.7;
  @override
  Widget build(BuildContext context) {
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
                },
                onScaleUpdate: (details) {
                  setState(() {
                    widget.scale = _baseScaleFactor * details.scale;
                    widget._x += details.focalPointDelta.dx;
                    widget._y += details.focalPointDelta.dy;
                  });
                  widget.docRef.update(widget.toCoordJson());
                },
                child: PhotoPicker(widget,  widget.scale),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              child: IconButton(
                icon: const Icon(

                  Icons.delete_forever_rounded,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    stack!.remove(widget);
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
