import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'admin_dashboard.dart';
import '../../shared/job_repository.dart';

class CrmPage extends ConsumerWidget {
  const CrmPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsyncValue = ref.watch(adminCustomerListProvider);

    return customerAsyncValue.when(
      data: (customers) {
        if (customers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 80, color: Colors.white.withOpacity(0.2)),
                const SizedBox(height: 16),
                Text('No customers found in CRM.', style: TextStyle(color: Colors.grey.shade400, fontSize: 18)),
              ],
            ).animate().fade().scale(),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20.0),
          itemCount: customers.length,
          itemBuilder: (context, index) {
            final customer = customers[index];
            return _buildCustomerCard(context, ref, customer, index);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00C6FF))),
      error: (error, stack) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.redAccent))),
    );
  }

  Widget _buildCustomerCard(BuildContext context, WidgetRef ref, Map<String, dynamic> customer, int index) {
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
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF00C6FF).withOpacity(0.2),
                  child: const Icon(Icons.person, color: Color(0xFF00C6FF)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customer['email'] ?? 'Unknown Customer', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('Customer ID: ${customer['id'].toString().substring(0, 6)}...', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.history, color: Color(0xFF00E676)),
                  onPressed: () => _showServiceHistory(context, ref, customer['id'], customer['email'] ?? 'Customer'),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade(delay: (50 * index).ms).slideY(begin: 0.1);
  }

  void _showServiceHistory(BuildContext context, WidgetRef ref, String customerId, String email) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade600, borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Service History: $email', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder(
                  stream: ref.read(jobRepositoryProvider).getCustomerJobs(customerId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF00C6FF)));
                    }
                    if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                    
                    final jobs = snapshot.data ?? [];
                    if (jobs.isEmpty) {
                      return Center(child: Text('No service history found.', style: TextStyle(color: Colors.grey.shade400)));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: jobs.length,
                      itemBuilder: (ctx, index) {
                        final job = jobs[index];
                        final isApproved = job.customerApproved;
                        final hasQuote = job.quoteAmount != null;

                        return Card(
                          color: Colors.white.withOpacity(0.05),
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(job.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                    Text(job.status.toUpperCase(), style: TextStyle(color: job.status == 'completed' ? Colors.green : Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(job.vehicleInfo, style: TextStyle(color: Colors.grey.shade400)),
                                const SizedBox(height: 12),
                                const Divider(color: Colors.white12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    hasQuote 
                                      ? Text('Quote: \$${job.quoteAmount}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                                      : const Text('No quote set', style: TextStyle(color: Colors.grey)),
                                    if (hasQuote)
                                      Row(
                                        children: [
                                          Icon(isApproved ? Icons.check_circle : Icons.pending, size: 16, color: isApproved ? Colors.green : Colors.orange),
                                          const SizedBox(width: 4),
                                          Text(isApproved ? 'Approved' : 'Pending', style: TextStyle(color: isApproved ? Colors.green : Colors.orange, fontSize: 12)),
                                        ],
                                      ),
                                    if (!hasQuote)
                                      TextButton(
                                        onPressed: () => _setQuoteDialog(context, job.id),
                                        child: const Text('Add Quote', style: TextStyle(color: Color(0xFF00C6FF))),
                                      ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _setQuoteDialog(BuildContext context, String jobId) {
    final quoteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Set Quote Amount', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: quoteCtrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            prefixText: '\$ ',
            prefixStyle: TextStyle(color: Colors.white),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00C6FF))),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(quoteCtrl.text);
              if (amount != null) {
                await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({'quoteAmount': amount});
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C6FF), foregroundColor: Colors.black),
            child: const Text('SET QUOTE'),
          ),
        ],
      ),
    );
  }
}
