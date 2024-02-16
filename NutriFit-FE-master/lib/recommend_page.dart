import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'main.dart';
import 'package:http/http.dart' as http;

class RecommendScreen extends StatefulWidget {
  String todays = '';
  double tdee = 0.0;
  RecommendScreen({required this.todays, required this.tdee});

  @override
  _RecommendScreenState createState() =>
      _RecommendScreenState(todays: todays, tdee: tdee);
}

class _RecommendScreenState extends State<RecommendScreen> {
  String todays = '';
  double tdee = 0.0;
  _RecommendScreenState({required this.todays, required this.tdee});
  List<dynamic>? data;
  TextEditingController _consumedAmountController = TextEditingController();
  double totalAmount = 100.0;
  List<String> recommendationData = [];

  Future _recommend() async {
    final String url =
        'https://nutrifit-server-h52zonluwa-du.a.run.app/food/todays';
    final Map<String, String> body = {'todaysfood': todays};

    final http.Response response = await http.post(
      Uri.parse(url),
      body: body,
    );
    Map<String, dynamic> originalData = json.decode(response.body);
    originalData['energy_kcal'] = tdee - originalData['energy_kcal'];
    originalData['protein_g'] = (tdee / 4 * 0.14) - originalData['protein_g'];
    originalData['fat_g'] = (tdee / 9 * 0.21) - originalData['fat_g'];
    originalData['carbohydrate_g'] =(tdee / 4 * 0.65) - originalData['carbohydrate_g'];
    originalData["nutrifit_percent"] = [
      originalData['energy_kcal'] / (tdee),
      originalData['protein_g'] / (tdee / 4 * 0.14),
      originalData['fat_g'] / (tdee / 9 * 0.21),
      originalData['carbohydrate_g'] / (tdee / 4 * 0.65)
    ];

    String jsonString = jsonEncode(originalData);
    final String url_recommend =
        'https://nutrifit-server-h52zonluwa-du.a.run.app/food/recommendfood';
    final http.Response recommend_response = await http.post(
        Uri.parse(url_recommend),
        body: jsonString,
        headers: {"Content-Type": "application/json"});

    if (recommend_response.statusCode == 201) {
      if (mounted) {
        data = jsonDecode(recommend_response.body);
      }
      List<String> foodNames = [];
      for (var item in data!) {
        String foodName = item['food_name'];
        foodNames.add(foodName);
        recommendationData = foodNames;
      }
      return recommend_response.body;
    } else {
      print(jsonEncode(originalData));
      print('추천 실패: ${recommend_response.reasonPhrase}');
    }
  }

  Future<void> _add(searchdata, double totalAmount, double once) async {
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
    if (response_post.statusCode != 200) {
      print('update 실패!${response_post.statusCode}');
    } else {
      print('update 성공!');
      print(jsonString);
    }
  }

  //추천 음식 목록
  @override
  void initState() {
    super.initState();
    _recommend();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _recommend(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text('오늘의 추천 음식'),
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              body: _buildRecommendations(),
            );
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Center(
              child: Text('오류 발생!'),
            );
          }
          return Scaffold(
            appBar: AppBar(),
            body: Center(
                child: CircularProgressIndicator(
              color: Colors.grey,
            )),
          );
        });
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
            _showDetailDialog(data![index]);
          },
          child: Container(
            margin: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 248, 199, 185), // deepOrange 색상
              borderRadius: BorderRadius.circular(8.0), // 네모 버튼 형태로 만들기
            ),
            child: AspectRatio(
              aspectRatio: 1.5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    recommendationData[index],
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDetailDialog(searchdata) {
    double once = searchdata['once'].toDouble();
    totalAmount = once;
    _consumedAmountController = TextEditingController(text: '${totalAmount}');

    // searchdata['once'] -> '1회 제공량';
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
                          Text('${searchdata['food_name']}'),
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
                            }).toList())), //영양 성분 정보
                    SizedBox(
                      height: 14,
                    ), //blank
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
                                onPressed: () async {
                                  //사용자가 입력한 값을 total Amount로 변환
                                  setState(() {
                                    totalAmount = double.tryParse(
                                            _consumedAmountController.text) ??
                                        0.0;
                                  });
                                  await _add(searchdata, totalAmount, once);
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
