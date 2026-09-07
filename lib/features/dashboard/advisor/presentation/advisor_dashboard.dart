import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/presentation/widgets/staff_drawer.dart';
import '../../shared/job_repository.dart';
import '../../../../core/models/job_model.dart';
import 'package:uuid/uuid.dart';

final advisorJobsProvider = StreamProvider.autoDispose<List<JobModel>>((ref) {
  return ref.watch(jobRepositoryProvider).getAllActiveJobs();
});

class AdvisorDashboard extends ConsumerStatefulWidget {
  final String title;
  const AdvisorDashboard({super.key, required this.title});

  @override
  ConsumerState<AdvisorDashboard> createState() => _AdvisorDashboardState();
}

class _AdvisorDashboardState extends ConsumerState<AdvisorDashboard> {
  void _showNewJobIntakeDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final vehicleController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('New Vehicle Intake', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(titleController, 'Brief Issue Title (e.g. Brake Pad Replacement)', Icons.build),
                const SizedBox(height: 16),
                _buildTextField(vehicleController, 'Vehicle (e.g. 2021 Toyota Corolla - ABC-1234)', Icons.directions_car),
                const SizedBox(height: 16),
                _buildTextField(descriptionController, 'Customer Notes / Description', Icons.notes, maxLines: 3),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                if (titleController.text.trim().isEmpty || vehicleController.text.trim().isEmpty) return;
                setState(() => isLoading = true);
                
                final newJob = JobModel(
                  id: const Uuid().v4(),
                  customerId: 'walk_in_customer', // Fallback for now
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  status: 'Pending',
                  scheduledTime: DateTime.now(),
                  vehicleInfo: vehicleController.text.trim(),
                );
                
                try {
                  await ref.read(jobRepositoryProvider).createJob(newJob);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job Intake Complete'), backgroundColor: Colors.green));
                  }
                } catch (e) {
                  setState(() => isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent.shade400,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : const Text('Create Job Card', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.tealAccent),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(advisorJobsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const StaffDrawer(currentRole: 'Service Advisor'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: jobsAsync.when(
            data: (jobs) {
              if (jobs.isEmpty) {
                return const Center(child: Text('No active jobs in the shop.', style: TextStyle(color: Colors.white54, fontSize: 18)));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: jobs.length,
                itemBuilder: (context, index) {
                  return AdvisorJobCard(job: jobs[index]).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.1, end: 0);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Colors.tealAccent)),
            error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewJobIntakeDialog,
        backgroundColor: Colors.tealAccent.shade400,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('New Intake', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ).animate().scale(delay: 500.ms),
    );
  }
}

class AdvisorJobCard extends ConsumerWidget {
  final JobModel job;
  const AdvisorJobCard({super.key, required this.job});

  Color _getStatusColor() {
    switch (job.status.toLowerCase()) {
      case 'in progress': return Colors.orange;
      case 'completed': return Colors.greenAccent;
      default: return Colors.blueAccent;
    }
  }

  void _showQuoteDialog(BuildContext context, WidgetRef ref) {
    final quoteController = TextEditingController(text: job.quoteAmount?.toString() ?? '');
    bool isLoading = false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Generate Quote', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: quoteController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter amount (Rs)',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.attach_money, color: Colors.tealAccent),
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                final amount = double.tryParse(quoteController.text.trim());
                if (amount == null) return;
                setState(() => isLoading = true);
                await ref.read(jobRepositoryProvider).updateJobQuote(job.id, amount);
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent.shade400, foregroundColor: Colors.black),
              child: isLoading ? const SizedBox(width:20, height:20, child: CircularProgressIndicator(color: Colors.black)) : const Text('Send Quote'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignDialog(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Assign Mechanic', style: TextStyle(color: Colors.white)),
        content: FutureBuilder<List<Map<String, dynamic>>>(
          future: ref.read(jobRepositoryProvider).getAvailableMechanics(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
            final mechanics = snapshot.data!;
            if (mechanics.isEmpty) return const Text('No mechanics available', style: TextStyle(color: Colors.white54));
            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: mechanics.length,
                itemBuilder: (context, index) {
                  final mech = mechanics[index];
                  return ListTile(
                    leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.person, color: Colors.white)),
                    title: Text(mech['email'] ?? 'Unknown', style: const TextStyle(color: Colors.white)),
                    onTap: () async {
                      await ref.read(jobRepositoryProvider).assignJob(job.id, mech['id']);
                      if (context.mounted) Navigator.pop(context);
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(job.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: _getStatusColor().withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: _getStatusColor().withOpacity(0.5))),
                      child: Text(job.status, style: TextStyle(color: _getStatusColor(), fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.directions_car, color: Colors.white54, size: 16),
                    const SizedBox(width: 8),
                    Text(job.vehicleInfo, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
                if (job.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(job.description, style: const TextStyle(color: Colors.white54, fontSize: 13, fontStyle: FontStyle.italic)),
                ],
                const SizedBox(height: 16),
                Divider(color: Colors.white.withOpacity(0.1)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.person_add,
                      label: job.assignedMechanicId != null ? 'Reassign' : 'Assign',
                      color: job.assignedMechanicId != null ? Colors.white54 : Colors.tealAccent,
                      onTap: () => _showAssignDialog(context, ref),
                    ),
                    _buildActionButton(
                      icon: Icons.request_quote,
                      label: job.quoteAmount != null ? 'Rs ${job.quoteAmount}' : 'Quote',
                      color: job.customerApproved == true ? Colors.greenAccent : Colors.amberAccent,
                      onTap: () => _showQuoteDialog(context, ref),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
