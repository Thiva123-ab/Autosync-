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
                  return const Text('User Card Placeholder'); // To be replaced in Step 4
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
