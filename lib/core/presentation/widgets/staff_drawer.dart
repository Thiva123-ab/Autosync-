import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StaffDrawer extends StatelessWidget {
  final String currentRole;

  const StaffDrawer({super.key, required this.currentRole});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(currentRole.toUpperCase()),
            accountEmail: Text(FirebaseAuth.instance.currentUser?.email ?? 'Unknown User'),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.blue),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
