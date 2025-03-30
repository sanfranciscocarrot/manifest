import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_data.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'meditation_users';

  FirebaseService() {
    // Enable offline persistence
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  Future<String?> saveUserData(MeditationUserData userData) async {
    try {
      final docRef = await _firestore
          .collection(_collectionName)
          .add(userData.toMap())
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Connection timed out. Data will be synced when online.');
            },
          );
      return docRef.id;
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }

  Future<List<MeditationUserData>> getAllUserData() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => MeditationUserData.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting all user data: $e');
      return [];
    }
  }

  Stream<List<MeditationUserData>> streamUserData() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MeditationUserData.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> deleteUserData(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      print('Error deleting user data: $e');
      rethrow;
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  
  TimeoutException(this.message);
  
  @override
  String toString() => message;
} 