import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:some_space/authentication/authentication_service.dart';
import 'package:some_space/creating_screen.dart';
import 'package:some_space/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:some_space/theme/theme_constants.dart';
import 'package:some_space/theme/theme_manager.dart';
import 'authentication/authentication_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
  // signOut();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(lightTheme),
      child: MaterialApp(
        theme: darkTheme,
        themeMode: themeManager.themeMode,
        home: is_logged_in() ? LogInScreen(): AuthenticationScreen() ,
      ),
    );
  }
}
