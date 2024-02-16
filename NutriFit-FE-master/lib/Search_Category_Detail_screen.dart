import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nutrifit/MyData.dart'; //수정
import 'main.dart';
import 'package:provider/provider.dart'; //수정

void main(item) {
  runApp(MaterialApp(
    home: DetailScreen(word: item),
  ));
}

class DetailScreen extends StatelessWidget {
  final String word;

  DetailScreen({required this.word});

  final List<String> items = ['apple', 'banana', 'orange', 'grape'];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyData>(
      create: (context) => MyData(),
      child: DetailPage(words: items, word: word),
    ); //수정
  }
}

class DetailPage extends StatefulWidget {
  final List<String> words;
  final String word;

  DetailPage({required this.words, required this.word});

  @override
  _DetailPageState createState() => _DetailPageState(word: word);
}

class _DetailPageState extends State<DetailPage> {
  TextEditingController _searchController = TextEditingController();
  List<String>? _matchingWords;
  List<dynamic>? data;
  TextEditingController _consumedAmountController = TextEditingController();
  double totalAmount = 100.0;
  final String word;

  Timer? _searchTimer;

  _DetailPageState({required this.word});

  Future<void> search(String food_name, String group) async {
    final String url =
        'https://nutrifit-server-h52zonluwa-du.a.run.app/food/foodSearch';

    final http.Response response = await http.get(
      Uri.parse('${url}?food_name=${food_name}&DB_group=${group}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body);
      });
      List<String> foodNames = [];
      for (var item in data!) {
        String foodName = item['food_name'];
        foodNames.add(foodName);
      }
      setState(() {
        _matchingWords = foodNames as List<String>;
      });
    } else {
      print('검색 실패: ${response.reasonPhrase}');
    }
  }

  void _searchWords(String query) {
    // 이전 타이머가 있으면 취소
    _searchTimer?.cancel();

    // 새로운 타이머 시작
    _searchTimer = Timer(Duration(milliseconds: 500), () {
      print(word);
      // 500ms 후에 search 함수 호출
      search(query, word);
    });
  }

  Future<void> _add(
      //수정 mydata MyData
      searchdata,
      double totalAmount,
      double once,
      MyData myData) async {
    final String url_get =
        'https://nutrifit-server-h52zonluwa-du.a.run.app/users/profile';
    final String url_post =
        'https://nutrifit-server-h52zonluwa-du.a.run.app/users/update/todaysfood';

    final http.Response response_get = await http.get(Uri.parse(url_get),
        headers: {
          'Authorization': 'Bearer ${await storage.read(key: 'jwtToken')}'
        });
    Map<String, dynamic> dataMap = json.decode(response_get.body);
    final data = {
      "todaysfood": (dataMap['todays'] == '' ? '' : dataMap['todays'] + '\\') +
          '${searchdata['NO']}^${totalAmount}^${searchdata['food_name']}^${searchdata['once']}',
    };
    String jsonString = json.encode(data);
    final http.Response response_post =
        await http.patch(Uri.parse(url_post), body: jsonString, headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer ${await storage.read(key: 'jwtToken')}'
    });
    MyData myData = Provider.of<MyData>(context, listen: false); //수정

    if (response_post.statusCode != 200) {
      print('추가하기 실패 ${response_post.statusCode}');
    } else {
      print('추가하기 성공!');
      print(jsonString);
    }
    myData.addData(
        '${searchdata['NO']}_${totalAmount}_${searchdata['food_name']}_${searchdata['once']}'); //#수정
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //     title: Center(
      //         child: Text(
      //   'NutriFit',
      //   style: TextStyle(fontSize: 30),
      // ))),
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(labelText: '${word} 검색'),
              onChanged: (query) {
                _searchWords(query);
              },
            ),
            Expanded(
              child: _matchingWords != null
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: _matchingWords!.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                  flex: 2,
                                  child: Text(
                                    _matchingWords![index],
                                    overflow: TextOverflow.ellipsis,
                                  )),
                              Flexible(
                                  flex: 1,
                                  child: Text(
                                    data![index]['region'],
                                    style: TextStyle(fontSize: 10),
                                    overflow: TextOverflow.ellipsis,
                                  ))
                            ],
                          ),
                          onTap: () {
                            _showDetailDialog(data![index]);
                          },
                        );
                      },
                    )
                  : Center(
                      child: Text(''),
                      // Text('Detail for $word'),
                    ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.manage_search),
      //       label: 'search',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: 'my page',
      //     )
      //   ],
      // ),
    );
  }

  void _showDetailDialog(searchdata) {
    double once = searchdata['once'].toDouble();
    totalAmount = once;
    _consumedAmountController = TextEditingController(text: '${totalAmount}');

    // searchdata['food_name'] -> '음식 이름';
    // searchdata['energy_kcal'] -> '칼로리';
    // searchdata['water_g'] -> '수분';
    // searchdata['protein_g'] -> '단백질';
    // searchdata['fat_g'] -> '지방';
    // searchdata['carbohydrate_g'] -> '탄수화물';
    // 나머지 정보도 보려면 print(searchdata)하면 됨
    List data = [
      {
        'label': '칼로리',
        'value': [searchdata["energy_kcal"], 'kcal']
      },
      {
        'label': '단백질',
        'value': [searchdata['protein_g'], 'g']
      },
      {
        'label': '지방',
        'value': [searchdata['fat_g'], 'g']
      },
      {
        'label': '탄수화물',
        'value': [searchdata['carbohydrate_g'], 'g']
      },
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Dialog(
            child: Container(
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                  child: Text('${searchdata['food_name']}')),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(totalAmount == once
                              ? '1회 제공량(${once}g)당 함량'
                              : '${totalAmount}g (1회 제공량 * ${(totalAmount / once).toStringAsFixed(2)}) 당 함량'),
                        ],
                      ),
                    ), //사진+음식이름
                    //blank
                    SizedBox(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: data.map((data) {
                              if (data['value'][0] != -1) {
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16.0, 8.0, 8.0, 2.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${data['label']}'),
                                      Text(
                                          '${(data['value'][0] * (totalAmount / once)).toStringAsFixed(2)}'
                                          ' ${data['value'][1]}')
                                    ],
                                  ),
                                );
                              } else {
                                return SizedBox(
                                  height: 0,
                                );
                              }
                            }).toList())), //영양 성분 정보                    SizedBox(
                    SizedBox(
                      height: 14,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                        child: SizedBox(
                          width: 250,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      '총 섭취량',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    SizedBox(
                                      width: 125,
                                      height: 20,
                                      child: TextField(
                                        style: TextStyle(fontSize: 12),
                                        controller: _consumedAmountController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          hintText: '(1회 제공량 100g)',
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 13),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.black,
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                        onSubmitted: (value) {
                                          setState(
                                            () {
                                              totalAmount = double.parse(value);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 10,
                                          height: 20,
                                          child: InkWell(
                                            onTap: () {
                                              // 버튼 클릭 시 totalAmount 변수 값 증가
                                              setState(() {
                                                totalAmount += once;
                                                _consumedAmountController.text =
                                                    totalAmount.toString();
                                              });
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(0),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(0),
                                              ),
                                              alignment: Alignment.center,
                                              child: Icon(
                                                Icons.arrow_drop_up,
                                                size: 20,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                          width: 10,
                                          height: 20,
                                          child: InkWell(
                                            onTap: () {
                                              // 버튼 클릭 시 totalAmount 변수 값 증가
                                              setState(() {
                                                totalAmount -= once;
                                                _consumedAmountController.text =
                                                    totalAmount.toString();
                                              });
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(0),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(0),
                                              ),
                                              alignment: Alignment.center,
                                              child: Icon(
                                                Icons.arrow_drop_down,
                                                size: 20,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ]),
                              ElevatedButton(
                                onPressed: () {
                                  //사용자가 입력한 값을 total Amount로 변환
                                  setState(() {
                                    totalAmount = double.tryParse(
                                            _consumedAmountController.text) ??
                                        0.0;
                                  });
                                  _add(searchdata, totalAmount, once,
                                      MyData()); //수정
                                  Navigator.pop(context);
                                },
                                child: Text('추가하기',
                                    style: TextStyle(
                                      fontSize: 15,
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          );
        });
      },
    );
  }
}
