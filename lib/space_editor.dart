
import 'package:some_space/drag_and_drop.dart';
import 'package:some_space/picture_drop_stack.dart';
import 'package:some_space/space.dart';

import 'image_picker.dart';
import 'package:flutter/material.dart';

class SpaceEditor extends Space {
  String group;
  PictureDropStack dnds;

  SpaceEditor(this.group, this.dnds){}

  @override
  State<SpaceEditor> createState() => SpaceEditorState();
}

class SpaceEditorState extends State<SpaceEditor> implements SpaceState {
  @override
  void reload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    widget.dnds.editor = this;
    print(widget.dnds.listEditible.length);
    print("build");
    return Scaffold(
        appBar: AppBar(
          title: const Text('Drag and Drop Widget'),
        ),
        body: Stack(
          children: [
            Stack(
              children: widget.dnds.listEditible,
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
                    var image = await pickImage();
                    if (image != null) {
                      setState(
                            () {
                          widget.dnds.add(DragAndDrop(widget.group, widget.dnds, 'picture'));
                        },
                      );
                    }
                  },
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 20,
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.green,
                child: IconButton(
                  icon: const Icon(
                    Icons.save_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () async {
                    widget.dnds.exitEditState();
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ));
  }
}