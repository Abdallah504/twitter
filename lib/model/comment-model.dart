import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String userId;
  final String username;
  final String userProfilePic;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userProfilePic,
    required this.content,
    required this.createdAt,
  });

  /// Convert CommentModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userProfilePic': userProfilePic,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt), // Firestore Timestamp
    };
  }

  /// Create a CommentModel from Firestore Map
  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      userProfilePic: map['userProfilePic'] ?? '',
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(), // Convert Timestamp to DateTime
    );
  }
}