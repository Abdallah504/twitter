
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/logic/auth-provider.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
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
          child: Text('Search',style: TextStyle(color: Colors.white),),
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
