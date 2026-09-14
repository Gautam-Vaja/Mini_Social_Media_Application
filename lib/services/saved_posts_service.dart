import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/post_model.dart';

class SavedPostsService extends ChangeNotifier {
  SavedPostsService._internal() {
    init();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      init();
    });
  }
  static final SavedPostsService instance = SavedPostsService._internal();

  final Map<int, PostModel> _savedPostsMemory = {};

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _savedPostsRef {
    final uid = _currentUserId;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('saved_posts');
  }

  bool isSaved(int postId) {
    return _savedPostsMemory.containsKey(postId);
  }

  List<PostModel> get savedPosts => _savedPostsMemory.values.toList();

  Future<void> init() async {
    try {
      final ref = _savedPostsRef;
      if (ref == null) {
        notifyListeners();
        return;
      }

      final snapshot = await ref.get();
      _savedPostsMemory.clear();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final post = PostModel.fromJson(data);
        if (post.id != 0) {
          _savedPostsMemory[post.id] = post;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error initializing saved posts: $e");
      notifyListeners();
    }
  }

  Future<bool> toggleSave(PostModel post) async {
    final postId = post.id;
    final currentlySaved = isSaved(postId);

    if (currentlySaved) {
      _savedPostsMemory.remove(postId);
    } else {
      _savedPostsMemory[postId] = post;
    }
    notifyListeners();

    try {
      final ref = _savedPostsRef;
      if (ref != null) {
        final docRef = ref.doc(postId.toString());
        if (currentlySaved) {
          await docRef.delete();
        } else {
          final data = post.toJson();
          data['savedAt'] = DateTime.now().toIso8601String();
          await docRef.set(data, SetOptions(merge: true));
        }
      }
    } catch (e) {
      debugPrint("Firestore save post error: $e");
    }

    return !currentlySaved;
  }
}
