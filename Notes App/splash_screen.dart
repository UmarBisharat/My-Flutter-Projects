import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notes/home_screen.dart';
import 'package:notes/log_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  static const String id = 'splash_screen';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    startApp();
  }

  void startApp() async {
    await Future.delayed(const Duration(seconds: 5));

    SharedPreferences sp = await SharedPreferences.getInstance();
    String? name = sp.getString('name');

    if (name != null && name.isNotEmpty) {
      Navigator.pushReplacementNamed(context, HomeScreen.id);
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
          const LogIn(),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image(
        height: double.infinity,
        fit: BoxFit.fitHeight,
        image: NetworkImage(
          'https://learning.nd.edu/assets/596229/600x/note_taking.jpg',
        ),
      ),
    );
  }
}