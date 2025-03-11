
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../../controller/logic/auth-provider.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
        builder: (context,provider,_){
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/icon.png',height: 248.h,width: 248.w,),
              SizedBox(height: 20.h,),
              SignInButton(
                Buttons.google,
                onPressed: () {
                  provider.signInWithGoogle(context);
                },
              )
            ],
          ),
        ),
      );
    });
  }
}
