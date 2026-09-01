import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/package:firebase_auth.dart';
import '../../../../core/presentation/widgets/staff_drawer.dart';
import '../../shared/job_repository.dart';
import '../../../../core/models/job_model.dart';

final mechanicJobsProvider = StreamProvider.autoDispose<List<JobModel>>((ref) {
  final mechanicId = FirebaseAuth.instance.currentUser?.uid;
  if (mechanicId == null) return const Stream.empty();
  return ref.watch(jobRepositoryProvider).getAssignedJobs(mechanicId);
});

class MechanicDashboard extends ConsumerWidget {
  final String title;

  const MechanicDashboard({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsyncValue = ref.watch(mechanicJobsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      drawer: const StaffDrawer(currentRole: 'Mechanic'),
      body: jobsAsyncValue.when(
        data: (jobs) {
          if (jobs.isEmpty) {
            return const Center(child: Text('No assigned jobs currently.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return _buildJobCard(job, ref);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildJobCard(JobModel job, WidgetRef ref) {
    final statusColor = job.status == 'in_progress' ? Colors.orange : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(Icons.build, color: statusColor),
        ),
        title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(job.vehicleInfo),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${job.scheduledTime.hour}:${job.scheduledTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            // Update status logic
            ref.read(jobRepositoryProvider).updateJobStatus(
                job.id, job.status == 'pending' ? 'in_progress' : 'completed');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: statusColor,
            foregroundColor: Colors.white,
          ),
          child: Text(job.status == 'pending' ? 'Start' : 'Complete'),
        ),
      ),
    );
  }
}
