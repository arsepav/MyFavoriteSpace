import 'package:cloud_firestore/cloud_firestore.dart';

import 'authentication/authentication_service.dart';

class Group {
  late String id;
  late String editor;
  late List<dynamic> viewers;
  String name;
  late String password;

  late DocumentReference docRef;

  bool loaded = false;

  Future<void> loadData(Function(bool)? callback) async {
    bool answer = false;
    var query = await FirebaseFirestore.instance
        .collection("groups")
        .where('name', isEqualTo: name)
        .where(
          Filter.or(
            Filter("viewers", arrayContains: "*"),
            Filter(
              "viewers",
              arrayContains: getEmail(),
            ),
          ),
        )
        .get();

    docRef = query.docs.first.reference;

    if (query.docs.length > 0){
      answer = true;
      id = query.docs.first.id;
      var data = query.docs.first.data();
      editor = data['editor'];
      viewers = data['viewers'];
      password = data['password'];
    }

    if (callback != null) {
      callback(answer);
    }
  }

  Future<void> createData(Function(bool)? callback) async {
    print("here!!!!");
    try {
      docRef = await FirebaseFirestore.instance.collection("groups").add({
        'name': name,
        'password': "no password",
        'viewers': ['*'],
        'editor': getEmail()
      });
      id = docRef.id;
      if (callback != null) {
        callback(true);
      }
    }
    catch(exception){
      print("Exceptiooon::");
      print(exception);
      if (callback != null) {
        callback(false);
      }
    }
  }

  void update() async {
    docRef.update({'viewers' : viewers});
  }

  Group(this.name, {Function(bool)? callback}) {
    loadData(callback);
  }

  Group.create(this.name, {Function(bool)? callback}) {

    loaded = true;

    password = 'no password';
    viewers = ['*'];
    editor = getEmail()!;
    createData(callback);
  }
}
