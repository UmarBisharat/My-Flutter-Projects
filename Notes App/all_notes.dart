import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllNotes extends StatefulWidget {
  static const String id = 'all_notes';
  const AllNotes({super.key});

  @override
  State<AllNotes> createState() => _AllNotesState();
}

class _AllNotesState extends State<AllNotes> {
  String noteName = '';
  String description = '';
  String note = '';
  @override
  void initState() {
    super.initState();
    loadNote();
  }

  void loadNote() async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    setState(() {
      noteName = sp.getString('note name') ?? '';

      description = sp.getString('description') ?? '';

      note = sp.getString('note') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF10B981),
        title: Text('Your Latest Note', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      backgroundColor: Color(0xFFF0FDF4),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 200),
                      child: Text('Note Name'),
                    ),
                    Container(
                      width: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Color(0xFF10B981),
                      ),
                      child: Center(
                        child: Text(
                          noteName,
                          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.only(right: 157),
                      child: Text('Note Description'),
                    ),
                    Container(
                      width: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Color(0xFF10B981),
                      ),
                      child: Center(
                        child: Text(
                          description,
                          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.only(right: 230),
                      child: Text('Note'),
                    ),
                    Container(
                      width: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Color(0xFF10B981),
                      ),
                      child: Center(
                        child: Text(note, style: TextStyle(color: Colors.white,fontSize: 15)),
                      ),
                    ),
                    SizedBox(height: 40,),
                    InkWell(
                        onTap: () async {
                          SharedPreferences sp =
                              await SharedPreferences.getInstance();

                          await sp.remove('note name');
                          await sp.remove('description');
                          await sp.remove('note');

                          setState(() {
                            noteName = '';
                            description = '';
                            note = '';
                          });
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
                            "Delete Note",
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
