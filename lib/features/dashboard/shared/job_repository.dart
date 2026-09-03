import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/job_model.dart';

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepository(FirebaseFirestore.instance);
});

class JobRepository {
  final FirebaseFirestore _firestore;

  JobRepository(this._firestore);

  Stream<List<JobModel>> getAssignedJobs(String mechanicId) {
    return _firestore
        .collection('jobs')
        .where('assignedMechanicId', isEqualTo: mechanicId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs
                .map((doc) => JobModel.fromMap(doc.id, doc.data()))
                .where((job) => job.status != 'completed')
                .toList());
  }

  Stream<List<JobModel>> getAllActiveJobs() {
    return _firestore
        .collection('jobs')
        .where('status', isNotEqualTo: 'completed')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => JobModel.fromMap(doc.id, doc.data())).toList());
  }

  Stream<List<JobModel>> getCustomerJobs(String customerId) {
    return _firestore
        .collection('jobs')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => JobModel.fromMap(doc.id, doc.data())).toList());
  }

  Future<List<Map<String, dynamic>>> getAvailableMechanics() async {
    final snapshot = await _firestore.collection('users').where('role', isEqualTo: 'mechanic').get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  Future<void> assignMechanicToJob(String jobId, String mechanicId) async {
    await _firestore.collection('jobs').doc(jobId).update({
      'assignedMechanicId': mechanicId,
      'status': 'pending', // Reset to pending if assigned
    });
  }

  Future<void> createJob(JobModel job, String customerId) async {
    final data = job.toMap();
    data['customerId'] = customerId;
    await _firestore.collection('jobs').add(data);
  }

  Future<void> updateJobStatus(String jobId, String status) async {
    await _firestore.collection('jobs').doc(jobId).update({'status': status});
  }
  Future<void> updateMechanicNotes(String jobId, String notes) async {
    await _firestore.collection('jobs').doc(jobId).update({'mechanicNotes': notes});
  }

  Future<void> requestJobParts(String jobId, List<String> currentParts, String newPart) async {
    final updatedParts = List<String>.from(currentParts)..add(newPart);
    await _firestore.collection('jobs').doc(jobId).update({'requestedParts': updatedParts});
  }
}
