import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

bool is_logged_in(){
  if(_firebaseAuth.currentUser == null){
    return false;
  }
  return true;
}


String? getEmail(){
  return _firebaseAuth.currentUser?.email;
}

Future<String> singIn(
    {required String username, required String password}) async {
  try {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: username, password: password);
    return "Signed in";
  } on FirebaseAuthException catch (e) {
    return e.message ?? "no error message";
  }
}

Future<String> singUp(
    {required String username, required String password}) async {
  try {
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: username, password: password);
    return "Signed up";
  } on FirebaseAuthException catch (e) {
    return e.message ?? "no error message";
  }
}

void signOut(){
  _firebaseAuth.signOut();
}