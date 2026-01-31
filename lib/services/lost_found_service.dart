// ignore: avoid_web_libraries_in_flutter
import 'dart:io' show File;

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class LostFoundService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ADD LOST / FOUND ITEM
  static Future<String?> addItem({
    required String description,
    required String location,
    required DateTime date,
    required String status,
    File? imageFile,       // Mobile
    XFile? imageXFile,     // Web
  }) async {
    try {
      print('🚀 Starting addItem');

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      String? imageUrl;

      // ================= IMAGE UPLOAD =================
      if (imageXFile != null || imageFile != null) {
        try {
          final fileName =
              'lostFound/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';

          final ref = FirebaseStorage.instance.ref().child(fileName);


          if (kIsWeb && imageXFile != null) {
            // 🌐 WEB
            print('🌐 Uploading image (WEB)');
            final bytes = await imageXFile.readAsBytes();
            await ref.putData(
              bytes,
              SettableMetadata(contentType: 'image/jpeg'),
            );
          } else if (imageFile != null) {
            // 📱 MOBILE
            print('📱 Uploading image (MOBILE)');
            await ref.putFile(
              imageFile,
              SettableMetadata(contentType: 'image/jpeg'),
            );
          }

          imageUrl = await ref.getDownloadURL();
          print('✅ Image uploaded: $imageUrl');
        } catch (e) {
          print('❌ Image upload failed: $e');
          imageUrl = null; // IMPORTANT
        }
      }

      // ================= FIRESTORE SAVE =================
      final docRef =
      await _firestore.collection('lost_found_items').add({
        'description': description,
        'location': location,
        'date': Timestamp.fromDate(date),
        'status': status.toLowerCase(),
        'imageUrl': imageUrl, // ✅ null or URL
        'userId': user.uid,
        'userEmail': user.email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Item added: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ addItem error: $e');
      return null;
    }
  }

  /// GET ITEMS BY STATUS
  static Stream<QuerySnapshot> getItemsByStatus(String status) {
    return _firestore
        .collection('lost_found_items')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// DELETE ITEM
  static Future<bool> deleteItem(String itemId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc =
      await _firestore.collection('lost_found_items').doc(itemId).get();

      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != user.uid) return false;

      await _firestore.collection('lost_found_items').doc(itemId).delete();
      return true;
    } catch (e) {
      print('❌ deleteItem error: $e');
      return false;
    }
  }
}
