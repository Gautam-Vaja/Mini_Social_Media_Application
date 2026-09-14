import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BlockedUsersService extends ChangeNotifier {
  BlockedUsersService._internal() {
    init();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      init();
    });
  }
  static final BlockedUsersService instance = BlockedUsersService._internal();

  final Map<int, Map<String, dynamic>> _blockedUsersMemory = {};

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _blockedUsersRef {
    final uid = _currentUserId;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('blocked_users');
  }

  bool isBlocked(int userId) {
    return _blockedUsersMemory.containsKey(userId);
  }

  List<Map<String, dynamic>> get blockedUsers =>
      _blockedUsersMemory.values.toList();

  Future<void> init() async {
    try {
      final ref = _blockedUsersRef;
      if (ref == null) {
        notifyListeners();
        return;
      }

      final snapshot = await ref.get();
      _blockedUsersMemory.clear();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final userId = data['userId'] is int
            ? data['userId'] as int
            : int.tryParse(doc.id) ??
                  int.tryParse(data['userId']?.toString() ?? '0') ??
                  0;
        if (userId != 0) {
          _blockedUsersMemory[userId] = data;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error initializing blocked users: $e");
      notifyListeners();
    }
  }

  Future<void> blockUser({
    required int userId,
    required String username,
    required String fullName,
    required String image,
  }) async {
    final data = {
      'userId': userId,
      'username': username,
      'fullName': fullName,
      'image': image,
      'blockedAt': DateTime.now().toIso8601String(),
    };

    _blockedUsersMemory[userId] = data;
    notifyListeners();

    try {
      final ref = _blockedUsersRef;
      if (ref != null) {
        await ref.doc(userId.toString()).set(data, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint("Firestore block user error: $e");
    }
  }

  Future<void> unblockUser(int userId) async {
    _blockedUsersMemory.remove(userId);
    notifyListeners();

    try {
      final ref = _blockedUsersRef;
      if (ref != null) {
        await ref.doc(userId.toString()).delete();
      }
    } catch (e) {
      debugPrint("Firestore unblock user error: $e");
    }
  }
}
