import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:twitter/controller/logic/posts-provider.dart';
import 'package:twitter/view/screens/auth-screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controller/logic/auth-provider.dart';
import '../../model/comment-model.dart';
import '../../model/posts-model.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  File? _pickedFile;
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, auth, _) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Image.asset('assets/twitter.png'),
          centerTitle: true,
          leading: IconButton(onPressed: (){
            showDialog(context: context, builder: (context){
              nameController.text = auth.userModel!.name.toString();
              usernameController.text = auth.userModel!.username.toString();
              bioController.text = auth.userModel!.bio.toString();
              locationController.text = auth.userModel!.location.toString();
              websiteController.text = auth.userModel!.website.toString();

              return Dialog(
                child: Container(
                  height: 450.h,
                  width: 350.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10).r
                  ),
                  child:SingleChildScrollView(
                    child: Padding(padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(),
                            IconButton(onPressed: (){
                              Navigator.pop(context);
                            }, icon: Icon(Icons.close))
                          ],
                        ),
                        SizedBox(height: 10,),
                        TextField(
                          controller:nameController ,
                          decoration: InputDecoration(
                            label: Text('Name',style: TextStyle(color: Colors.black),),
                            hintText: 'Name',
                            hintStyle: TextStyle(color: Colors.grey),

                          ),
                        ),
                        SizedBox(height: 10.h,),

                        TextField(
                          controller:usernameController ,
                          decoration: InputDecoration(
                            label: Text('user name',style: TextStyle(color: Colors.black),),
                            hintText: 'user name',
                            hintStyle: TextStyle(color: Colors.grey),

                          ),
                        ),
                        SizedBox(height: 10.h,),

                        TextField(
                          controller:bioController ,
                          decoration: InputDecoration(
                            label: Text('Bio',style: TextStyle(color: Colors.black),),
                            hintText: 'Bio',
                            hintStyle: TextStyle(color: Colors.grey),

                          ),
                        ),
                        SizedBox(height: 10.h,),
                        TextField(
                          controller:locationController ,
                          decoration: InputDecoration(
                            label: Text('Location',style: TextStyle(color: Colors.black),),
                            hintText: 'Location',
                            hintStyle: TextStyle(color: Colors.grey),

                          ),
                        ),
                        SizedBox(height: 10.h,),
                        TextField(
                          controller:websiteController ,
                          decoration: InputDecoration(
                            label: Text('Website',style: TextStyle(color: Colors.black),),
                            hintText: 'Website',
                            hintStyle: TextStyle(color: Colors.grey),

                          ),
                        ),
                        SizedBox(height: 20.h,),

                        InkWell(
                          onTap: ()async{
                            await FirebaseFirestore.instance.collection('users').doc(auth.userModel?.uid).update({
                              'name':nameController.text,
                              'username':usernameController.text,
                              'bio':bioController.text,
                              'website':websiteController.text,
                              'location':locationController.text
                            }).then((v){
                              auth.getUserData();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User updated')));
                              Navigator.pop(context);
                            });
                          },
                          child: Container(
                            height: 30.h,
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10).r
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Update',style: TextStyle(color:Colors.white),),
                            ),
                          ),
                        )

                      ],

                    ),
                    ),
                  ),
                ),
              );
            });
          }, icon: Icon(Icons.edit,color: Colors.white,)),
          actions: [
            IconButton(onPressed: (){
              auth.signOut().then((v){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AuthScreen()));
              });
            }, icon: Icon(Icons.logout,color: Colors.red,))
          ],
        ),

        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  // Banner Image
                  InkWell(
                    onTap: ()async{
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      setState(() {
                        _pickedFile = File(image!.path);
                      });
                      if(_pickedFile!=null){
                        print(_pickedFile!.path);
                        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
                        final path = 'uploads/$fileName';
                        await Supabase.instance.client.storage.from('images').upload(path, _pickedFile!)
                            .then((v)async{
                          final String imageUrl = Supabase.instance.client.storage.from('images').getPublicUrl(path);
                          await FirebaseFirestore.instance.collection('users').doc(auth.userModel?.uid).update({
                            'bannerImage': imageUrl,
                          });
                          auth.getUserData();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image Uploaded')));
                          //imageFile = null;

                        });
                      }

                    },
                    child: Container(
                      height: 150.h, // Adjust height as needed
                      width: MediaQuery.of(context).size.width,
                      color: Colors.grey, // Placeholder for banner image
                      child: auth.userModel?.bannerImage != null &&
                          auth.userModel!.bannerImage.isNotEmpty
                          ? Image.network(
                        auth.userModel!.bannerImage,
                        fit: BoxFit.cover,
                      )
                          : Icon(Icons.image, color: Colors.white),
                    ),
                  ),
                  // Profile Picture
                  Positioned(
                    bottom: -20.h, // Adjust position as needed
                    left: 16.w, // Adjust position as needed
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black,
                          width: 2.w,
                        ),
                      ),
                      child: _buildProfileAvatar(auth),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h), // Spacing between profile picture and text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      auth.userModel?.name ?? "Name",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    // Username
                    Text(
                      "@${auth.userModel?.username ?? "username"}",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Bio
                    Text(
                      auth.userModel?.bio ?? "Bio",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text(
                          "${auth.userModel?.followers.length} Followers",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Text(
                          "${auth.userModel?.following.length} Following",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    // Location and Website
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.grey, size: 20.r),
                          SizedBox(width: 4.w),
                          Text(
                            auth.userModel?.location ?? "Location",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Icon(Icons.link, color: Colors.grey, size: 20.r),
                          SizedBox(width: 4.w),
                          TextButton(onPressed: ()async{
                            await launchUrl(Uri.parse(auth.userModel!.website));
                          }, child: Text(
                            auth.userModel?.website ?? "Website",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14.sp,
                            ),
                          ),)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h,),
              // Display user's posts
              Consumer<PostsProvider>(
                builder: (context, provider, _) {
                  return StreamBuilder<List<PostModel>>(
                    stream: provider.getPosts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error loading posts", style: TextStyle(color: Colors.white)));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text("No posts available", style: TextStyle(color: Colors.white70)));
                      }

                      final posts = snapshot.data!
                          .where((post) => post.userId == auth.userModel?.uid)
                          .toList();

                      if (posts.isEmpty) {
                        return Center(child: Text("No posts by this user", style: TextStyle(color: Colors.white70)));
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return Padding(
                            padding: EdgeInsets.all(8),
                            child: _buildPostItem(post, auth, provider, context),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildProfileAvatar(AuthProvider auth) {
    String? profilePic = auth.person?.photoURL ?? auth.userModel?.profilePic;

    return CircleAvatar(
      radius: 50.r, // Adjust size as needed
      backgroundColor: Colors.grey,
      backgroundImage: profilePic != null && profilePic.isNotEmpty
          ? NetworkImage(profilePic)
          : null,
      child: profilePic == null || profilePic.isEmpty
          ? Icon(Icons.person, color: Colors.white, size: 50.r)
          : null,
    );
  }

  /// Build a single post item (reused from HomeScreen)
  Widget _buildPostItem(PostModel post, AuthProvider auth, PostsProvider provider, BuildContext context) {
    bool isLiked = post.likes.contains(auth.userModel?.uid);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(10).r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            onTap: () {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,size: 9.sp,color: Colors.grey,),
                  SizedBox(width: 2.w,),
                  Text(post.likes.length.toString(),style: TextStyle(color:Colors.grey,fontSize: 10.sp),)
                ],
              ),
              auth.userModel!.uid == post.userId
                  ? IconButton(onPressed: () {}, icon: Icon(Icons.delete), color: Colors.red)
                  : SizedBox()
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
}