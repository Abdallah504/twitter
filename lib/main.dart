import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:twitter/controller/logic/auth-provider.dart';
import 'package:twitter/controller/logic/posts-provider.dart';
import 'package:twitter/view/screens/splash-screen.dart';

import 'firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context)=>AuthProvider()..getUserData()),
      ChangeNotifierProvider(create: (context)=>PostsProvider())
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

