import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notes/log_in.dart';

class LogOut extends StatefulWidget {
  static const String id = 'log_out';
  const LogOut({super.key});

  @override
  State<LogOut> createState() => _LogOutState();
}

class _LogOutState extends State<LogOut> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0FDF4),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF10B981),
        title: Text('Log Out', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(55),
                border: Border.all(color: Color(0xFF10B981)),
                boxShadow: [
                  BoxShadow(color: Colors.green, blurRadius: 40),
                ],
                color: Color(0xFF10B981),
              ),
              child: Center(
                child: Text(
                  'Press the button below\nTo log out from the app',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFF0FDF4),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 30),

          InkWell(
            onTap: () async {
              SharedPreferences sp =
              await SharedPreferences.getInstance();

              await sp.remove('name');
              await sp.remove('email');

              Navigator.pushNamedAndRemoveUntil(
                context,
                LogIn.id,
                    (route) => false,
              );
            },
            child: Container(
              height: 50,
              width: 300,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(55),
                boxShadow: [
                  BoxShadow(color: Colors.redAccent, blurRadius: 10),
                ],
              ),
              child: Center(
                child: Text(
                  "Log Out",
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