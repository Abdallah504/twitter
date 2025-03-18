import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/logic/auth-provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context,auth,_){
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Image.asset('assets/twitter.png'),
          centerTitle: true,
          leading: _buildProfileAvatar(auth),
        ),
        body: Center(
          child: Text('Chat',style: TextStyle(color: Colors.white),),
        ),
      );
    });
  }
  Widget _buildProfileAvatar(AuthProvider auth) {
    String? profilePic = auth.person?.photoURL ?? auth.userModel?.profilePic;

    if (profilePic == null || profilePic.isEmpty) {
      return CircleAvatar(
        child: Icon(Icons.person, color: Colors.white),
        backgroundColor: Colors.grey,
      );
    }

    return CircleAvatar(
      backgroundImage: NetworkImage(profilePic),
      onBackgroundImageError: (_, __) => debugPrint("Error loading profile image"),
    );
  }
}
