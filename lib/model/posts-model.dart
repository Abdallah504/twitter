class PostModel {
  final String id;
  final String userId;
  final String username;
  final String userProfilePic;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final List<String> likes;
  final List<String> comments;

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userProfilePic,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.likes,
    required this.comments,
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
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'comments': comments,
    };
  }

  /// Create a PostModel from Firestore DocumentSnapshot
  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'],
      userId: map['userId'],
      username: map['username'],
      userProfilePic: map['userProfilePic'],
      content: map['content'],
      imageUrl: map['imageUrl'],
      createdAt: DateTime.parse(map['createdAt']),
      likes: List<String>.from(map['likes']),
      comments: List<String>.from(map['comments']),
    );
  }
}
