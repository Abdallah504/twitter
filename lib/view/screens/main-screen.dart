import 'package:flutter/material.dart';
import 'package:twitter/view/screens/profile-screen.dart';
import 'package:twitter/view/screens/search.screen.dart';

import 'chat-screen.dart';
import 'home-screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
    List<Widget> _widgetOptions = <Widget> [
    HomeScreen(),
    SearchScreen(),
    ChatScreen(),

    ProfileScreen()


  ];

  void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(

        backgroundColor: Colors.black,
        elevation: 4,

        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home,color: Colors.blue.shade700,),
              label: 'Home',

              backgroundColor: Colors.black,

          ),
          BottomNavigationBarItem(icon: Icon(
            Icons.search,color: Colors.blue.shade700,)
              ,label: 'Search',
              backgroundColor: Colors.black),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_sharp,color: Colors.blue.shade700,),
              label: 'Chat',
              backgroundColor: Colors.black),

          BottomNavigationBarItem(
              icon: Icon(Icons.person,color: Colors.blue.shade700,),
              label: 'Profile',
              backgroundColor: Colors.black),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
