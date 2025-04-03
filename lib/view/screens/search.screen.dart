import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:twitter/controller/logic/news-provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controller/logic/auth-provider.dart';
import '../../model/user-model.dart';
import '../widgets/other-profiles.dart'; // Ensure you import your UserModel

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
      return Consumer<NewsProvider>(builder: (context,provider,_){
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
            leading: Padding(
              padding:  EdgeInsets.all(8.0).r,
              child: _buildProfileAvatar(auth),
            ),
          ),
          body: _searchResults.isEmpty
              ? SingleChildScrollView(
                child:provider.bbcModel!=null &&provider.newsModel!=null? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding:  EdgeInsets.all(5.0).r,
                                  child: Text('Latest News',style: TextStyle(color: Colors.white,fontSize: 20.sp),),
                                ),
                              ),
                SizedBox(height: 15.h,),
                Container(
                  height: 170.h,
                  child: ListView.builder(
                      itemCount: provider.bbcModel!.articles!.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      itemBuilder:(context,index){
                        return Padding(padding: EdgeInsets.all(8),
                        child: InkWell(
                          onTap: ()async{
                            await launchUrl(Uri.parse(provider.bbcModel!.articles![index].url.toString()));
                          },
                          child: Container(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white54),
                              borderRadius: BorderRadius.circular(10).r
                            ),
                            child: Padding(
                              padding:  EdgeInsets.all(2.0).r,
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Container(
                                    height: 170.h,
                                    width: 250.w,

                                    child: Image.network(
                                      provider.bbcModel!.articles![index].urlToImage.toString(),
                                      errorBuilder: (context, error, stackTrace) {
                                        return Image.asset('assets/news.jpg');
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return SizedBox(
                                          width: 100, // Same dimensions as error state
                                          height: 100,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                      fit: BoxFit.cover, // Optional: adjust to your needs
                                    ),
                                  ),
                                  Container(
                                    height: 40.h,
                                    width: 250.w,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [

                                          Colors.blue.shade400,
                                        Colors.black,Colors.black,Colors.black

                                      ])
                                    ),
                                    child: Text(provider.bbcModel!.articles![index].title.toString(),style: TextStyle(
                                      color: Colors.white
                                    ),),
                                  )
                                ],
                              ),
                            ),
                          )
                        ),
                        );
                      } ),
                ),
                SizedBox(height: 10.h,),
                ListView.builder(
                    itemCount: provider.newsModel!.articles!.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: BouncingScrollPhysics(),
                    itemBuilder:(context,index){
                      return Padding(
                        padding:  EdgeInsets.all(8.0).r,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(10).r
                          ),
                          child: Padding(padding: EdgeInsets.all(8).r,
                            child: ListTile(
                              onTap: ()async{
                                await launchUrl(Uri.parse(provider.newsModel!.articles![index].url.toString()));
                              },
                              leading: Image.network(
                                provider.newsModel!.articles![index].urlToImage.toString(),
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset('assets/news.jpg');
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return SizedBox(
                                    width: 100, // Same dimensions as error state
                                    height: 100,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                fit: BoxFit.cover, // Optional: adjust to your needs
                              ),
                              title: Text(provider.newsModel!.articles![index].title.toString(),style: TextStyle(color: Colors.white),),
                              //subtitle: Text(provider.newsModel!.articles![index].author.toString(),style: TextStyle(color: Colors.white54),),
                            )
                          ),
                        ),
                      );
                    } ),
                            ],
                          ):
            Center(child:
              CircularProgressIndicator(color: Colors.blue,)
              ,),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OtherProfileScreen(user: user),
                    ),
                  );
                },
              );
            },
          ),
        );
      });
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