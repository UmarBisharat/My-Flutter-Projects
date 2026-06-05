import 'package:flutter/material.dart';
import 'package:notes/about.dart';
import 'package:notes/account_info.dart';
import 'package:notes/all_notes.dart';
import 'package:notes/log_out.dart';
import 'package:notes/new_note.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = '';
  String email = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  void loadData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    username = sp.getString('name') ?? '';
    email = sp.getString('email') ?? '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0FDF4),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF10B981),
        title: Text('My Notes', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      drawer: Drawer(
        backgroundColor: Color(0xFF10B981),
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR_u8QLa4WlhisqJvQjp2m-sjjr82OrHKx78g&s',
                ),
              ),
              decoration: BoxDecoration(color: Color(0xFFF0FDF4)),
              accountName: Text(
                username,
                style: TextStyle(color: Colors.black),
              ),
              accountEmail: Text(email, style: TextStyle(color: Colors.black)),
            ),
            ListTile(
              leading: Text(
                'All Notes',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              trailing: Icon(Icons.note_alt_sharp, color: Colors.white),
              onTap: () {
                Navigator.pushNamed(context, AllNotes.id);
              },
            ),
            ListTile(
              leading: Text(
                'Account Info',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              trailing: Icon(Icons.person, color: Colors.white),
              onTap: () {
                Navigator.pushNamed(context, AccountInfo.id);
              },
            ),
            ListTile(
              leading: Text(
                'About',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              trailing: Icon(Icons.phone_android, color: Colors.white),
              onTap: () {
                Navigator.pushNamed(context, About.id);
              },
            ),
            ListTile(
              leading: Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              trailing: Icon(Icons.logout, color: Colors.white),
              onTap: () {
                Navigator.pushNamed(context, LogOut.id);
              },
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(55),
                border: Border.all(color: Color(0xFF10B981)),
                boxShadow: [BoxShadow(color: Colors.green, blurRadius: 40)],
                color: Color(0xFF10B981),
              ),
              child: Center(
                child: Text(
                  'Press the + button below \n To create a note',
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF10B981),
        onPressed: () {
          Navigator.pushNamed(context, NewNote.id);
        },
        child: Icon(Icons.note_add_sharp, color: Color(0xFFF0FDF4), size: 30),
      ),
    );
  }
}
