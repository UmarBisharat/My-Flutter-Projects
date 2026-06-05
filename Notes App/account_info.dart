import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountInfo extends StatefulWidget {
  static const String id = 'account_info';
  const AccountInfo({super.key});

  @override
  State<AccountInfo> createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {
  String Xname = '';
  String Xemail = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  void loadData() async {
    SharedPreferences  sp =  await SharedPreferences.getInstance();
    Xname = sp.getString('name') ?? '';
    Xemail = sp.getString('email') ?? '';
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
backgroundColor: Color(0xFFF0FDF4),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF10B981),
        title: Text('Account Info', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body:
          Center(
            child: Container(
              height: 300,
              width: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(55),
                border: Border.all(color: Color(0xFF10B981)),
                boxShadow: [BoxShadow(color: Colors.green, blurRadius: 40)],
                color: Color(0xFF10B981),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('user name -->',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),
                        Text(
                        Xname.toString(),
                          style: TextStyle(
                            color: Color(0xFFF0FDF4),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('email -->',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),),
                        Text(
                          Xemail.toString(),
                          style: TextStyle(
                            color: Color(0xFFF0FDF4),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),

        //
      //
    );
  }
}
