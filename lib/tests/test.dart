import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:some_space/group_class.dart';

import '../authentication/authentication_service.dart';

Future<void> test() async {
  late Group group;
  group = Group("yan", callback: (bool a) {
    print(a);
    print(group.viewers);
  });
}
