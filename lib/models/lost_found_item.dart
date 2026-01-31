import 'package:cloud_firestore/cloud_firestore.dart';

class LostFoundItem {
  final String id;
  final String description;
  final String location;
  final DateTime date;
  final String imageUrl;
  final String status; // 'lost' or 'found'
  final String userId;
  final String userEmail;
  final DateTime createdAt;

  LostFoundItem({
    required this.id,
    required this.description,
    required this.location,
    required this.date,
    required this.imageUrl,
    required this.status,
    required this.userId,
    required this.userEmail,
    required this.createdAt,
  });

  factory LostFoundItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return LostFoundItem(
      id: doc.id,
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] ?? '',
      status: data['status'] ?? '',
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'location': location,
      'date': Timestamp.fromDate(date),
      'imageUrl': imageUrl,
      'status': status,
      'userId': userId,
      'userEmail': userEmail,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}