import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String senderId;
  final String recipientId;
  final String content;
  final DateTime timestamp;
  final bool read;

  MessageModel({
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.timestamp,
    required this.read,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map['senderId'] ?? '',
      recipientId: map['recipientId'] ?? '',
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      read: map['read'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'recipientId': recipientId,
      'content': content,
      'timestamp': timestamp,
      'read': read,
    };
  }
}