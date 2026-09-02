import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../../../core/presentation/widgets/staff_drawer.dart';
import '../../shared/job_repository.dart';
import '../../../../core/models/job_model.dart';
import '../../../auth/providers/auth_provider.dart';

final mechanicJobsProvider = StreamProvider.autoDispose<List<JobModel>>((ref) {
  final mechanicId = ref.watch(authStateProvider).value?.uid;
  if (mechanicId == null) return Stream.value([]);
  return ref.watch(jobRepositoryProvider).getAssignedJobs(mechanicId);
});

class MechanicDashboard extends ConsumerWidget {
  final String title;

  const MechanicDashboard({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsyncValue = ref.watch(mechanicJobsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      drawer: const StaffDrawer(currentRole: 'Mechanic'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0F1A), Color(0xFF1A1A2E)],
          ),
        ),
        child: SafeArea(
          child: jobsAsyncValue.when(
            data: (jobs) {
              if (jobs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 80, color: Colors.white.withOpacity(0.2)),
                      const SizedBox(height: 16),
                      Text('No assigned jobs currently.', style: TextStyle(color: Colors.grey.shade400, fontSize: 18)),
                    ],
                  ).animate().fade().scale(curve: Curves.easeOutBack),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(20.0),
                itemCount: jobs.length,
                itemBuilder: (context, index) {
                  final job = jobs[index];
                  return _buildPremiumJobCard(job, ref, index);
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF00C6FF)),
            ),
            error: (error, stack) => Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: Text('Error: $error', style: const TextStyle(color: Colors.redAccent)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumJobCard(JobModel job, WidgetRef ref, int index) {
    final isPending = job.status == 'pending';
    final statusColor = isPending ? const Color(0xFF00C6FF) : const Color(0xFFFF9100);
    final statusText = isPending ? 'START JOB' : 'COMPLETE';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        color: Colors.white.withOpacity(0.05),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        job.title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isPending ? Icons.build_circle : Icons.handyman, size: 14, color: statusColor),
                          const SizedBox(width: 6),
                          Text(
                            job.status.toUpperCase(),
                            style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(job.vehicleInfo, style: TextStyle(color: Colors.grey.shade300, fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_month, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    Text(
                      '${job.scheduledTime.year}-${job.scheduledTime.month.toString().padLeft(2, '0')}-${job.scheduledTime.day.toString().padLeft(2, '0')} at ${job.scheduledTime.hour}:${job.scheduledTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(jobRepositoryProvider).updateJobStatus(
                        job.id, 
                        isPending ? 'in_progress' : 'completed',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: statusColor,
                      foregroundColor: isPending ? Colors.black87 : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    child: Text(
                      statusText, 
                      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade(delay: (100 * index).ms).slideY(begin: 0.2);
  }
}
