import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsService {
  final _db = FirebaseFirestore.instance;

  Stream<int> totalStudents() {
    return _db.collection('students').snapshots().map((s) => s.size);
  }

  Stream<int> totalAdmins() {
    return _db.collection('management').snapshots().map((s) => s.size);
  }

  Stream<int> totalIssues() {
    return _db.collection('issues').snapshots().map((s) => s.size);
  }

  Stream<int> openIssues() {
    return _db
        .collection('issues')
        .where('status', isEqualTo: 'Open')
        .snapshots()
        .map((s) => s.size);
  }

  Stream<int> resolvedIssues() {
    return _db
        .collection('issues')
        .where('status', isEqualTo: 'Resolved')
        .snapshots()
        .map((s) => s.size);
  }

  Stream<int> totalAnnouncements() {
    return _db.collection('announcements').snapshots().map((s) => s.size);
  }
}
