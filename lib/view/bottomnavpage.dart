import 'package:flutter/material.dart';

class Bottomnavpage extends StatefulWidget {
  const Bottomnavpage({super.key});

  @override
  State<Bottomnavpage> createState() => _BottomnavpageState();
}

class _BottomnavpageState extends State<Bottomnavpage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bottom Navigation Example')),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
