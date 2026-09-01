import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/staff_drawer.dart';
import '../../shared/job_repository.dart';
import '../../../../core/models/job_model.dart';

final advisorJobsProvider = StreamProvider.autoDispose<List<JobModel>>((ref) {
  return ref.watch(jobRepositoryProvider).getAllActiveJobs();
});

class AdvisorDashboard extends ConsumerWidget {
  final String title;

  const AdvisorDashboard({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsyncValue = ref.watch(advisorJobsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
      ),
      drawer: const StaffDrawer(currentRole: 'Service Advisor'),
      body: jobsAsyncValue.when(
        data: (jobs) {
          if (jobs.isEmpty) {
            return const Center(child: Text('No active appointments.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return _buildAppointmentCard(context, job, ref);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Logic to create a new appointment
        },
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, JobModel job, WidgetRef ref) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: Colors.indigo,
          child: Icon(Icons.calendar_month, color: Colors.white),
        ),
        title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Vehicle: ${job.vehicleInfo}'),
            Text('Status: ${job.status}'),
            const SizedBox(height: 4),
            Text(
              'Time: ${job.scheduledTime.toString().substring(0, 16)}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: job.assignedMechanicId == null || job.assignedMechanicId!.isEmpty
            ? OutlinedButton(
                onPressed: () {
                  // Dialog to assign a mechanic
                },
                child: const Text('Assign'),
              )
            : Chip(
                label: const Text('Assigned'),
                backgroundColor: Colors.green.shade100,
              ),
      ),
    );
  }
}
