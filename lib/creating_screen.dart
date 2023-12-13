import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:some_space/space_editor.dart';
import 'package:some_space/space_viewer.dart';

Future<String> createGroup(String name, String password) async {
  print("check12");
  var a = await FirebaseFirestore.instance.collection("groups").add({'name':name, 'password':password});
  print("check13");
  return a.id;
}

Future<String> createGroupCheck(String name, String password) async {
  var a = await FirebaseFirestore.instance.collection("groups").where('name', isEqualTo: name).get();
  print("a.size");
  print(a.size);
  if (a.size == 0){
    return createGroup(name, password);
  }
  return "";
}

class CreatingGroupScreen extends StatefulWidget {
  final groups_storage = FirebaseFirestore.instance.collection("groups");

  CreatingGroupScreen({super.key});
  @override
  _CreatingGroupScreenState createState() => _CreatingGroupScreenState();
}

class _CreatingGroupScreenState extends State<CreatingGroupScreen> {
  TextEditingController inputController1 = TextEditingController();
  TextEditingController inputController2 = TextEditingController();
  bool isLoading = false;
  bool groupAlreadyExists = false;

  Future<void> someFunction(String name, String password) async {
    print("before1");
    String group = await createGroupCheck(name, password);
    print("after1");
    setState(() {
      isLoading = false;
    });
    if (group != "") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SpaceViewer(group),
        ),
      );
    }
    else{
      groupAlreadyExists = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Экран с полями ввода'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: inputController1,
              decoration: const InputDecoration(labelText: 'Поле 1'),
            ),
            TextField(
              controller: inputController2,
              decoration: const InputDecoration(labelText: 'Поле 2'),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : Column(
                  children: [
                    groupAlreadyExists ? const Text("Group already exists") : Container(),
                    ElevatedButton(
              onPressed: () {
                    setState(() {
                      isLoading = true;
                    });
                    someFunction(inputController1.text, inputController2.text);
              },
              child: const Text('Отправить'),
            ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}