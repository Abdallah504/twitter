import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../controller/logic/auth-provider.dart';
import '../../model/user-model.dart'; // Ensure you import your UserModel

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _searchResults = [];

  /// Search for users by username
  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThan: query + 'z') // Ensures case-insensitive search
          .get();

      setState(() {
        _searchResults = snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      print("Error searching users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, auth, _) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: TextField(
            controller: _searchController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Search users...",
              hintStyle: TextStyle(color: Colors.white70),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(Icons.search, color: Colors.white),
                onPressed: () => _searchUsers(_searchController.text.trim()),
              ),
            ),
            onChanged: (value) => _searchUsers(value.trim()),
          ),
          centerTitle: true,
          leading: _buildProfileAvatar(auth),
        ),
        body: _searchResults.isEmpty
            ? Center(
          child: Text(
            _searchController.text.isEmpty
                ? "Search for users"
                : "No users found",
            style: TextStyle(color: Colors.white),
          ),
        )
            : ListView.builder(
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final user = _searchResults[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: user.profilePic.isNotEmpty
                    ? NetworkImage(user.profilePic)
                    : null,
                child: user.profilePic.isEmpty
                    ? Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              title: Text(
                user.name,
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "@${user.username}",
                style: TextStyle(color: Colors.white70),
              ),
              onTap: () {
                // Navigate to the user's profile or perform an action
              },
            );
          },
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