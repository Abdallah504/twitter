import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitter/controller/logic/posts-provider.dart';
import '../../controller/logic/auth-provider.dart';
import '../../model/posts-model.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, auth, _) {
      return Consumer<PostsProvider>(builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Image.asset('assets/twitter.png'),
            centerTitle: true,
            leading: _buildProfileAvatar(auth),
          ),
          body: StreamBuilder<List<PostModel>>(
            stream: provider.getPosts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error loading posts", style: TextStyle(color: Colors.white)));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("No posts available", style: TextStyle(color: Colors.white70)));
              }

              final posts = snapshot.data!;
              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return _buildPostItem(post, auth, provider);
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showPostDialog(context, auth, provider),
            child: Image.asset('assets/text.png'),
            backgroundColor: Colors.blue,
          ),
        );
      });
    });
  }

  /// Profile avatar in AppBar
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


  /// Build a single post item
  Widget _buildPostItem(PostModel post, AuthProvider auth, PostsProvider provider) {
    bool isLiked = post.likes.contains(auth.userModel?.uid);

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: post.userProfilePic.isNotEmpty
            ? NetworkImage(post.userProfilePic)
            : null,
        child: post.userProfilePic.isEmpty ? Icon(Icons.person, color: Colors.white) : null,
        backgroundColor: Colors.grey,
      ),
      title: Text(post.username, style: TextStyle(color: Colors.white)),
      subtitle: Text(post.content, style: TextStyle(color: Colors.white70)),
      trailing: IconButton(
        icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.white),
        onPressed: () {
          if (auth.userModel?.uid != null) {
            provider.likePost(post.id, auth.userModel!.uid);
          }
        },
      ),
    );
  }


  /// Show dialog to create a new post
  void _showPostDialog(BuildContext context, AuthProvider auth, PostsProvider provider) {
    TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text("New Post", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: contentController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(hintText: "What's on your mind?", hintStyle: TextStyle(color: Colors.white70)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              if (contentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Post cannot be empty"), backgroundColor: Colors.red),
                );
                return;
              }

              final post = PostModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                userId: auth.person?.uid ?? auth.userModel!.uid,
                username: auth.person?.displayName ?? auth.userModel!.username,
                userProfilePic: auth.person?.photoURL ?? auth.userModel!.profilePic,
                content: contentController.text.trim(),
                createdAt: DateTime.now(),
                likes: [],
                comments: [],
              );

              provider.createPost(post);
              Navigator.pop(context);
            },
            child: Text("Post", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
