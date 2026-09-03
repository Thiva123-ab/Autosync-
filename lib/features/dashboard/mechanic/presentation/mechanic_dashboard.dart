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
              final activeJobs = jobs.where((j) => j.status != 'completed').toList();
              
              if (activeJobs.isEmpty) {
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
                itemCount: activeJobs.length,
                itemBuilder: (context, index) {
                  final job = activeJobs[index];
                  return JobCard(job: job, index: index);
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
}

class JobCard extends ConsumerWidget {
  final JobModel job;
  final int index;

  const JobCard({super.key, required this.job, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending = job.status == 'pending';
    final isInProgress = job.status == 'in_progress';
    final statusColor = isPending 
        ? const Color(0xFF00C6FF) 
        : isInProgress ? const Color(0xFFFF9100) : const Color(0xFF00E676);
    
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
                // Header: Vehicle & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        job.vehicleInfo,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPending ? Icons.build_circle : (isInProgress ? Icons.timelapse : Icons.check_circle),
                            size: 14, 
                            color: statusColor
                          ),
                          const SizedBox(width: 4),
                          Text(
                            job.status.toUpperCase().replaceAll('_', ' '),
                            style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Title and Description
                Text(job.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  job.description != null && job.description!.isNotEmpty 
                      ? job.description! 
                      : 'No issue description provided.',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white12),
                const SizedBox(height: 8),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(
                      icon: isInProgress ? Icons.pause_circle_outline : Icons.play_circle_outline, 
                      label: isInProgress ? 'Pause' : 'Start', 
                      color: const Color(0xFF00C6FF),
                      onPressed: () {
                         ref.read(jobRepositoryProvider).updateJobStatus(
                           job.id, 
                           isInProgress ? 'pending' : 'in_progress',
                         );
                      }
                    ),
                    _buildActionButton(
                      icon: Icons.note_add_outlined, 
                      label: 'Notes', 
                      color: const Color(0xFFFF9100),
                      onPressed: () {
                        _showNotesDialog(context, ref, job);
                      }
                    ),
                    _buildActionButton(
                      icon: Icons.inventory_2_outlined, 
                      label: 'Parts', 
                      color: const Color(0xFFE040FB),
                      onPressed: () {
                        _showPartsDialog(context, ref, job);
                      }
                    ),
                    if (isInProgress)
                      _buildActionButton(
                        icon: Icons.check_circle_outline, 
                        label: 'Finish', 
                        color: const Color(0xFF00E676),
                        onPressed: () {
                          ref.read(jobRepositoryProvider).updateJobStatus(job.id, 'completed');
                        }
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade(delay: (100 * index).ms).slideY(begin: 0.2);
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.grey.shade300, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  void _showNotesDialog(BuildContext context, WidgetRef ref, JobModel job) {
    final noteCtrl = TextEditingController(text: job.mechanicNotes ?? '');
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Add Digital Inspection Note', style: TextStyle(color: Colors.white, fontSize: 18)),
        content: TextField(
          controller: noteCtrl,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Type technical notes or document pre-existing damage...',
            hintStyle: TextStyle(color: Colors.grey.shade600),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFFF9100))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (noteCtrl.text.isNotEmpty) {
                await ref.read(jobRepositoryProvider).updateMechanicNotes(job.id, noteCtrl.text.trim());
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: const Text('Notes saved to database!'), backgroundColor: Colors.green.shade800),
                  );
                }
              }
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('SAVE & UPLOAD'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9100), 
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showPartsDialog(BuildContext context, WidgetRef ref, JobModel job) {
    final partCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Request Parts', style: TextStyle(color: Colors.white, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A notification will be sent to the Admin/Inventory room to prepare parts for this vehicle.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: partCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. Brake Pads',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFE040FB))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (partCtrl.text.isNotEmpty) {
                await ref.read(jobRepositoryProvider).requestJobParts(job.id, job.requestedParts, partCtrl.text.trim());
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: const Text('Part requested from inventory!'), backgroundColor: Colors.purple.shade800),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE040FB), 
              foregroundColor: Colors.white,
            ),
            child: const Text('REQUEST'),
          ),
        ],
      ),
    );
  }
}
