import 'package:cloud_firestore/cloud_firestore.dart';

import 'comment-model.dart';

class PostModel {
  final String id;
  final String userId;
  final String username;
  final String userProfilePic;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final List<String> likes;
  final List<CommentModel> comments; // Updated to use CommentModel

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userProfilePic,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.likes,
    required this.comments, // Updated to use CommentModel
  });

  /// Convert PostModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userProfilePic': userProfilePic,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt), // Firestore Timestamp
      'likes': likes,
      'comments': comments.map((comment) => comment.toMap()).toList(), // Convert comments to Map
    };
  }

  /// Create a PostModel from Firestore DocumentSnapshot
  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      userProfilePic: map['userProfilePic'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(), // Convert Timestamp to DateTime
      likes: List<String>.from(map['likes'] ?? []),
      comments: (map['comments'] as List<dynamic>?) // Convert comments to List<CommentModel>
          ?.map((comment) => CommentModel.fromMap(comment))
          .toList() ??
          [],
    );
  }
}