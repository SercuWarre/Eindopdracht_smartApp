// import 'package:daily_photo/models/details.dart';
// import 'package:daily_photo/models/icons.dart';
import 'package:daily_photo/firebase_options.dart';
import 'package:daily_photo/models/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Photo',
      theme: ThemeData(
        scaffoldBackgroundColor:
            Colors.grey, // Set scaffold background color to black
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white), // Set text color to white
          bodyMedium: TextStyle(color: Colors.white), // Set text color to white
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black, // Set app bar color to black
          titleTextStyle:
              TextStyle(color: Colors.white), // Set app bar text color to white
        ),
      ),
      home: const LoginPage(),
    );
  }
}
