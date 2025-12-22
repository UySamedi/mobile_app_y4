import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'ProfileScreen.dart';

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    HomeScreen(),
    const Center(child: Text('My Orders Screen', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Saved Items Screen', style: TextStyle(fontSize: 24))),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            showUnselectedLabels: true,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(_selectedIndex == 0 ? Icons.home : Icons.home_outlined),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(_selectedIndex == 1 ? Icons.confirmation_number : Icons.confirmation_number_outlined),
                ),
                label: 'My Orders',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(_selectedIndex == 2 ? Icons.bookmark : Icons.bookmark_add_outlined),
                ),
                label: 'Save',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(_selectedIndex == 3 ? Icons.person : Icons.person_outline),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
