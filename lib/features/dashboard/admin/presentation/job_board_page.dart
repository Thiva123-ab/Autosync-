import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../shared/job_repository.dart';
import '../../../../core/models/job_model.dart';

final adminAllActiveJobsProvider = StreamProvider.autoDispose<List<JobModel>>((ref) {
  return ref.watch(jobRepositoryProvider).getAllActiveJobs();
});

class JobBoardPage extends ConsumerWidget {
  const JobBoardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsyncValue = ref.watch(adminAllActiveJobsProvider);

    return jobsAsyncValue.when(
      data: (jobs) {
        if (jobs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_turned_in, size: 80, color: Colors.white.withOpacity(0.2)),
                const SizedBox(height: 16),
                Text('No active jobs in the system.', style: TextStyle(color: Colors.grey.shade400, fontSize: 18)),
              ],
            ).animate().fade().scale(curve: Curves.easeOutBack),
          );
        }

        // Group jobs by status
        final pendingJobs = jobs.where((j) => j.status == 'pending').toList();
        final inProgressJobs = jobs.where((j) => j.status == 'in_progress').toList();

        return ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            if (pendingJobs.isNotEmpty) ...[
              const Text('Queued Jobs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              ...pendingJobs.map((job) => _buildAdminJobCard(context, ref, job, Colors.redAccent)),
              const SizedBox(height: 24),
            ],
            if (inProgressJobs.isNotEmpty) ...[
              const Text('In Progress', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              ...inProgressJobs.map((job) => _buildAdminJobCard(context, ref, job, Colors.orange)),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00C6FF))),
      error: (error, stack) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.redAccent))),
    );
  }

  Widget _buildAdminJobCard(BuildContext context, WidgetRef ref, JobModel job, Color statusColor) {
    final hasMechanic = job.assignedMechanicId != null && job.assignedMechanicId!.isNotEmpty;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(job.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(job.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(job.vehicleInfo, style: TextStyle(color: Colors.grey.shade300, fontSize: 14)),
                if (job.description != null && job.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Notes: ${job.description}', style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontStyle: FontStyle.italic)),
                ],
                const SizedBox(height: 16),
                const Divider(color: Colors.white12),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(hasMechanic ? Icons.engineering : Icons.person_add_alt_1, size: 16, color: hasMechanic ? Colors.greenAccent : Colors.redAccent),
                        const SizedBox(width: 8),
                        Text(
                          hasMechanic ? 'Mechanic Assigned' : 'Unassigned',
                          style: TextStyle(color: hasMechanic ? Colors.greenAccent : Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => _showAssignMechanicDialog(context, ref, job),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C6FF),
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('ASSIGN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade().slideY(begin: 0.1);
  }

  void _showAssignMechanicDialog(BuildContext context, WidgetRef ref, JobModel job) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final mechanics = await ref.read(jobRepositoryProvider).getAvailableMechanics();
      Navigator.pop(context); // Close loading dialog

      if (mechanics.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No mechanics found!')));
        return;
      }

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text('Assign Mechanic', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: mechanics.length,
              itemBuilder: (ctx, idx) {
                final mechanic = mechanics[idx];
                final isCurrentlyAssigned = mechanic['id'] == job.assignedMechanicId;
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCurrentlyAssigned ? Colors.green : Colors.blueGrey,
                    child: const Icon(Icons.engineering, color: Colors.white),
                  ),
                  title: Text(mechanic['email'] ?? 'Unknown', style: const TextStyle(color: Colors.white)),
                  subtitle: Text(isCurrentlyAssigned ? 'Currently Assigned' : 'Available', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                  trailing: isCurrentlyAssigned ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () async {
                    Navigator.pop(ctx);
                    await ref.read(jobRepositoryProvider).assignMechanicToJob(job.id, mechanic['id']);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Assigned to ${mechanic['email']}')));
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
