import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:twitter/controller/logic/posts-provider.dart';
import '../../controller/logic/auth-provider.dart';
import '../../model/comment-model.dart';
import '../../model/posts-model.dart';
import 'package:timeago/timeago.dart' as timeago;

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
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildProfileAvatar(auth),
            ),
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
                  return Padding(padding:EdgeInsets.all(8) ,
                  child: _buildPostItem(post, auth, provider,context),
                  );
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
  Widget _buildPostItem(PostModel post, AuthProvider auth, PostsProvider provider, BuildContext context) {
    bool isLiked = post.likes.contains(auth.userModel?.uid);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(10).r
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            onTap: (){
              _showCommentsPopup(context, provider, post.id);
            },
            leading: CircleAvatar(
              backgroundImage: post.userProfilePic.isNotEmpty
                  ? NetworkImage(post.userProfilePic)
                  : null,
              child: post.userProfilePic.isEmpty ? Icon(Icons.person, color: Colors.white) : null,
              backgroundColor: Colors.grey,
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(post.username, style: TextStyle(color: Colors.white)),
                Text(timeago.format(post.createdAt, locale: 'en'), style: TextStyle(color: Colors.white, fontSize: 6.sp)),
              ],
            ),
            subtitle: Text(post.content, style: TextStyle(color: Colors.white70)),
            trailing: IconButton(
              icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.white),
              onPressed: () {
                if (auth.userModel?.uid != null) {
                  provider.likePost(post.id, auth.userModel!.uid);
                }
              },
            ),
          ),
          // Add Comment Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => _showCommentDialog(context, auth, provider, post.id),
                child: Text("Add Comment", style: TextStyle(color: Colors.blue)),
              ),
              auth.userModel!.uid==post.userId?
              IconButton(onPressed: (){}, icon: Icon(Icons.delete),color: Colors.red,):
              SizedBox()
            ],
          )

        ],
      ),
    );
  }
  void _showCommentsPopup(BuildContext context, PostsProvider provider, String postId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text("Comments", style: TextStyle(color: Colors.white)),
          content: Container(
            width: double.maxFinite,
            child: StreamBuilder<List<CommentModel>>(
              stream: provider.getComments(postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text("Error loading comments", style: TextStyle(color: Colors.white));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text("No comments yet", style: TextStyle(color: Colors.white70));
                }

                final comments = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(comment.userProfilePic),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(comment.username, style: TextStyle(color: Colors.white)),
                          // Text(timeago.format(comment.createdAt, locale: 'en'), style: TextStyle(color: Colors.white, fontSize: 6.sp)),
                        ],
                      ),
                      subtitle: Text(comment.content, style: TextStyle(color: Colors.white70)),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _showCommentDialog(BuildContext context, AuthProvider auth, PostsProvider provider, String postId) {
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text("Add Comment", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: commentController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(hintText: "Write a comment...", hintStyle: TextStyle(color: Colors.white70)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              if (commentController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Comment cannot be empty"), backgroundColor: Colors.red),
                );
                return;
              }

              final comment = CommentModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                userId: auth.person?.uid ?? auth.userModel!.uid,
                username: auth.person?.displayName ?? auth.userModel!.username,
                userProfilePic: auth.person?.photoURL ?? auth.userModel!.profilePic,
                content: commentController.text.trim(),
                createdAt: DateTime.now(),
              );

              provider.addComment(postId, comment);
              Navigator.pop(context);
            },
            child: Text("Post", style: TextStyle(color: Colors.blue)),
          ),
        ],
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
