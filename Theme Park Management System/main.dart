import 'package:flutter/material.dart';

void main() {
  runApp(const ThemeParkManagerApp());
}

class ThemeParkManagerApp extends StatelessWidget {
  const ThemeParkManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Theme Park Manager',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0F3460),
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF16213E),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      home: const ThemeParkHomePage(),
    );
  }
}

class ThemeParkHomePage extends StatefulWidget {
  const ThemeParkHomePage({super.key});

  @override
  State<ThemeParkHomePage> createState() => _ThemeParkHomePageState();
}

class _ThemeParkHomePageState extends State<ThemeParkHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<String, Visitor> visitors = {};
  final Map<String, RideQueue> rideQueues = {
    'Roller Coaster': RideQueue('Roller Coaster'),
    'Ferris Wheel': RideQueue('Ferris Wheel'),
    'Haunted House': RideQueue('Haunted House'),
    'Water Slide': RideQueue('Water Slide'),
  };

  final VisitorBST visitorBST = VisitorBST();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  // -------------------- Core Functions --------------------
  void _addVisitor(String id, String name, bool isVIP) {
    setState(() {
      final visitor = Visitor(id: id.trim(), name: name.trim(), isVIP: isVIP);
      visitors[id.trim()] = visitor;
      visitorBST.insert(visitor);
    });
  }

  void _joinRide(String visitorId, String rideName) {
    final visitor = visitors[visitorId.trim()];
    if (visitor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visitor not found!')),
      );
      return;
    }

    setState(() {
      rideQueues[rideName]?.joinQueue(visitor);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${visitor.name} joined $rideName 🎢')),
    );
  }

  void _upgradeToVIP(String visitorId) {
    final visitor = visitors[visitorId.trim()];
    if (visitor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Visitor not found!')),
      );
      return;
    }

    setState(() {
      visitor.isVIP = true;

      // Update ride queues (move to front if already in queue)
      for (var ride in rideQueues.values) {
        if (ride.queue.contains(visitor)) {
          ride.queue.remove(visitor);
          ride.joinQueue(visitor);
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${visitor.name} is now a VIP ⭐')),
    );
  }

  // -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Park Manager'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Visitors'),
            Tab(icon: Icon(Icons.queue), text: 'Rides'),
            Tab(icon: Icon(Icons.settings), text: 'Actions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVisitorTab(),
          _buildRidesTab(),
          _buildActionsTab(),
        ],
      ),
    );
  }

  // -------------------- Tabs --------------------
  Widget _buildVisitorTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ElevatedButton.icon(
          onPressed: _showAddVisitorDialog,
          icon: const Icon(Icons.person_add),
          label: const Text('Add New Visitor'),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _showSortedVisitors,
          icon: const Icon(Icons.sort),
          label: const Text('Show Sorted Visitors (BST)'),
        ),
        const SizedBox(height: 16),
        ...visitors.values.map((v) {
          return Card(
            child: ListTile(
              leading: Icon(
                v.isVIP ? Icons.star : Icons.person,
                color: v.isVIP ? Colors.amber : Colors.blue,
              ),
              title: Text(v.name),
              subtitle: Text('ID: ${v.id}'),
              trailing: v.isVIP
                  ? const Text('VIP', style: TextStyle(color: Colors.amber))
                  : null,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRidesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: rideQueues.values.map((ride) {
        return Card(
          child: ExpansionTile(
            title: Text(ride.rideName),
            subtitle: Text('Queue: ${ride.queue.length} visitors'),
            children: ride.queue
                .map((v) => ListTile(
                      title: Text(v.name),
                      trailing: v.isVIP
                          ? const Icon(Icons.star, color: Colors.amber)
                          : null,
                    ))
                .toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ElevatedButton.icon(
          onPressed: _showJoinRideDialog,
          icon: const Icon(Icons.directions_car),
          label: const Text('Join Ride Queue'),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _showUpgradeVIPDialog,
          icon: const Icon(Icons.star),
          label: const Text('Upgrade to VIP'),
        ),
      ],
    );
  }

  // -------------------- Dialogs --------------------
  void _showAddVisitorDialog() {
    String id = '';
    String name = '';
    bool isVIP = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: const Color(0xFF16213E),
            title: const Text('Add New Visitor',
                style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Visitor ID',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (v) => id = v,
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Visitor Name',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (v) => name = v,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('VIP Member',
                        style: TextStyle(color: Colors.white)),
                    Switch(
                      value: isVIP,
                      onChanged: (v) => setStateDialog(() => isVIP = v),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (id.isNotEmpty && name.isNotEmpty) {
                    _addVisitor(id, name, isVIP);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showJoinRideDialog() {
    String visitorId = '';
    String rideName = rideQueues.keys.first;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('Join Ride Queue',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Visitor ID',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => visitorId = v,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: rideName,
              dropdownColor: const Color(0xFF16213E),
              items: rideQueues.keys
                  .map((ride) =>
                      DropdownMenuItem(value: ride, child: Text(ride)))
                  .toList(),
              onChanged: (v) => rideName = v ?? '',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              if (visitorId.isNotEmpty && rideName.isNotEmpty) {
                _joinRide(visitorId, rideName);
                Navigator.pop(context);
              }
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  void _showUpgradeVIPDialog() {
    String visitorId = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title:
            const Text('Upgrade to VIP', style: TextStyle(color: Colors.white)),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Visitor ID',
            labelStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (v) => visitorId = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              if (visitorId.isNotEmpty) {
                _upgradeToVIP(visitorId);
                Navigator.pop(context);
              }
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  // -------------------- BST Display --------------------
  void _showSortedVisitors() {
    final sortedList = visitorBST.inOrderTraversal();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('Visitors (Sorted by ID)',
            style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: sortedList.length,
            itemBuilder: (context, index) {
              final v = sortedList[index];
              return ListTile(
                leading: Icon(v.isVIP ? Icons.star : Icons.person,
                    color: v.isVIP ? Colors.amber : Colors.blue),
                title: Text(v.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text('ID: ${v.id}',
                    style: const TextStyle(color: Colors.white70)),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Close', style: TextStyle(color: Colors.white60)),
          ),
        ],
      ),
    );
  }
}

// -------------------- Models --------------------
class Visitor {
  String id;
  String name;
  bool isVIP;
  Visitor({required this.id, required this.name, this.isVIP = false});
}

class RideQueue {
  String rideName;
  final List<Visitor> queue = [];

  RideQueue(this.rideName);

  void joinQueue(Visitor visitor) {
    if (visitor.isVIP) {
      queue.insert(0, visitor);
    } else {
      queue.add(visitor);
    }
  }
}

// -------------------- Binary Search Tree --------------------
class VisitorNode {
  Visitor visitor;
  VisitorNode? left;
  VisitorNode? right;

  VisitorNode(this.visitor);
}

class VisitorBST {
  VisitorNode? root;

  void insert(Visitor visitor) {
    root = _insertRec(root, visitor);
  }

  VisitorNode _insertRec(VisitorNode? node, Visitor visitor) {
    if (node == null) return VisitorNode(visitor);
    if (visitor.id.compareTo(node.visitor.id) < 0) {
      node.left = _insertRec(node.left, visitor);
    } else if (visitor.id.compareTo(node.visitor.id) > 0) {
      node.right = _insertRec(node.right, visitor);
    }
    return node;
  }

  List<Visitor> inOrderTraversal() {
    List<Visitor> result = [];
    _inOrder(root, result);
    return result;
  }

  void _inOrder(VisitorNode? node, List<Visitor> list) {
    if (node != null) {
      _inOrder(node.left, list);
      list.add(node.visitor);
      _inOrder(node.right, list);
    }
  }
}
