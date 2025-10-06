import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> createOrUpdateUser(User user) async {
    final userDoc = _db.collection('users').doc(user.uid);
    final snapshot = await userDoc.get();

    if (!snapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'hasLifetimeAccess': false,
        'hasActiveSubscription': false,
        'subscriptionStartDate': null,
        'unlockedPrompts': [],
        'favoritePrompts': [],
        'totalPromptsUnlocked': 0,
        'isAdFree': false,
      });
    } else {
      await userDoc.update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  static Future<void> unlockPrompt(String uid, String promptId) async {
    await _db.collection('users').doc(uid).update({
      'unlockedPrompts': FieldValue.arrayUnion([promptId]),
      'totalPromptsUnlocked': FieldValue.increment(1),
    });

    await _logPurchase(uid, 'single_prompt', promptId);
  }

  static Future<void> activateLifetimeAccess(String uid) async {
    await _db.collection('users').doc(uid).update({
      'hasLifetimeAccess': true,
      'isAdFree': true,
      'lifetimeAccessDate': FieldValue.serverTimestamp(),
    });

    await _logPurchase(uid, 'lifetime_access', null);
  }

  static Future<void> activateSubscription(String uid) async {
    await _db.collection('users').doc(uid).update({
      'hasActiveSubscription': true,
      'isAdFree': true,
      'subscriptionStartDate': FieldValue.serverTimestamp(),
    });

    await _logPurchase(uid, 'monthly_subscription', null);
  }

  static Future<void> deactivateSubscription(String uid) async {
    await _db.collection('users').doc(uid).update({
      'hasActiveSubscription': false,
      'isAdFree': false,
    });
  }

  static Future<void> toggleFavorite(String uid, String promptId, bool isFavorite) async {
    if (isFavorite) {
      await _db.collection('users').doc(uid).update({
        'favoritePrompts': FieldValue.arrayUnion([promptId]),
      });
    } else {
      await _db.collection('users').doc(uid).update({
        'favoritePrompts': FieldValue.arrayRemove([promptId]),
      });
    }
  }

  static Future<void> _logPurchase(String uid, String type, String? promptId) async {
    await _db.collection('purchases').add({
      'uid': uid,
      'type': type,
      'promptId': promptId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<bool> hasLifetimeAccess(String uid) async {
    final data = await getUserData(uid);
    return data?['hasLifetimeAccess'] ?? false;
  }

  static Future<bool> hasActiveSubscription(String uid) async {
    final data = await getUserData(uid);
    final hasSubscription = data?['hasActiveSubscription'] ?? false;
    
    if (hasSubscription) {
      final startDate = data?['subscriptionStartDate'] as Timestamp?;
      if (startDate != null) {
        final daysSinceStart = DateTime.now().difference(startDate.toDate()).inDays;
        if (daysSinceStart >= 30) {
          await deactivateSubscription(uid);
          return false;
        }
      }
    }
    
    return hasSubscription;
  }

  static Future<bool> isAdFree(String uid) async {
    final data = await getUserData(uid);
    return data?['isAdFree'] ?? false;
  }

  static Future<List<String>> getUnlockedPrompts(String uid) async {
    final data = await getUserData(uid);
    return List<String>.from(data?['unlockedPrompts'] ?? []);
  }

  static Future<List<String>> getFavoritePrompts(String uid) async {
    final data = await getUserData(uid);
    return List<String>.from(data?['favoritePrompts'] ?? []);
  }
}
