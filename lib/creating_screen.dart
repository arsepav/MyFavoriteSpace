import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:some_space/main.dart';

Future<String> createGroup(String name, String password) async {
  var a = await FirebaseFirestore.instance.collection("groups").add({'name':name, 'password':password});
  return a.id;
}

Future<String> createGroupCheck(String name, String password) async {
  var a = await FirebaseFirestore.instance.collection("groups").where('name', isEqualTo: name).get();

  if (a.size == 0){
    return createGroup(name, password);
  }
  return "";
}

class CreatingGroupScreen extends StatefulWidget {
  final groups_storage = FirebaseFirestore.instance.collection("groups");
  @override
  _CreatingGroupScreenState createState() => _CreatingGroupScreenState();
}

class _CreatingGroupScreenState extends State<CreatingGroupScreen> {
  TextEditingController inputController1 = TextEditingController();
  TextEditingController inputController2 = TextEditingController();
  bool isLoading = false;
  bool groupAlreadyExists = false;

  Future<void> someFunction(String name, String password) async {
    print("before");
    String group = await createGroupCheck(name, password);
    print("after");
    setState(() {
      isLoading = false;
    });
    if (group != "") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(group),
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
        title: Text('Экран с полями ввода'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: inputController1,
              decoration: InputDecoration(labelText: 'Поле 1'),
            ),
            TextField(
              controller: inputController2,
              decoration: InputDecoration(labelText: 'Поле 2'),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : Column(
                  children: [
                    groupAlreadyExists ? Text("Group already exists") : Container(),
                    ElevatedButton(
              onPressed: () {
                    setState(() {
                      isLoading = true;
                    });
                    someFunction(inputController1.text, inputController2.text);
              },
              child: Text('Отправить'),
            ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}