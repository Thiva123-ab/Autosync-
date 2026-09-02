import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'admin_dashboard.dart';

class StaffRosterPage extends ConsumerWidget {
  const StaffRosterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsyncValue = ref.watch(adminStaffListProvider);
    final completedJobsAsyncValue = ref.watch(adminCompletedJobsListProvider);

    return staffAsyncValue.when(
      data: (staffList) {
        if (staffList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.engineering_outlined, size: 80, color: Colors.white.withOpacity(0.2)),
                const SizedBox(height: 16),
                Text('No staff members found.', style: TextStyle(color: Colors.grey.shade400, fontSize: 18)),
              ],
            ).animate().fade().scale(curve: Curves.easeOutBack),
          );
        }

        return completedJobsAsyncValue.when(
          data: (completedJobs) {
            return ListView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: staffList.length,
              itemBuilder: (context, index) {
                final staff = staffList[index];
                
                // Calculate metrics
                final mechanicJobs = completedJobs.where((j) => j.assignedMechanicId == staff['id']).toList();
                final completedCount = mechanicJobs.length;
                
                return _buildPremiumStaffCard(staff, completedCount, index);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00E676))),
          error: (error, stack) => Center(child: Text('Error loading metrics: $error', style: const TextStyle(color: Colors.redAccent))),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00C6FF))),
      error: (error, stack) => Center(child: Text('Error loading staff: $error', style: const TextStyle(color: Colors.redAccent))),
    );
  }

  Widget _buildPremiumStaffCard(Map<String, dynamic> staff, int completedCount, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        color: Colors.white.withOpacity(0.05),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C6FF).withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF00C6FF).withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.engineering, size: 30, color: Color(0xFF00C6FF)),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(staff['email'] ?? 'Unknown Staff', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('Role: ${(staff['role'] as String? ?? 'N/A').toUpperCase()}', style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.0)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF00E676)),
                          const SizedBox(width: 6),
                          Text(
                            '$completedCount Jobs Completed',
                            style: const TextStyle(color: Color(0xFF00E676), fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade(delay: (100 * index).ms).slideY(begin: 0.1);
  }
}
