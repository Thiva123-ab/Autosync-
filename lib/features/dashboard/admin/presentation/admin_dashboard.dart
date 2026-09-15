import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import '../../../../core/presentation/widgets/staff_drawer.dart';
import '../../../../core/presentation/widgets/theme_toggle_button.dart';
import '../../../../core/models/job_model.dart';
import 'job_board_page.dart';
import 'inventory_page.dart';
import 'users_page.dart';

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

final adminCompletedJobsListProvider = StreamProvider.autoDispose<List<JobModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('jobs')
      .where('status', isEqualTo: 'completed')
      .snapshots()
      .map((s) => s.docs.map((d) => JobModel.fromMap(d.id, d.data())).toList());
});

final adminAllUsersListProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

final adminStaffListProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'mechanic')
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

final adminCustomerListProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'customer')
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

final adminRecentJobsProvider = StreamProvider.autoDispose<List<JobModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('jobs')
      .orderBy('scheduledTime', descending: true)
      .limit(5)
      .snapshots()
      .map((s) => s.docs.map((d) => JobModel.fromMap(d.id, d.data())).toList());
});

final adminRecentCustomersProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'customer')
      .limit(5)
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

class AdminDashboard extends ConsumerStatefulWidget {
  final String title;
  const AdminDashboard({super.key, required this.title});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget currentBody;
    switch (_currentIndex) {
      case 0:
        currentBody = _buildOverview(ref, theme, isDark);
        break;
      case 1:
        currentBody = const JobBoardPage();
        break;
      case 2:
        currentBody = const UsersPage();
        break;
      case 3:
        currentBody = const InventoryPage();
        break;
      default:
        currentBody = _buildOverview(ref, theme, isDark);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1, color: theme.colorScheme.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(child: ThemeToggleButton()),
          )
        ],
      ),
      drawer: const StaffDrawer(currentRole: 'Admin'),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
                ? [const Color(0xFF0F0F1A), const Color(0xFF1A1A2E)] 
                : [const Color(0xFFF5F7FA), const Color(0xFFE4E9F2)],
          ),
        ),
        child: SafeArea(
          child: currentBody,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.colorScheme.surface,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Overview'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Jobs'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Inventory'),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview(WidgetRef ref, ThemeData theme, bool isDark) {
    final usersCount = ref.watch(adminUsersCountProvider);
    final activeJobsCount = ref.watch(adminActiveJobsCountProvider);
    final completedJobsCount = ref.watch(adminCompletedJobsCountProvider);
    
    final recentJobs = ref.watch(adminRecentJobsProvider);
    final recentCustomers = ref.watch(adminRecentCustomersProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
          ).animate().fade().slideX(),
          const SizedBox(height: 20),
          
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildPremiumStatCard(
                'Total Users',
                usersCount.when(data: (val) => val.toString(), loading: () => '...', error: (_, __) => '!'),
                Icons.people_alt,
                const Color(0xFF00C6FF),
                0,
                theme,
                isDark
              ),
              _buildPremiumStatCard(
                'Active Bookings',
                activeJobsCount.when(data: (val) => val.toString(), loading: () => '...', error: (_, __) => '!'),
                Icons.calendar_today_rounded,
                const Color(0xFFFF9100),
                1,
                theme,
                isDark
              ),
              _buildPremiumStatCard(
                'Completed Jobs',
                completedJobsCount.when(data: (val) => val.toString(), loading: () => '...', error: (_, __) => '!'),
                Icons.check_circle_outline,
                const Color(0xFF00E676),
                2,
                theme,
                isDark
              ),
              _buildPremiumStatCard(
                'Est. Revenue',
                ref.watch(adminCompletedJobsListProvider).when(
                  data: (jobs) {
                    final revenue = jobs.fold<double>(0, (sum, job) => sum + (job.quoteAmount ?? 150.0));
                    return '\$${revenue.toStringAsFixed(0)}';
                  },
                  loading: () => '...',
                  error: (_, __) => '!'
                ),
                Icons.attach_money_rounded,
                const Color(0xFFFF4081),
                3,
                theme,
                isDark
              ),
            ],
          ),

          const SizedBox(height: 32),
          
          _buildSectionHeader('Recent Bookings', Icons.history, theme).animate().fade(delay: 400.ms),
          const SizedBox(height: 16),
          recentJobs.when(
            data: (jobs) => jobs.isEmpty 
              ? _buildEmptyState('No recent bookings found.', theme, isDark)
              : Column(children: jobs.asMap().entries.map((entry) => _buildJobCard(entry.value, entry.key, theme, isDark)).toList()),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Error loading jobs: $err', style: TextStyle(color: theme.colorScheme.error)),
          ),

          const SizedBox(height: 32),

          _buildSectionHeader('New Customers', Icons.person_add_alt_1, theme).animate().fade(delay: 500.ms),
          const SizedBox(height: 16),
          recentCustomers.when(
            data: (customers) => customers.isEmpty 
              ? _buildEmptyState('No new customers found.', theme, isDark)
              : SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: customers.length,
                    itemBuilder: (context, index) => _buildCustomerCard(customers[index], index, theme, isDark),
                  ),
                ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Error loading customers: $err', style: TextStyle(color: theme.colorScheme.error)),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontStyle: FontStyle.italic),
        ),
      ),
    ).animate().fade();
  }

  Widget _buildJobCard(JobModel job, int index, ThemeData theme, bool isDark) {
    Color statusColor;
    switch (job.status.toLowerCase()) {
      case 'completed': statusColor = const Color(0xFF00E676); break;
      case 'in_progress': statusColor = const Color(0xFFFF9100); break;
      default: statusColor = const Color(0xFF00C6FF);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.05)),
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.6),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.15) : Colors.black.withOpacity(0.03), 
            blurRadius: 10, offset: const Offset(0, 4)
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.build_circle_outlined, color: statusColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface)),
                      const SizedBox(height: 4),
                      Text(job.vehicleInfo, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, fontSize: 13)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 12, color: isDark ? Colors.grey.shade500 : Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM d, h:mm a').format(job.scheduledTime),
                            style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    job.status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade(delay: (200 + (50 * index)).ms).slideX(begin: 0.1, curve: Curves.easeOutQuad);
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer, int index, ThemeData theme, bool isDark) {
    final name = customer['name'] ?? 'Unknown';
    final email = customer['email'] ?? 'No email';
    final initial = name.toString().isNotEmpty ? name.toString()[0].toUpperCase() : '?';

    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.05)),
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.6),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.15) : Colors.black.withOpacity(0.03), 
            blurRadius: 10, offset: const Offset(0, 4)
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                  child: Text(initial, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade(delay: (400 + (50 * index)).ms).slideY(begin: 0.2, curve: Curves.easeOutQuad);
  }

  Widget _buildPremiumStatCard(String title, String value, IconData icon, Color color, int index, ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.05),
        ),
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.6),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.15) : Colors.black.withOpacity(0.03), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          ),
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
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade(delay: (100 * index).ms).slideY(begin: 0.2);
  }
}
