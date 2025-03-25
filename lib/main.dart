import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:twitter/controller/logic/auth-provider.dart';
import 'package:twitter/controller/logic/posts-provider.dart';
import 'package:twitter/view/screens/splash-screen.dart';

import 'controller/logic/news-provider.dart';
import 'firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(url: 'https://euclgidlzogbcibgzrtg.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV1Y2xnaWRsem9nYmNpYmd6cnRnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI3MjY4MTcsImV4cCI6MjA1ODMwMjgxN30.vo87lKsgE8ZAm2qTjIs5-sIA1XVsOxWRSMJ65uynmek');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context)=>AuthProvider()..getUserData()),
      ChangeNotifierProvider(create: (context)=>PostsProvider()),
      ChangeNotifierProvider(create: (context)=>NewsProvider()..gettingNews())
    ],
    child:  ScreenUtilInit(
        designSize: const Size(360, 690),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context,_){
    return MaterialApp(
    title: 'Twitter',
    debugShowCheckedModeBanner: false, navigatorKey: navigatorKey,
      theme: ThemeData(

    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    ),
    home: SplashScreen(),
    );
    },
    ),
    );
  }
}

