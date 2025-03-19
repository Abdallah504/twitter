import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../model/comment-model.dart';
import '../../model/posts-model.dart';

class PostsProvider extends ChangeNotifier{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// **Create a New Post**
  Future<void> createPost(PostModel post) async {
    try {
      await _firestore.collection('posts').doc(post.id).set(post.toMap());
      notifyListeners();
    } catch (e) {
      print("Error creating post: $e");
    }
  }

  /// **Fetch All Posts (Latest First)**
  Stream<List<PostModel>> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => PostModel.fromMap(doc.data())).toList());
  }

  /// **Like a Post**
  Future<void> likePost(String postId, String userId) async {
    final postRef = _firestore.collection('posts').doc(postId);
    final postSnapshot = await postRef.get();

    if (postSnapshot.exists) {
      List<String> likes = List<String>.from(postSnapshot.data()!['likes']);

      if (likes.contains(userId)) {
        likes.remove(userId); // Unlike post
      } else {
        likes.add(userId); // Like post
      }

      await postRef.update({'likes': likes});
      notifyListeners();
    }
  }

  /// **Delete a Post**
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
      notifyListeners();
    } catch (e) {
      print("Error deleting post: $e");
    }
  }

  Future<void> addComment(String postId, CommentModel comment) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      await postRef.update({
        'comments': FieldValue.arrayUnion([comment.toMap()]), // Add comment to the list
      });
      notifyListeners();
    } catch (e) {
      print("Error adding comment: $e");
    }
  }

  /// Fetch Comments for a Post
  Stream<List<CommentModel>> getComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      if (data != null && data['comments'] != null) {
        return (data['comments'] as List<dynamic>)
            .map((comment) => CommentModel.fromMap(comment))
            .toList();
      }
      return [];
    });
  }
}
