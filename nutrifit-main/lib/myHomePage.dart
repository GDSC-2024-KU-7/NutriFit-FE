import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutrifit/Homepage.dart';
import 'package:nutrifit/Search_screen.dart';
import 'mypage.dart';

class MyHomePage extends StatefulWidget {
  var selectedIndex = 1;
  MyHomePage({required this.selectedIndex});
  @override
  State<MyHomePage> createState() =>
      _MyHomePageState(selectedIndex: selectedIndex);
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 1;
  _MyHomePageState({required this.selectedIndex});
  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    widget.selectedIndex = selectedIndex;
  }

  final _pages = [SearchPage(), HomePage(), Mypage()];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didpop) {
        if (didpop) {
          return;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Center(
              child: Text(
            'NutriFit',
            style: TextStyle(fontSize: 30),
          )),
          automaticallyImplyLeading: false,
        ),
        body: _pages[selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.manage_search),
              label: 'search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'my page',
            )
          ],
          currentIndex: selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
