import 'package:flutter/material.dart';
import 'package:notes/about.dart';
import 'package:notes/account_info.dart';
import 'package:notes/all_notes.dart';
import 'package:notes/home_screen.dart';
import 'package:notes/log_in.dart';
import 'package:notes/log_out.dart';
import 'package:notes/new_note.dart';
import 'package:notes/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Starting screen
      home: const SplashScreen(),

      // Routes
      routes: {
        SplashScreen.id: (context) => const SplashScreen(),
        LogIn.id: (context) => const LogIn(),
        HomeScreen.id: (context) => const HomeScreen(),
        NewNote.id: (context) => const NewNote(),
        AllNotes.id: (context) => const AllNotes(),
        AccountInfo.id: (context) => const AccountInfo(),
        About.id: (context) => const About(),
        LogOut.id: (context) => const LogOut(),
      },
    );
  }
}