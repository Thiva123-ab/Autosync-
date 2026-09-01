import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../dashboard/shared/job_repository.dart';
import '../../../core/models/job_model.dart';
import '../../../core/routing/route_names.dart';
import 'package:go_router/go_router.dart';

final customerJobsProvider = StreamProvider.autoDispose<List<JobModel>>((ref) {
  final customerId = FirebaseAuth.instance.currentUser?.uid;
  if (customerId == null) return const Stream.empty();
  return ref.watch(jobRepositoryProvider).getCustomerJobs(customerId);
});

class CustomerHomePage extends ConsumerWidget {
  final String title;

  const CustomerHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsyncValue = ref.watch(customerJobsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              context.pushNamed(RouteNames.chatbot);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: jobsAsyncValue.when(
        data: (jobs) {
          if (jobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No current bookings.', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pushNamed(RouteNames.booking),
                    child: const Text('Book a Service'),
                  )
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return _buildBookingCard(job);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(RouteNames.booking),
        icon: const Icon(Icons.add),
        label: const Text('Book Service'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildBookingCard(JobModel job) {
    Color statusColor;
    switch (job.status) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'in_progress':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Vehicle: ${job.vehicleInfo}'),
            const SizedBox(height: 4),
            Text('Scheduled: ${job.scheduledTime.toString().substring(0, 16)}'),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.circle, size: 12, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  job.status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
