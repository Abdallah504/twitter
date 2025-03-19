import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../controller/logic/auth-provider.dart';

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

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, auth, _) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Image.asset('assets/twitter.png'),
          centerTitle: true,
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
                    // Location and Website
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey, size: 16.sp),
                        SizedBox(width: 4.w),
                        Text(
                          auth.userModel?.location ?? "Location",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Icon(Icons.link, color: Colors.grey, size: 16.sp),
                        SizedBox(width: 4.w),
                        Text(
                          auth.userModel?.website ?? "Website",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
}