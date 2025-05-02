import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference jobsCollection = FirebaseFirestore.instance.collection('jobs');

  /// ✅ Add a new job to Firestore
  Future<String?> addJob(String title, String description, String userId) async {
    try {
      await jobsCollection.add({
        'title': title,
        'description': description,
        'postedBy': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }

  /// ✅ Fetch all job listings
  Stream<QuerySnapshot> getJobs() {
    return jobsCollection.orderBy('timestamp', descending: true).snapshots();
  }

  /// ✅ Fetch jobs posted by a specific user
  Stream<QuerySnapshot> getUserJobs(String userId) {
    return jobsCollection.where('postedBy', isEqualTo: userId).snapshots();
  }

  /// ✅ Delete a job (Only by the owner)
  Future<void> deleteJob(String jobId) async {
    await jobsCollection.doc(jobId).delete();
  }

  /// ✅ Update a job post
  Future<void> updateJob(String jobId, String title, String description) async {
    await jobsCollection.doc(jobId).update({
      'title': title,
      'description': description,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
