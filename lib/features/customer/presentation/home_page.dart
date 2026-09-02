import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

import '../../dashboard/shared/job_repository.dart';
import '../../../core/models/job_model.dart';
import '../../../core/routing/route_names.dart';

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
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              backgroundColor: Colors.black.withOpacity(0.3),
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  color: const Color(0xFF00C6FF),
                  onPressed: () => context.pushNamed(RouteNames.chatbot),
                ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.easeOutBack),
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  color: Colors.white70,
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
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
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.withOpacity(0.1),
                        ),
                        child: Icon(Icons.directions_car_outlined, size: 80, color: const Color(0xFF00C6FF)),
                      ).animate().fade(duration: 600.ms).scale(curve: Curves.easeOutBack),
                      const SizedBox(height: 24),
                      const Text(
                        'No upcoming services',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ).animate().fade(delay: 200.ms),
                      const SizedBox(height: 8),
                      Text(
                        'Your vehicle is all caught up!',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
                      ).animate().fade(delay: 300.ms),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
                itemCount: jobs.length,
                itemBuilder: (context, index) {
                  final job = jobs[index];
                  return _buildPremiumCard(job, index);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00C6FF))),
            error: (error, stack) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.redAccent))),
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00C6FF).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => context.pushNamed(RouteNames.booking),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Book Service', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ).animate(onPlay: (controller) => controller.repeat(reverse: true)).shimmer(duration: 2.seconds, color: Colors.white24),
    );
  }

  Widget _buildPremiumCard(JobModel job, int index) {
    Color statusColor;
    switch (job.status) {
      case 'completed':
        statusColor = const Color(0xFF00E676);
        break;
      case 'in_progress':
        statusColor = const Color(0xFFFF9100);
        break;
      default:
        statusColor = const Color(0xFF00C6FF);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.02),
          ],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
        ],
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
                  child: Icon(Icons.build_circle_outlined, color: statusColor, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                      const SizedBox(height: 6),
                      Text(job.vehicleInfo, style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            job.scheduledTime.toString().substring(0, 16),
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor)),
                      const SizedBox(width: 6),
                      Text(
                        job.status.toUpperCase(),
                        style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade(duration: 400.ms, delay: (index * 100).ms).slideX(begin: 0.1, curve: Curves.easeOutQuad);
  }
}
