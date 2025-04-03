import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String senderId;
  final String recipientId;
  final String content;
  final DateTime? timestamp; // Make timestamp nullable
  final bool read;

  MessageModel({
    required this.senderId,
    required this.recipientId,
    required this.content,
    this.timestamp, // Now nullable
    required this.read,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map['senderId'] ?? '',
      recipientId: map['recipientId'] ?? '',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : null,
      read: map['read'] ?? false,
    );
  }
}