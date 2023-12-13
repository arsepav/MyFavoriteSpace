import 'package:some_space/drag_and_drop.dart';
import 'package:some_space/picture_drop_stack.dart';
import 'package:some_space/space.dart';
import 'package:some_space/space_editor.dart';

import 'image_picker.dart';
import 'package:flutter/material.dart';

class SpaceViewer extends Space {
  String group;
  late PictureGetter pictureGetter;
  late PictureDropStack dnds;

  SpaceViewer(this.group) {
    pictureGetter = PictureGetter();
    dnds = PictureDropStack(group);
  }

  @override
  State<SpaceViewer> createState() => SpaceViewerState();
}

class SpaceViewerState extends State<SpaceViewer> implements SpaceState {
  @override
  void reload() {

    setState(() {});

    // print(widget.dnds.list.length);
  }

  @override
  Widget build(BuildContext context) {

    print("reloaded");
    for (int i = 0; i < widget.dnds.list.length; ++i){
      print("this_> ${widget.dnds.list[i].x} ${widget.dnds.list[i].y}");
    }
    widget.dnds.viewer = this;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Drag and Drop Widget'),
          actions: [IconButton(onPressed: (){
            widget.dnds.openEditState();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SpaceEditor(widget.group, widget.dnds),
              ),
            );
          }, icon: Icon(Icons.edit))],
        ),
        body: Stack(
          children: [
            Stack(
              children: widget.dnds.list,
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
                  onPressed: () {
                    reload();
                  },
                ),
              ),
            ),
          ],
        ));
  }
}
