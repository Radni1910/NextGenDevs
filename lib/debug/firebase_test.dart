import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDebugHelper {
  static Future<void> testFirebaseConnections() async {
    print('🔍 Testing Firebase connections...');

    // Test Authentication
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('✅ Auth: User logged in - ${user.uid}');
        print('📧 Email: ${user.email}');
      } else {
        print('❌ Auth: No user logged in');
        return;
      }
    } catch (e) {
      print('❌ Auth Error: $e');
      return;
    }

    // Test Firestore
    try {
      await FirebaseFirestore.instance
          .collection('test')
          .doc('test_doc')
          .set({'test': 'data', 'timestamp': FieldValue.serverTimestamp()});
      print('✅ Firestore: Write test successful');

      await FirebaseFirestore.instance
          .collection('test')
          .doc('test_doc')
          .delete();
      print('✅ Firestore: Delete test successful');
    } catch (e) {
      print('❌ Firestore Error: $e');
    }

    // Test Storage
    try {
      final ref = FirebaseStorage.instance.ref().child('test/test_file.txt');
      await ref.putString('test data');
      print('✅ Storage: Upload test successful');

      await ref.delete();
      print('✅ Storage: Delete test successful');
    } catch (e) {
      print('❌ Storage Error: $e');
    }
  }

  static Future<void> testImageUpload(File imageFile) async {
    print('🖼️ Testing image upload...');

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ No user authenticated');
        return;
      }

      print('📁 Image file: ${imageFile.path}');
      print('📊 File size: ${await imageFile.length()} bytes');
      print('✅ File exists: ${await imageFile.exists()}');

      final ref = FirebaseStorage.instance
          .ref()
          .child('test_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      print('📤 Starting upload...');
      final uploadTask = ref.putFile(imageFile);

      uploadTask.snapshotEvents.listen((snapshot) {
        double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('📈 Upload progress: ${progress.toStringAsFixed(1)}%');
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('✅ Upload successful!');
      print('🔗 Download URL: $downloadUrl');

      // Clean up test file
      await ref.delete();
      print('🗑️ Test file cleaned up');

    } catch (e) {
      print('❌ Image upload test failed: $e');
    }
  }
}