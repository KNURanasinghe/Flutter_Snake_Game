import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:snake_game/Screens/homePage.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCwOc7_Gu016mDJZjrf7AnUo0w48HRWpaQ",
          authDomain: "snake-game-c38f8.firebaseapp.com",
          projectId: "snake-game-c38f8",
          storageBucket: "snake-game-c38f8.appspot.com",
          messagingSenderId: "909861820917",
          appId: "1:909861820917:web:5b042de35da8711e5d68bc",
          measurementId: "G-DC91JCP62N"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: const HomePage(),
      theme: ThemeData(brightness: Brightness.dark),
    );
  }
}
