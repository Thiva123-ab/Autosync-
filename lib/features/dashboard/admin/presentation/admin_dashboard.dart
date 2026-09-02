import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../../../core/presentation/widgets/staff_drawer.dart';

final adminUsersCountProvider = StreamProvider.autoDispose<int>((ref) {
  return FirebaseFirestore.instance.collection('users').snapshots().map((s) => s.docs.length);
});

final adminActiveJobsCountProvider = StreamProvider.autoDispose<int>((ref) {
  return FirebaseFirestore.instance
      .collection('jobs')
      .where('status', isNotEqualTo: 'completed')
      .snapshots()
      .map((s) => s.docs.length);
});

final adminCompletedJobsCountProvider = StreamProvider.autoDispose<int>((ref) {
  return FirebaseFirestore.instance
      .collection('jobs')
      .where('status', isEqualTo: 'completed')
      .snapshots()
      .map((s) => s.docs.length);
});

class AdminDashboard extends ConsumerWidget {
  final String title;

  const AdminDashboard({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersCount = ref.watch(adminUsersCountProvider);
    final activeJobsCount = ref.watch(adminActiveJobsCountProvider);
    final completedJobsCount = ref.watch(adminCompletedJobsCountProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      drawer: const StaffDrawer(currentRole: 'Admin'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0F1A), Color(0xFF1A1A2E)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Overview',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ).animate().fade().slideX(),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildPremiumStatCard(
                        'Total Users',
                        usersCount.when(
                          data: (val) => val.toString(),
                          loading: () => '...',
                          error: (_, __) => '!',
                        ),
                        Icons.people_alt,
                        const Color(0xFF00C6FF),
                        0,
                      ),
                      _buildPremiumStatCard(
                        'Active Bookings',
                        activeJobsCount.when(
                          data: (val) => val.toString(),
                          loading: () => '...',
                          error: (_, __) => '!',
                        ),
                        Icons.calendar_today_rounded,
                        const Color(0xFFFF9100),
                        1,
                      ),
                      _buildPremiumStatCard(
                        'Completed Jobs',
                        completedJobsCount.when(
                          data: (val) => val.toString(),
                          loading: () => '...',
                          error: (_, __) => '!',
                        ),
                        Icons.check_circle_outline,
                        const Color(0xFF00E676),
                        2,
                      ),
                      _buildPremiumStatCard(
                        'Est. Revenue',
                        completedJobsCount.when(
                          data: (val) => '\$${(val * 150).toStringAsFixed(0)}', // Mock calculation based on $150/job
                          loading: () => '...',
                          error: (_, __) => '!',
                        ),
                        Icons.attach_money_rounded,
                        const Color(0xFFFF4081),
                        3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumStatCard(String title, String value, IconData icon, Color color, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        color: Colors.white.withOpacity(0.05),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 36, color: color),
                ),
                const SizedBox(height: 16),
                Text(
                  value,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade(delay: (100 * index).ms).slideY(begin: 0.2);
  }
}
