import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:some_space/space_viewer.dart';

Future<String> createGroup(String name, String password) async {
  print("check12");
  var a = await FirebaseFirestore.instance.collection("groups").add({'name':name, 'password':password});
  print("check13");
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
    String group = await createGroupCheck(name, password);
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
        title: const Text('Create your space'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: inputController1,
                decoration: const InputDecoration(labelText: 'name of space'),
              ),
              TextField(
                controller: inputController2,
                decoration: const InputDecoration(labelText: 'password'),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                    children: [
                      groupAlreadyExists ? const Text("Space already exists") : Container(),
                      ElevatedButton(
                onPressed: () {
                      setState(() {
                        isLoading = true;
                      });
                      someFunction(inputController1.text, inputController2.text);
                },
                child: const Text('Create'),
              ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}