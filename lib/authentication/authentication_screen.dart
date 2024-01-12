import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:some_space/authentication/authentication_service.dart';
import 'package:some_space/creating_screen.dart';
bool error = false;
String error_text = "";

bool checkEmail(String email){
  return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(email);
}

class AuthenticationScreen extends StatefulWidget {
  AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
  TextEditingController inputController1 = TextEditingController();
  TextEditingController inputController2 = TextEditingController();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  @override
  Widget build(BuildContext context) {
    print("login::");
    print(is_logged_in());
    return Scaffold(
      appBar: AppBar(
        title: Text("Authentication"),
      ),
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: widget.inputController1,
              decoration: const InputDecoration(labelText: 'email'),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9@.]')),
              ],
            ),
            TextField(
              controller: widget.inputController2,
              decoration: const InputDecoration(labelText: 'password'),
              obscureText: true,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9.,!?]')),
              ],
            ),
            error ? Text(error_text) : Container(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (checkEmail(widget.inputController1.text)) {
                  var answer = await singUp(
                      username: widget.inputController1.text,
                      password: widget.inputController2.text);

                  if (answer == "Signed up") {
                    setState(() {
                      error = false;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreatingGroupScreen(),
                      ),
                    );
                  }
                  else{
                    setState(() {
                      error = true;
                      error_text = answer;
                    });
                  }
                }
                else{
                  setState(() {
                    error = true;
                    error_text = "Email Is Incorrect";
                  });
                }
              },
              child: const Text('Sign Up'),
            ),
            ElevatedButton(
              onPressed: () async {
                var answer = await singIn(
                    username: widget.inputController1.text,
                    password: widget.inputController2.text);
                if (answer == "Signed in") {

                  setState(() {
                    error = false;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreatingGroupScreen(),
                    ),
                  );
                }
                else{
                  setState(() {
                    error = true;
                    error_text = answer;
                  });
                }
              },
              child: const Text('Log In'),
            ),
          ],
        ),
      ),
    );

    throw UnimplementedError();
  }
}
