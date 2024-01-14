import 'package:some_space/authentication/authentication_service.dart';
import 'package:some_space/picture_drop_stack.dart';
import 'package:some_space/space.dart';
import 'package:some_space/space_editor.dart';

import 'group_class.dart';
import 'package:flutter/material.dart';


class SpaceViewer extends Space {
  Group group;

  bool isEditor = false;

  late PictureDropStack dnds;

  SpaceViewer(this.group) {
    dnds = PictureDropStack(group.id);
    isEditor = group.editor == getEmail();
  }

  @override
  State<SpaceViewer> createState() => SpaceViewerState();
}

class SpaceViewerState extends State<SpaceViewer> implements SpaceState {
  @override
  void reload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    widget.dnds.viewer = this;
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.group.name),
          actions: [
            widget.isEditor
                ? IconButton(
                    onPressed: () {
                      widget.dnds.openEditState();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SpaceEditor(widget.group.id, widget.dnds),
                        ),
                      );
                    },
                    icon: Icon(Icons.edit),
                  )
                : Container()
          ],
        ),
        body: Stack(
          children: [
            Stack(
              children: widget.dnds.list,
            ),
          ],
        ));
  }
}
