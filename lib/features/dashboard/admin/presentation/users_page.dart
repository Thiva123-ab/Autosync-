import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'admin_dashboard.dart';

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final usersAsync = ref.watch(adminAllUsersListProvider);

    return Column(
      children: [
        const SizedBox(height: 100), // SafeArea + AppBar space
        _buildSegmentedControl(theme, isDark),
        Expanded(
          child: usersAsync.when(
            data: (users) {
              final filtered = users.where((u) {
                if (_filter == 'All') return true;
                final role = u['role']?.toString().toLowerCase() ?? 'customer';
                if (_filter == 'Mechanics') return role == 'mechanic';
                if (_filter == 'Admins') return role == 'admin';
                return role == 'customer';
              }).toList();

              if (filtered.isEmpty) {
                return const Center(child: Text('No users found.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final user = filtered[index];
                  return _buildUserCard(user, index, theme, isDark);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, int index, ThemeData theme, bool isDark) {
    final name = user['name'] ?? 'Unknown User';
    final email = user['email'] ?? 'No Email';
    final role = user['role']?.toString().toUpperCase() ?? 'CUSTOMER';
    final initial = name.toString().isNotEmpty ? name.toString()[0].toUpperCase() : '?';
    
    IconData roleIcon;
    Color roleColor;
    if (role == 'ADMIN') {
      roleIcon = Icons.admin_panel_settings;
      roleColor = const Color(0xFFFF4081);
    } else if (role == 'MECHANIC') {
      roleIcon = Icons.engineering;
      roleColor = const Color(0xFF00E676);
    } else {
      roleIcon = Icons.person;
      roleColor = const Color(0xFF00C6FF);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.05)),
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.6),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: roleColor.withValues(alpha: 0.2),
                  child: Text(initial, style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                      const SizedBox(height: 4),
                      Text(email, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: roleColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(roleIcon, size: 14, color: roleColor),
                      const SizedBox(width: 4),
                      Text(role, style: TextStyle(color: roleColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Action menu placeholder
                Icon(Icons.more_vert, color: isDark ? Colors.white54 : Colors.black54),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade(delay: (50 * index).ms).slideY(begin: 0.1);
  }


  Widget _buildSegmentedControl(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: ['All', 'Customers', 'Mechanics', 'Admins'].map((f) {
            final isSelected = _filter == f;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    f,
                    style: TextStyle(
                      color: isSelected ? theme.colorScheme.onPrimary : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
