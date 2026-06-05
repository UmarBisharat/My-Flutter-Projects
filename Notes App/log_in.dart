import 'package:flutter/material.dart';
import 'package:notes/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogIn extends StatefulWidget {
  static const String id = 'log_in';
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    return Scaffold(
      backgroundColor: Color(0xFFF0FDF4),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome',
            style: TextStyle(
              color: Color(0xFF10B981),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: usernameController,
              style: TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: 'user name',
                hintStyle: TextStyle(color: Colors.white),
                prefixIcon: Icon(Icons.person, color: Colors.white),
                fillColor: Color((0xFF10B981)),
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(55),
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(55),
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: emailController,
              style: TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: 'email',
                hintStyle: TextStyle(color: Colors.white),
                prefixIcon: Icon(Icons.email_rounded, color: Colors.white),
                fillColor: Color((0xFF10B981)),
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(55),
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(55),
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          InkWell(
            onTap: () async {
              SharedPreferences sp = await SharedPreferences.getInstance();
              sp.setString('name', usernameController.text.toString());
              sp.setString('email', emailController.text.toString());
              Navigator.pushNamed(context, HomeScreen.id);
            },
            child: Container(
              height: 50,
              width: 300,
              decoration: BoxDecoration(
                color: Color(0xFF10B981),
                borderRadius: BorderRadius.circular(55),
                boxShadow: [BoxShadow(color: Colors.green, blurRadius: 10)],
              ),
              child: Center(
                child: Text(
                  "Let's Goo",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
