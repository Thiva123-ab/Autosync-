import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StaffDrawer extends StatelessWidget {
  final String currentRole;

  const StaffDrawer({super.key, required this.currentRole});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Unknown User';
    final role = currentRole.toUpperCase();

    return Drawer(
      backgroundColor: const Color(0xFF0F172A),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.tealAccent.withOpacity(0.5), width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.tealAccent.withOpacity(0.2), blurRadius: 10, spreadRadius: 2),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF1E293B),
                    child: Icon(Icons.person, size: 35, color: Colors.tealAccent),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),

          _buildDrawerItem(
            icon: Icons.dashboard_rounded,
            title: 'Dashboard',
            onTap: () => Navigator.pop(context),
            iconColor: Colors.tealAccent,
          ),

          const Spacer(),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Divider(color: Colors.white.withOpacity(0.1)),
          ),
          
          Padding(
            padding: const EdgeInsets.only(bottom: 24, top: 8),
            child: _buildDrawerItem(
              icon: Icons.logout_rounded,
              title: 'Logout',
              onTap: () async {
                await FirebaseAuth.instance.signOut();
              },
              iconColor: Colors.redAccent,
              textColor: Colors.redAccent,
              isLogout: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.white70,
    Color textColor = Colors.white,
    bool isLogout = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: Colors.white.withOpacity(0.05),
          highlightColor: Colors.white.withOpacity(0.1),
          splashColor: Colors.white.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: isLogout
                ? BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
                  )
                : null,
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: isLogout ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
