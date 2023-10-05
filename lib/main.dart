import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:some_space/drag_and_drop.dart';
import 'package:some_space/login_screen.dart';
import 'package:some_space/memory_saver.dart';
import 'package:some_space/picture_drop_stack.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:some_space/resizeble_widget.dart';
import 'firebase_options.dart';
import 'image_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // deleteAllGroups();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LogInScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  String group;

  HomeScreen(this.group){
    stack = PictureDropStack(group);
  }

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  void reload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    stack!.parent = this;
    return Scaffold(
        appBar: AppBar(
          title: Text('Drag and Drop Widget'),
        ),
        body: Stack(
          children: [
            Stack(
              children: stack!.list,
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
                  onPressed: () {
                    setState(
                      () {
                        stack!.add(DragAndDrop(widget.group));
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ));
  }
}
