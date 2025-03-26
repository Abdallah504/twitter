import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twitter/controller/logic/auth-provider.dart';
import 'package:twitter/model/user-model.dart';
import 'package:twitter/model/message-model.dart';

class ChatScreen extends StatefulWidget {
  final UserModel recipientUser;

  const ChatScreen({super.key, required this.recipientUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isListViewAttached = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollListener() {
    _isListViewAttached = _scrollController.hasClients;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = auth.userModel;

    if (_messageController.text.trim().isEmpty || currentUser == null) return;

    final message = {
      'senderId': currentUser.uid,
      'recipientId': widget.recipientUser.uid,
      'participants': [currentUser.uid, widget.recipientUser.uid],
      'content': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    };

    try {
      // Add message to Firestore
      await FirebaseFirestore.instance.collection('messages').add(message);

      // Update chat metadata
      final chatData = {
        'lastMessage': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'participants': [currentUser.uid, widget.recipientUser.uid],
        'user1': currentUser.uid,
        'user2': widget.recipientUser.uid,
      };

      await FirebaseFirestore.instance
          .collection('chats')
          .doc(_getChatId(currentUser.uid, widget.recipientUser.uid))
          .set(chatData, SetOptions(merge: true));

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  void _scrollToBottom() {
    if (_isListViewAttached && _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  String _getChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '$uid1-$uid2' : '$uid2-$uid1';
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final currentUserId = auth.userModel?.uid;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.recipientUser.name,
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ),
            Text(
              '@${widget.recipientUser.username}',
              style: TextStyle(color: Colors.white70, fontSize: 12.sp),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: currentUserId == null
                ? const Center(
              child: Text('Please sign in', style: TextStyle(color: Colors.white)),
            )
                : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('participants', arrayContains: currentUserId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No messages yet', style: TextStyle(color: Colors.white70)),
                  );
                }

                // Filter messages to only include those between current user and recipient
                final filteredMessages = snapshot.data!.docs.where((doc) {
                  final message = doc.data() as Map<String, dynamic>;
                  return (message['senderId'] == currentUserId &&
                      message['recipientId'] == widget.recipientUser.uid) ||
                      (message['senderId'] == widget.recipientUser.uid &&
                          message['recipientId'] == currentUserId);
                }).toList();

                if (filteredMessages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet', style: TextStyle(color: Colors.white70)),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: filteredMessages.length,
                  itemBuilder: (context, index) {
                    final message = MessageModel.fromMap(
                      filteredMessages[index].data() as Map<String, dynamic>,
                    );
                    final isMe = message.senderId == currentUserId;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.all(8.r),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[800],
                          borderRadius: BorderRadius.circular(12).r,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              message.content,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _formatTime(message.timestamp),
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.r),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30).r,
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[900],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8.w),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}