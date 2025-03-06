import 'dart:convert';

class UserModel {
  final String uid;
  final String name;
  final String username;
  final String email;
  final String profilePic;
  final String bannerImage;
  final String bio;
  final String location;
  final String website;
  final List<String> followers;
  final List<String> following;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    required this.profilePic,
    required this.bannerImage,
    required this.bio,
    required this.location,
    required this.website,
    required this.followers,
    required this.following,
    required this.createdAt,
  });

  /// Convert Firestore document to a `UserModel` object
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      profilePic: map['profilePic'] ?? '',
      bannerImage: map['bannerImage'] ?? '',
      bio: map['bio'] ?? '',
      location: map['location'] ?? '',
      website: map['website'] ?? '',
      followers: List<String>.from(map['followers'] ?? []),
      following: List<String>.from(map['following'] ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  /// Convert `UserModel` object to a Firestore document
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'username': username,
      'email': email,
      'profilePic': profilePic,
      'bannerImage': bannerImage,
      'bio': bio,
      'location': location,
      'website': website,
      'followers': followers,
      'following': following,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convert JSON string to `UserModel`
  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  /// Convert `UserModel` to JSON string
  String toJson() => json.encode(toMap());
}
