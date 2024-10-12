import 'package:flutter/material.dart';
import 'bottom_navigation_bar.dart';

class MainScreenWrapper extends StatefulWidget {
  final List<Widget> screens;
  final List<String> titles;

  const MainScreenWrapper({
    Key? key,
    required this.screens,
    required this.titles,
  }) : super(key: key);

  @override
  _MainScreenWrapperState createState() => _MainScreenWrapperState();
}

class _MainScreenWrapperState extends State<MainScreenWrapper> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titles[_selectedIndex]),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, 'settings_screen'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: widget.screens,
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
