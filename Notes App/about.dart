import 'package:flutter/material.dart';

class About extends StatefulWidget {
  static const String id = 'about';
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0FDF4),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF10B981),
        title: Text('About', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
              height: 500,
              width: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Color(0xFF10B981)),
                boxShadow: [BoxShadow(color: Colors.green, blurRadius: 40)],
                color: Color(0xFF10B981),
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Text(
                    '''
This Notes App was created by Umar Bisharat as a personal learning and practice project.

While learning the basics of Flutter and SharedPreferences, I decided to apply the concepts I had learned by building a complete app from scratch. This project allows users to create and store notes, and it demonstrates my understanding of Flutter UI design, navigation, state management, and local data storage using SharedPreferences.

Currently, the app can store only one note at a time because it does not use a database. As I continue learning technologies such as SQLite, Hive, and Firebase, I plan to upgrade this application to support multiple notes, cloud storage, synchronization, and many more advanced features.

What makes this project special to me is that it was built entirely from my own planning and ideas. Before writing any code, I designed the screens and app flow on paper and planned how the application would work. I did not follow any tutorial specifically for building this app. Instead, I relied on the knowledge and skills I gained while learning Flutter and implemented the project using my own understanding and problem-solving abilities.

This is my first self-planned Flutter application, and it represents an important step in my journey as a Software Engineering student and Flutter developer. InshaAllah, I will continue learning, improving my skills, and building even better applications in the future.

Developed by Umar Bisharat.
''',
                    style: TextStyle(
                      color: Color(0xFFF0FDF4),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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
