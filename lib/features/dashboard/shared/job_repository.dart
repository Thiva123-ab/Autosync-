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
        .where('status', isNotEqualTo: 'completed')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => JobModel.fromMap(doc.id, doc.data())).toList());
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

  Future<void> createJob(JobModel job, String customerId) async {
    final data = job.toMap();
    data['customerId'] = customerId;
    await _firestore.collection('jobs').add(data);
  }

  Future<void> updateJobStatus(String jobId, String status) async {
    await _firestore.collection('jobs').doc(jobId).update({'status': status});
  }
}
