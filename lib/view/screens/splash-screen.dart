import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';// Ensure this path is correct
import 'package:provider/provider.dart';
import 'package:twitter/view/screens/auth-screen.dart';
import 'package:twitter/view/screens/home-screen.dart';
import 'package:twitter/view/shared/colors.dart';

import 'main-screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    auth.authStateChanges().listen((User? user) {
      if (mounted) {
        Future.delayed(const Duration(seconds: 3), () async {
          if (user == null) {
            // Navigate to Auth Screen if no user is logged in
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => AuthScreen()));
          } else {
            // Fetch user data before navigating to HomeScreen
            // final authProvider = AuthProvider();
            // await authProvider.getUserData();

            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => MainScreen()));
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBlue,
      body: Center(
        child: Image.asset('assets/icon.png'),
      ),
    );
  }
}
