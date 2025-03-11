import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../controller/logic/auth-provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, auth, _) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Image.asset('assets/twitter.png'),
          centerTitle: true,
          leading: auth.person?.photoURL != null
              ? CircleAvatar(
            backgroundImage: NetworkImage(auth.person!.photoURL!),
          )
              : CircleAvatar(
            child: Icon(Icons.person, color: Colors.white),
            backgroundColor: Colors.grey,
          ),
        ),
        body: SingleChildScrollView(
          child: ListView.builder(
              itemCount: 20,
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context,index){
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 200.h,// will be deleted
                    width: 414.w,
                    color: Colors.red,
                  ),
                );
              }),
        ),
        floatingActionButton: FloatingActionButton(onPressed: (){},
        child: Image.asset('assets/text.png'),
          backgroundColor: Colors.blue,

        ),
      );
    });
  }
}
