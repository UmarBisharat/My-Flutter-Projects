import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text('WhatsApp', style: TextStyle(color: Colors.white)),
          bottom: TabBar(
            tabs: [
              Tab(child: Icon(Icons.camera_alt, color: Colors.white)),
              Tab(
                child: Text('Chats', style: TextStyle(color: Colors.white)),
              ),
              Tab(
                child: Text('Status', style: TextStyle(color: Colors.white)),
              ),
              Tab(
                child: Text('Calls', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          actions: [
            Icon(Icons.search, color: Colors.white),
            SizedBox(width: 10),
            PopupMenuButton(
              icon: Icon(Icons.more_horiz, color: Colors.white),
              itemBuilder: (context) => [
                PopupMenuItem(value: '1', child: Text('New Groups')),
                PopupMenuItem(value: '2', child: Text('Settings')),
                PopupMenuItem(value: '3', child: Text('Log Out')),
              ],
            ),
            SizedBox(width: 10),
          ],
        ),
        body: TabBarView(
          children: [
            Text('Camera'),
            ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://media.licdn.com/dms/image/v2/D4D03AQFSfWlsXowPug/profile-displayphoto-scale_400_400/B4DZv4HQzKJoAg-/0/1769394214008?e=1773878400&v=beta&t=7Ql5nN-e2jqOPIWA5BUi1B87Ibt9mLvBSvQLcdbL4Gk',
                    ),
                  ),
                  title: Text('Umar Bisharat'),
                  subtitle: Text('Alhamdulillah'),
                  trailing: Text('3:09 pm'),
                );
              },
            ),
            ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(' New updates'),
                        ListTile(
                          leading: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.green, width: 5),
                            ),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                'https://media.licdn.com/dms/image/v2/D4D03AQFSfWlsXowPug/profile-displayphoto-scale_400_400/B4DZv4HQzKJoAg-/0/1769394214008?e=1773878400&v=beta&t=7Ql5nN-e2jqOPIWA5BUi1B87Ibt9mLvBSvQLcdbL4Gk',
                              ),
                            ),
                          ),
                          title: Text('Umar Bisharat'),
                          subtitle: Text('Alhamdulillah'),
                          trailing: Text('3:09 pm'),
                        ),
                      ],
                    ),
                  );
                } else {
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('new updates'),
                        ListTile(
                          leading: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.green, width: 5),
                            ),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                'https://media.licdn.com/dms/image/v2/D4D03AQFSfWlsXowPug/profile-displayphoto-scale_400_400/B4DZv4HQzKJoAg-/0/1769394214008?e=1773878400&v=beta&t=7Ql5nN-e2jqOPIWA5BUi1B87Ibt9mLvBSvQLcdbL4Gk',
                              ),
                            ),
                          ),
                          title: Text('Umar Bisharat'),
                          subtitle: Text('Alhamdulillah'),
                          trailing: Text('3:09 pm'),
                        ),
                      ],
                    ),
                  );
                }

                return ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green, width: 5),
                    ),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://media.licdn.com/dms/image/v2/D4D03AQFSfWlsXowPug/profile-displayphoto-scale_400_400/B4DZv4HQzKJoAg-/0/1769394214008?e=1773878400&v=beta&t=7Ql5nN-e2jqOPIWA5BUi1B87Ibt9mLvBSvQLcdbL4Gk',
                      ),
                    ),
                  ),
                  title: Text('Umar Bisharat'),
                  subtitle: Text('Alhamdulillah'),
                  trailing: Text('3:09 pm'),
                );
              },
            ),
            ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://media.licdn.com/dms/image/v2/D4D03AQFSfWlsXowPug/profile-displayphoto-scale_400_400/B4DZv4HQzKJoAg-/0/1769394214008?e=1773878400&v=beta&t=7Ql5nN-e2jqOPIWA5BUi1B87Ibt9mLvBSvQLcdbL4Gk',
                    ),
                  ),
                  title: Text('Umar Bisharat'),
                  subtitle: Text(
                    index / 2 == 0
                        ? 'you missed audio call'
                        : 'call time is 3:27 pm',
                  ),
                  trailing: Icon(
                    index / 2 == 0 ? Icons.call_end : Icons.video_call,
                    color: Colors.red,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
