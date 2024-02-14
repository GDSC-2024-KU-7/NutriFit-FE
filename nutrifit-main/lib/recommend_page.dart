import 'package:flutter/material.dart';
// import 'dart:async';
// import 'dart:convert';
// import 'main.dart';
// import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    home: RecommendPage(),
  ));
}

class RecommendPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RecommendScreen();
  }
}

class RecommendScreen extends StatefulWidget {
  RecommendScreen();

  @override
  _RecommendScreenState createState() => _RecommendScreenState();
}

class _RecommendScreenState extends State<RecommendScreen> {
  List<dynamic>? data;
  TextEditingController _consumedAmountController = TextEditingController();
  double totalAmount = 100.0;

  List<String> recommendationData = [
    '음식1',
    '음식2',
    '음식3',
    '음식4',
    '음식5',
    '음식6',
    '음식7',
    '음식8',
    '음식9',
    '음식10',
    '음식11',
  ]; //추천 음식 목록

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('오늘의 음식 추천'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Expanded(
        child: _buildRecommendations(), //추천 음식 목록 함수
      ),
    );
  }

  Widget _buildRecommendations() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 한 줄에 두 개의 항목을 표시
        crossAxisSpacing: 0.0, // 각 항목 사이의 가로 간격
        mainAxisSpacing: 0.0, // 각 항목 사이의 세로 간격
      ),
      itemCount: recommendationData.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            _showFoodDetails(recommendationData[index]);
          },
          child: Container(
            margin: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 248, 199, 185), // deepOrange 색상
              borderRadius: BorderRadius.circular(8.0), // 네모 버튼 형태로 만들기
            ),
            child: AspectRatio(
              aspectRatio: 1.5,
              child: Center(
                child: Text(
                  recommendationData[index],
                  style: TextStyle(
                    color: Colors.black, // 텍스트 색상을 흰색으로 지정
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // void _showFoodDetails(searchdata) {
  //   _consumedAmountController = TextEditingController();
  //   totalAmount = 100.0;

  // searchdata['food_name'] -> '음식 이름';
  // searchdata['energy_kcal'] -> '칼로리';
  // searchdata['water_g'] -> '수분';
  // searchdata['protein_g'] -> '단백질';
  // searchdata['fat_g'] -> '지방';
  // searchdata['carbohydrate_g'] -> '탄수화물';
  // 나머지 정보도 보려면 print(searchdata)하면 됨
  //   List<Map<String, String?>> data = [
  //     {'label': '칼로리', 'value': '${searchdata["energy_kcal"]} kcal'},
  //     {'label': '수분', 'value': '${searchdata['water_g']} g'},
  //     {'label': '단백질', 'value': '${searchdata['protein_g']} g'},
  //     {'label': '지방', 'value': '${searchdata['fat_g']} g'},
  //     {'label': '탄수화물', 'value': '${searchdata['carbohydrate_g']} g'},
  //   ];

  //   Future<void> _add(searchdata, double totalAmount) async {
  //     final String url_get =
  //         'https://nutrifit-server-h52zonluwa-du.a.run.app/users/profile';
  //     final String url_post =
  //         'https://nutrifit-server-h52zonluwa-du.a.run.app/users/update';

  //     final http.Response response_get = await http.get(Uri.parse(url_get),
  //         headers: {
  //           'Authorization': 'Bearer ${await storage.read(key: 'jwtToken')}'
  //         });
  //     Map<String, dynamic> dataMap = json.decode(response_get.body);
  //     final data = {
  //       //서버 바뀌면 다시..
  //       "todays": dataMap['todays'] + '/' + searchdata['food_name'],
  //       "today_energy": dataMap['today_energy'] +
  //           '${searchdata['energy_kcal'] * (totalAmount / 100)}',
  //       //아마 int랑 string이랑 더할려고 한다고 오류 날 듯..
  //       "today_water": dataMap['today_water'] +
  //           '${searchdata['water_g'] * (totalAmount / 100)}',
  //       "today_protein": dataMap['today_protein'] +
  //           '${searchdata['protein_g'] * (totalAmount / 100)}',
  //       "today_fat": dataMap['today_fat'] +
  //           '${searchdata['fat_g'] * (totalAmount / 100)}',
  //       "today_carbohydrate": dataMap['today_carbohydrate'] +
  //           '${searchdata['carbohydrate_g'] * (totalAmount / 100)}',
  //     };
  //     String jsonString = json.encode(data);
  //     final http.Response response_post =
  //         await http.patch(Uri.parse(url_post), body: jsonString, headers: {
  //       "Content-Type": "application/json",
  //       'Authorization': 'Bearer ${await storage.read(key: 'jwtToken')}'
  //     });
  //     if (response_post.statusCode != 200) {
  //       print('update 실패!${response_post.statusCode}');
  //     } else {
  //       print('update 성공!');
  //     }
  //   }

  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(
  //           builder: (BuildContext context, StateSetter setState) {
  //         return Dialog(
  //           child: Container(
  //               width: 300,
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.all(Radius.circular(10)),
  //               ),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Padding(
  //                     padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text('${searchdata['food_name']}'),
  //                         SizedBox(
  //                           height: 10,
  //                         ),
  //                         Text(totalAmount == 100.0
  //                             ? '1회 제공량 (100g) 당 함량'
  //                             : '(${totalAmount}g)당 함량'),
  //                       ],
  //                     ),
  //                   ), //사진+음식이름
  //                   //blank
  //                   SizedBox(
  //                       child: Column(
  //                           mainAxisSize: MainAxisSize.min,
  //                           children: data.map((data) {
  //                             return Padding(
  //                               padding: const EdgeInsets.fromLTRB(
  //                                   16.0, 8.0, 8.0, 2.0),
  //                               child: Row(
  //                                 mainAxisAlignment:
  //                                     MainAxisAlignment.spaceBetween,
  //                                 children: [
  //                                   Text('${data['label']}'),
  //                                   Text(
  //                                       '${double.parse((data['value']!.split(' '))[0]) * (totalAmount / 100)}'
  //                                       ' ${data['value']!.split(' ')[1]}')
  //                                 ],
  //                               ),
  //                             );
  //                           }).toList())), //영양 성분 정보
  //                   SizedBox(
  //                     height: 14,
  //                   ), //blank
  //                   Padding(
  //                     padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
  //                     child: Container(
  //                       decoration: BoxDecoration(
  //                         border: Border.all(
  //                           color: Colors.black,
  //                           width: 1,
  //                         ),
  //                       ),
  //                       child: SizedBox(
  //                         width: 250,
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.end,
  //                           children: [
  //                             Row(
  //                                 mainAxisAlignment:
  //                                     MainAxisAlignment.spaceAround,
  //                                 children: [
  //                                   Text(
  //                                     '총 섭취량',
  //                                     style: TextStyle(fontSize: 15),
  //                                   ),
  //                                   SizedBox(
  //                                     width: 125,
  //                                     height: 20,
  //                                     child: TextField(
  //                                       style: TextStyle(fontSize: 12),
  //                                       controller: _consumedAmountController,
  //                                       keyboardType: TextInputType.number,
  //                                       decoration: InputDecoration(
  //                                         hintText: '(1회 제공량 100g)',
  //                                         contentPadding: EdgeInsets.symmetric(
  //                                             vertical: 0, horizontal: 13),
  //                                         border: OutlineInputBorder(
  //                                           borderSide: BorderSide(
  //                                             color: Colors.black,
  //                                             width: 1.0,
  //                                           ),
  //                                         ),
  //                                       ),
  //                                       onSubmitted: (value) {
  //                                         setState(
  //                                           () {
  //                                             totalAmount = double.parse(value);
  //                                           },
  //                                         );
  //                                       },
  //                                     ),
  //                                   ),
  //                                   Row(
  //                                     children: [
  //                                       SizedBox(
  //                                         width: 10,
  //                                         height: 20,
  //                                         child: InkWell(
  //                                           onTap: () {
  //                                             // 버튼 클릭 시 totalAmount 변수 값 증가
  //                                             setState(() {
  //                                               totalAmount += 100;
  //                                               _consumedAmountController.text =
  //                                                   totalAmount.toString();
  //                                             });
  //                                           },
  //                                           child: Container(
  //                                             padding: EdgeInsets.all(0),
  //                                             decoration: BoxDecoration(
  //                                               color: Colors.white,
  //                                               borderRadius:
  //                                                   BorderRadius.circular(0),
  //                                             ),
  //                                             alignment: Alignment.center,
  //                                             child: Icon(
  //                                               Icons.arrow_drop_up,
  //                                               size: 20,
  //                                               color: Colors.red,
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       ),
  //                                       SizedBox(
  //                                         width: 5,
  //                                       ),
  //                                       SizedBox(
  //                                         width: 10,
  //                                         height: 20,
  //                                         child: InkWell(
  //                                           onTap: () {
  //                                             // 버튼 클릭 시 totalAmount 변수 값 증가
  //                                             setState(() {
  //                                               totalAmount -= 100;
  //                                               _consumedAmountController.text =
  //                                                   totalAmount.toString();
  //                                             });
  //                                           },
  //                                           child: Container(
  //                                             padding: EdgeInsets.all(0),
  //                                             decoration: BoxDecoration(
  //                                               color: Colors.white,
  //                                               borderRadius:
  //                                                   BorderRadius.circular(0),
  //                                             ),
  //                                             alignment: Alignment.center,
  //                                             child: Icon(
  //                                               Icons.arrow_drop_down,
  //                                               size: 20,
  //                                               color: Colors.red,
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                 ]),
  //                             ElevatedButton(
  //                               onPressed: () {
  //                                 //사용자가 입력한 값을 total Amount로 변환
  //                                 setState(() {
  //                                   totalAmount = double.tryParse(
  //                                           _consumedAmountController.text) ??
  //                                       0.0;
  //                                 });
  //                                 _add(searchdata, totalAmount);
  //                                 Navigator.pop(context);
  //                               },
  //                               child: Text('추가하기',
  //                                   style: TextStyle(
  //                                     fontSize: 15,
  //                                   )),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               )),
  //         );
  //       });
  //     },
  //   );
  // }
  void _showFoodDetails(String word) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SingleChildScrollView(
            child: Container(
                width: 300,
                height: 366,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 33,
                      width: 300,
                    ), //blank
                    SizedBox(
                      height: 95,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 18,
                          ),
                          Image(
                            image: AssetImage('assets/images/m_burger.png'),
                            width: 95,
                            height: 95,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(
                            width: 14,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 30,
                                  child: Text(
                                    '음식 이름',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                                SizedBox(
                                  height: 65,
                                ),
                              ],
                            ),
                          ), //text
                          SizedBox(
                            width: 43,
                          ),
                        ],
                      ),
                    ), //사진+음식이름
                    SizedBox(
                      height: 18,
                    ), //blank
                    SizedBox(
                      height: 108,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 18,
                          ),
                          SizedBox(
                            width: 174,
                            child: Text(
                                '1회 제공량 (100g) 당 함량\n'
                                '에너지\n'
                                '수분\n'
                                '단백질\n'
                                '지방\n'
                                '탄수화물\n',
                                style: TextStyle(fontSize: 12)),
                          ),
                          SizedBox(
                            width: 40,
                          ),
                          Expanded(
                            child: Text(
                              '\n'
                              'kcal\n'
                              'g\n'
                              'g\n'
                              'g\n'
                              'g\n',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          SizedBox(
                            width: 23,
                          ),
                        ],
                      ),
                    ), //영양 성분 정보
                    SizedBox(
                      height: 14,
                    ), //blank
                    Expanded(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 14,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            child: SizedBox(
                              width: 250,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 11,
                                  ), //공백
                                  SizedBox(
                                    height: 20,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 10,
                                        ), //공백
                                        SizedBox(
                                          width: 62,
                                          child: Text(
                                            '총 섭취량',
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ), //총 섭취량 텍스트
                                        SizedBox(
                                          width: 5,
                                        ), //사이 공백
                                        SizedBox(
                                          width: 125,
                                          height: 20,
                                          child: TextField(
                                            style: TextStyle(fontSize: 12),
                                            controller:
                                                _consumedAmountController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              hintText: '(1회 제공량 100g)',
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 0,
                                                      horizontal: 13),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.black,
                                                  width: 1.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 7,
                                        ),
                                        SizedBox(
                                          width: 10,
                                          height: 20,
                                          child: InkWell(
                                            onTap: () {
                                              // 버튼 클릭 시 totalAmount 변수 값 증가
                                              setState(() {
                                                totalAmount += 100;
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
                                                totalAmount -= 100;
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
                                        SizedBox(
                                          width: 8,
                                        ),
                                      ],
                                    ),
                                  ), //총 섭취량 정보,
                                  SizedBox(
                                    height: 9,
                                  ), //공백
                                  SizedBox(
                                    height: 26,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 125,
                                        ),
                                        SizedBox(
                                          width: 115,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              //사용자가 입력한 값을 total Amount로 변환
                                              setState(() {
                                                totalAmount = double.tryParse(
                                                        _consumedAmountController
                                                            .text) ??
                                                    0.0;
                                              });
                                              //최종 totalAmount를 간직한채 Dialog를 닫음.
                                              Navigator.pop(
                                                  context, totalAmount);
                                            },
                                            child: Text('추가하기',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                )),
                                          ),
                                        ), //추가하기 버튼
                                        SizedBox(
                                          width: 8,
                                        ),
                                      ],
                                    ),
                                  ), //추가하기 칸
                                  SizedBox(
                                    height: 14,
                                  ), //마지막 공백
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 14,
                          ),
                        ],
                      ),
                    ), //추가 박스
                    SizedBox(
                      height: 16,
                    ), //blank
                  ],
                )),
          ),
        );
      },
    );
  }
}
