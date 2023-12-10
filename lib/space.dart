
import 'package:some_space/drag_and_drop.dart';
import 'package:some_space/picture_drop_stack.dart';

import 'image_picker.dart';
import 'package:flutter/material.dart';

class Space extends StatefulWidget {
  String group;
  late PictureGetter pictureGetter;
  late PictureDropStack dnds;

  Space(this.group, {super.key}){
    pictureGetter = PictureGetter();
    dnds = PictureDropStack(group);
  }

  updateDnDs(){

  }

  @override
  State<Space> createState() => SpaceState();
}

class SpaceState extends State<Space> {
  void reload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    widget.dnds.parent = this;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Drag and Drop Widget'),
        ),
        body: Stack(
          children: [
            Stack(
              children: widget.dnds.list,
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.redAccent,
                child: IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () async {
                    var image = await widget.pictureGetter.pickImage();
                    if (image != null) {
                      setState(
                            () {
                          widget.dnds.add(DragAndDrop(widget.group, image, widget.dnds, false));
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ));
  }
}