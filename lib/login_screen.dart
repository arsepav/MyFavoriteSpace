import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:some_space/creating_screen.dart';
import 'package:some_space/memory_saver.dart';
import 'package:some_space/space_viewer.dart';
import 'package:some_space/theme/theme_constants.dart';
import 'package:some_space/theme/theme_manager.dart';

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

  @override
  void dispose(){
    themeManager.removeListener(themeListener);
    super.dispose();
  }

  @override
  void initState(){
    themeManager.addListener(themeListener);
    super.initState();
  }

  themeListener(){
    if (mounted){
      setState(() {

      });
    }
  }

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
          builder: (_) => SpaceViewer(group),
        ),
      );
    } else {
      joinProblem = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    var themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      // backgroundColor: DarkTheme.backgroundColor,

      appBar: AppBar(
        title: const Text("Welcome"),
        // backgroundColor: DarkTheme.backgroundColor,
        actions: [
          /*Switch(value: themeManager.themeMode == ThemeMode.dark,
              onChanged: (newValue){
                themeManager.toggleTheme(newValue);
          setState(() {
            var newTheme =
            (themeNotifier.getTheme().brightness == Brightness.dark)
                ? lightTheme
                : darkTheme;

            themeNotifier.setTheme(newTheme);
          });
        }),*/
        ],
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
                          //style: ElevatedButton.styleFrom(backgroundColor: DarkTheme.buttonsColor),
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
                // style: ElevatedButton.styleFrom(backgroundColor: DarkTheme.buttonsColor),
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
                          },
                              // style: ElevatedButton.styleFrom(backgroundColor: DarkTheme.buttonsColor),
                              child: Text(groups[index][0]));
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
