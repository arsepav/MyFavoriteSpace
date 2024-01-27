import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:some_space/authentication/authentication_service.dart';

import '../authentication/authentication_screen.dart';

Future<List<Map<String, dynamic>>>? getCreated() async {
  final storage = FirebaseFirestore.instance.collection("groups");
  var ref = await storage.where('editor', isEqualTo: getEmail()).get();
  List<Map<String, dynamic>> list = [];
  for (var snap in ref.docs) {
    list.add(snap.data());
  }
  return list;
}

Future<List<Map<String, dynamic>>>? getVisible() async {
  final storage = FirebaseFirestore.instance.collection("groups");
  var ref = await storage.where('viewers', arrayContains: getEmail()).get();
  List<Map<String, dynamic>> list = [];
  for (var snap in ref.docs) {
    if (snap.data()['editor'] != getEmail()) {
      list.add(snap.data());
    }
  }
  return list;
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});


  @override
  Widget build(BuildContext context) {
    var email = getEmail();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Your email: $email',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'You created:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            buildListView(true),
            const SizedBox(height: 16),
            const Text(
              'You are viewer in:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            buildListView(false),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                signOut();
                while(Navigator.canPop(context)){
                  Navigator.pop(context);
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AuthenticationScreen(),
                  ),
                );
              },
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildListView(bool created) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: created ? getCreated() : getVisible(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  color: Colors.black,
                  child: Center(
                    child: Text(
                      snapshot.data![index]['name'],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          return const Icon(Icons.error);
        }
      },
    );
  }
}
