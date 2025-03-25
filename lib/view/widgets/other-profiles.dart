import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:twitter/controller/logic/auth-provider.dart';
import 'package:twitter/controller/logic/posts-provider.dart';
import 'package:twitter/model/posts-model.dart';
import 'package:twitter/model/user-model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OtherProfileScreen extends StatefulWidget {
  final UserModel user;

  const OtherProfileScreen({super.key, required this.user});

  @override
  State<OtherProfileScreen> createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  late UserModel _user;
  bool _isFollowing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _checkIfFollowing();
  }

  Future<void> _checkIfFollowing() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUserId = auth.userModel?.uid;
      if (currentUserId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_user.uid)
            .get();

        if (userDoc.exists) {
          final updatedUser = UserModel.fromMap(userDoc.data()!);
          setState(() {
            _user = updatedUser;
            _isFollowing = updatedUser.followers.contains(currentUserId);
          });
        }
      }
    } catch (e) {
      print("Error checking follow status: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = auth.userModel?.uid;

    if (currentUserId == null || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(_user.uid);
      final currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUserId);

      if (_isFollowing) {
        // Unfollow
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.update(userRef, {
            'followers': FieldValue.arrayRemove([currentUserId])
          });
          transaction.update(currentUserRef, {
            'following': FieldValue.arrayRemove([_user.uid])
          });
        });
      } else {
        // Follow
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.update(userRef, {
            'followers': FieldValue.arrayUnion([currentUserId])
          });
          transaction.update(currentUserRef, {
            'following': FieldValue.arrayUnion([_user.uid])
          });
        });
      }

      // Update local state
      final userDoc = await userRef.get();
      if (userDoc.exists) {
        setState(() {
          _user = UserModel.fromMap(userDoc.data()!);
          _isFollowing = !_isFollowing;
        });
      }
    } catch (e) {
      print("Error toggling follow: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(_user.name, style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
                Container(
                  height: 150.h,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.grey,
                  child: _user.bannerImage.isNotEmpty
                      ? Image.network(
                    _user.bannerImage,
                    fit: BoxFit.cover,
                  )
                      : Icon(Icons.image, color: Colors.white),
                ),
                // Profile Picture
                Positioned(
                  bottom: -20.h,
                  left: 16.w,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black,
                        width: 2.w,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50.r,
                      backgroundColor: Colors.grey,
                      backgroundImage: _user.profilePic.isNotEmpty
                          ? NetworkImage(_user.profilePic)
                          : null,
                      child: _user.profilePic.isEmpty
                          ? Icon(Icons.person, color: Colors.white, size: 50.r)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Follow Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _user.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "@${_user.username}",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                      _buildFollowButton(),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Bio
                  Text(
                    _user.bio,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Followers and Following count
                  Row(
                    children: [
                      Text(
                        "${_user.followers.length} Followers",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        "${_user.following.length} Following",
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
                        if (_user.location.isNotEmpty) ...[
                          Icon(Icons.location_on, color: Colors.grey, size: 20.r),
                          SizedBox(width: 4.w),
                          Text(
                            _user.location,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(width: 16.w),
                        ],
                        if (_user.website.isNotEmpty) ...[
                          Icon(Icons.link, color: Colors.grey, size: 20.r),
                          SizedBox(width: 4.w),
                          TextButton(
                            onPressed: () async {
                              if (_user.website.startsWith('http')) {
                                await launchUrl(Uri.parse(_user.website));
                              } else {
                                await launchUrl(Uri.parse('https://${_user.website}'));
                              }
                            },
                            child: Text(
                              _user.website,
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14.sp,
                              ),
                            ),
                          )
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            // Display user's posts
            Consumer<PostsProvider>(
              builder: (context, provider, _) {
                return StreamBuilder<List<PostModel>>(
                  stream: provider.getPosts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text("Error loading posts",
                              style: TextStyle(color: Colors.white)));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: Text("No posts available",
                              style: TextStyle(color: Colors.white70)));
                    }

                    final posts = snapshot.data!
                        .where((post) => post.userId == _user.uid)
                        .toList();

                    if (posts.isEmpty) {
                      return Center(
                          child: Text("No posts by this user",
                              style: TextStyle(color: Colors.white70)));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return _buildPostItem(post, context);
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
  }

  Widget _buildFollowButton() {
    if (_isLoading) {
      return CircularProgressIndicator(color: Colors.blue);
    }

    return InkWell(
      onTap: _toggleFollow,
      child: Container(
        decoration: BoxDecoration(
          color: _isFollowing ? Colors.black : Colors.blue,
          borderRadius: BorderRadius.circular(10).r,
          border: Border.all(
            color: _isFollowing ? Colors.white : Colors.transparent,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            _isFollowing ? 'Following' : 'Follow',
            style: TextStyle(
              color: _isFollowing ? Colors.white : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostItem(PostModel post, BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    bool isLiked = post.likes.contains(auth.userModel?.uid);

    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(10).r,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: post.userProfilePic.isNotEmpty
                    ? NetworkImage(post.userProfilePic)
                    : null,
                child: post.userProfilePic.isEmpty
                    ? Icon(Icons.person, color: Colors.white)
                    : null,
                backgroundColor: Colors.grey,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(post.username, style: TextStyle(color: Colors.white)),
                  Text(timeago.format(post.createdAt, locale: 'en'),
                      style: TextStyle(color: Colors.white, fontSize: 6.sp)),
                ],
              ),
              subtitle: Text(post.content,
                  style: TextStyle(color: Colors.white70)),
              trailing: IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  if (auth.userModel?.uid != null) {
                    Provider.of<PostsProvider>(context, listen: false)
                        .likePost(post.id, auth.userModel!.uid);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}