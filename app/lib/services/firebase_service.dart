import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/monument.dart';
import '../models/user_profile.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all monuments
  Future<List<Monument>> getAllMonuments() async {
    try {
      final snapshot = await _firestore.collection('monuments').get();
      return snapshot.docs
          .map((doc) => Monument.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching monuments: $e');
      return [];
    }
  }

  // Get monuments by categories (for personalized feed)
  Future<List<Monument>> getMonumentsByCategories(
      List<String> categories) async {
    try {
      final snapshot = await _firestore
          .collection('monuments')
          .where('categories', arrayContainsAny: categories)
          .get();
      return snapshot.docs
          .map((doc) => Monument.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching monuments by categories: $e');
      return [];
    }
  }

  // Search monument by name (for camera recognition)
  Future<Monument?> searchMonumentByName(String name) async {
    try {
      final snapshot = await _firestore
          .collection('monuments')
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Monument.fromFirestore(
            snapshot.docs.first.data(), snapshot.docs.first.id);
      }
      return null;
    } catch (e) {
      print('Error searching monument: $e');
      return null;
    }
  }

  // Get user profile
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserProfile.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // Save user profile
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.userId)
          .set(profile.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving user profile: $e');
    }
  }

  // Add reflection
  Future<void> addReflection(
      String userId, String monumentId, Reflection reflection) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'reflections': {
          monumentId: reflection.toMap(),
        },
        'visited_monuments': FieldValue.arrayUnion([monumentId]),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error adding reflection: $e');
    }
  }

  // Add monument (for initial setup)
  Future<void> addMonument(Monument monument) async {
    try {
      await _firestore
          .collection('monuments')
          .doc(monument.id)
          .set(monument.toFirestore());
    } catch (e) {
      print('Error adding monument: $e');
    }
  }
}