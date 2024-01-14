import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:some_space/space_viewer.dart';

import 'authentication/authentication_service.dart';
import 'group_class.dart';

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
    late Group group;
    group = Group.create(
      name,
      callback: (bool a) {
        setState(() {
          isLoading = false;
        });
        if (a) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SpaceViewer(group),
            ),
          );
        } else {
          groupAlreadyExists = true;
        }
      },
    );
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
                        groupAlreadyExists
                            ? const Text("Space already exists")
                            : Container(),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                            });
                            someFunction(
                                inputController1.text, inputController2.text);
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
