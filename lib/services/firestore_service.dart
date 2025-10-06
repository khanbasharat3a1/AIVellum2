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
        'lifetimeAccessDate': null,
        'hasActiveSubscription': false,
        'subscriptionStartDate': null,
        'subscriptionEndDate': null,
        'subscriptionAutoRenew': false,
        'unlockedPrompts': [],
        'favoritePrompts': [],
        'totalPromptsUnlocked': 0,
        'isAdFree': false,
      });
    } else {
      await userDoc.update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
      // Check subscription expiry on login
      await _checkSubscriptionExpiry(user.uid);
    }
  }

  static Future<void> _checkSubscriptionExpiry(String uid) async {
    final data = await getUserData(uid);
    if (data == null) return;
    
    final hasSubscription = data['hasActiveSubscription'] ?? false;
    if (!hasSubscription) return;
    
    final endDate = data['subscriptionEndDate'] as Timestamp?;
    if (endDate != null && DateTime.now().isAfter(endDate.toDate())) {
      await deactivateSubscription(uid);
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
    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month + 1, now.day);
    
    await _db.collection('users').doc(uid).update({
      'hasActiveSubscription': true,
      'isAdFree': true,
      'subscriptionStartDate': Timestamp.fromDate(now),
      'subscriptionEndDate': Timestamp.fromDate(endDate),
      'subscriptionAutoRenew': true,
    });

    await _logPurchase(uid, 'monthly_subscription', null);
  }

  static Future<void> deactivateSubscription(String uid) async {
    await _db.collection('users').doc(uid).update({
      'hasActiveSubscription': false,
      'isAdFree': false,
      'subscriptionAutoRenew': false,
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
      final endDate = data?['subscriptionEndDate'] as Timestamp?;
      if (endDate != null && DateTime.now().isAfter(endDate.toDate())) {
        await deactivateSubscription(uid);
        return false;
      }
    }
    
    return hasSubscription;
  }

  static Stream<Map<String, dynamic>?> getUserDataStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) => doc.data());
  }

  static Future<void> syncLocalToCloud(String uid, List<String> localUnlocked, List<String> localFavorites) async {
    final cloudData = await getUserData(uid);
    if (cloudData == null) return;
    
    final cloudUnlocked = List<String>.from(cloudData['unlockedPrompts'] ?? []);
    final cloudFavorites = List<String>.from(cloudData['favoritePrompts'] ?? []);
    
    final mergedUnlocked = {...cloudUnlocked, ...localUnlocked}.toList();
    final mergedFavorites = {...cloudFavorites, ...localFavorites}.toList();
    
    await _db.collection('users').doc(uid).update({
      'unlockedPrompts': mergedUnlocked,
      'favoritePrompts': mergedFavorites,
      'totalPromptsUnlocked': mergedUnlocked.length,
    });
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
