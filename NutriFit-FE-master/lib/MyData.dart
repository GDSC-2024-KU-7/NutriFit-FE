import 'package:flutter/foundation.dart';

class MyData with ChangeNotifier {
  var _selectedIndex = 1;
  List<String> myDataList = [];

  int get selectedIndex => _selectedIndex;

  void updateSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners(); // 상태 변경을 감지한 위젯들에게 알리기
  }

  void addData(String newData) {
    myDataList.add(newData);
    notifyListeners();
  }
} //#수정
