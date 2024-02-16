import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutrifit/Homepage.dart';
import 'package:nutrifit/Search_screen.dart';
import 'mypage.dart';
import 'MyData.dart'; //수정

class MyHomePage extends StatefulWidget {
  var selectedIndex = 1;
  MyHomePage({required this.selectedIndex});
  @override
  State<MyHomePage> createState() =>
      _MyHomePageState(selectedIndex: selectedIndex);
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 1;
  late MyData myData; //수정

  @override
  void initState() {
    super.initState();
    myData = MyData(); // MyData 클래스의 인스턴스 생성
  } //수정

  _MyHomePageState({required this.selectedIndex});

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    widget.selectedIndex = selectedIndex;
    MyData myData = Provider.of<MyData>(context, listen: false); //수정
    myData.updateSelectedIndex(selectedIndex); //수정
    myData.updateSelectedIndex(index); //수정
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
            style: TextStyle(fontFamily: 'Italianno', fontSize: 50), //#수정
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
