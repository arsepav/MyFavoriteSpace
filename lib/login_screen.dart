import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:some_space/creating_screen.dart';
import 'package:some_space/memory_saver.dart';
import 'package:some_space/space.dart';

Future<String> joinGroupCheck(String name, String password) async {
  var a = await FirebaseFirestore.instance
      .collection("groups")
      .where('name', isEqualTo: name)
      .get();

  if (a.size == 1 && a.docs[0]['password'] == password) {
    return a.docs[0].id;
  }
  return "";
}

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  TextEditingController groupTextController = TextEditingController();

  TextEditingController passwordTextController = TextEditingController();

  bool isLoading = false;

  bool joinProblem = false;

  Future<void> someFunction(String name, String password) async {
    String group = await joinGroupCheck(name, password);
    setState(() {
      isLoading = false;
    });
    if (group != "") {
      groupTextController.clear();
      passwordTextController.clear();
      addRecentGroups(name,password);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Space(group),
        ),
      );
    } else {
      joinProblem = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: groupTextController,
                decoration: const InputDecoration(labelText: 'group name'),
              ),
              TextField(
                obscureText: true,
                controller: passwordTextController,
                decoration: const InputDecoration(
                  labelText: 'password',
                ),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        joinProblem
                            ? const Text(
                                "Group does not exists or password is incorrect")
                            : Container(),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              joinProblem = false;
                              isLoading = true;
                            });
                            someFunction(groupTextController.text,
                                passwordTextController.text);
                          },
                          child: const Text('Join'),
                        ),
                      ],
                    ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreatingGroupScreen(),
                    ),
                  );
                },
                child: const Text("Create new group"),
              ),
              const SizedBox(height: 25,),
              const Text("Here you can find recent groups:"),
              const SizedBox(height: 10,),
              FutureBuilder<List<List<String>>>(
                future: getRecentGroups(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return const CircularProgressIndicator();
                    default:
                      List<List<String>> groups = snapshot.data!;
                      int len = groups.length;
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: len > 3 ? 3 : len,
                        itemBuilder: (context, index) {
                          return ElevatedButton(onPressed: (){
                            someFunction(groups[index][0], groups[index][1]);
                          }, child: Text(groups[index][0]));
                        },
                      );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
