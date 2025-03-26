import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twitter/controller/logic/auth-provider.dart';
import 'package:twitter/model/user-model.dart';
import 'chat-screen.dart'; // Import your ChatScreen

class FollowingScreen extends StatelessWidget {
  const FollowingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = auth.userModel?.uid;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Chatting', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.white),
        //   onPressed: () => Navigator.pop(context),
        // ),
      ),
      body: currentUserId == null
          ? const Center(child: Text('Please sign in', style: TextStyle(color: Colors.white)))
          : StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(
              color: Colors.blue,
            ));
          }

          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(child: Text('No following data', style: TextStyle(color: Colors.white)));
          }

          final following = List<String>.from(
              (snapshot.data!.data() as Map<String, dynamic>)['following'] ?? []);

          if (following.isEmpty) {
            return const Center(
                child: Text('You are not following anyone yet',
                    style: TextStyle(color: Colors.white70)));
          }

          return ListView.builder(
            itemCount: following.length,
            itemBuilder: (context, index) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(following[index])
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      leading: CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    );
                  }

                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return const ListTile(
                      title: Text('User not found', style: TextStyle(color: Colors.white)),
                    );
                  }

                  final user = UserModel.fromMap(
                      userSnapshot.data!.data() as Map<String, dynamic>);

                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            recipientUser: user,
                          ),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundImage: user.profilePic.isNotEmpty
                          ? NetworkImage(user.profilePic)
                          : null,
                      child: user.profilePic.isEmpty
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    title: Text(
                      user.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                      ),
                    ),
                    subtitle: Text(
                      '@${user.username}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14.sp,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.blue,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}