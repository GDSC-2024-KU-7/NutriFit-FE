import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:nutrifit/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'recommend_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double bmr_value = 0.0;

  Future _info() async {
    final response = await http.get(
        Uri.parse(
            'https://nutrifit-server-h52zonluwa-du.a.run.app/users/profile'),
        headers: {
          'Authorization': 'Bearer ${await storage.read(key: 'jwtToken')}'
        });
    final datalist = jsonDecode(response.body);
    if (datalist['gender'] == '남') {
      bmr_value = 10 * datalist['weight'] +
          6.25 * datalist['height'] -
          5 * datalist['age'] +
          5;
      tdee = bmr_value * datalist['activity'];
      print(tdee);
    } else {
      bmr_value = 10 * datalist['weight'] +
          6.25 * datalist['height'] -
          5 * datalist['age'] -
          161;
      tdee = bmr_value * datalist['activity'];
      print(tdee);
    }
    return response.body;
  }

  Future _delete(food_list, index) async {
    final String url =
        'https://nutrifit-server-h52zonluwa-du.a.run.app/users/update/todaysfood';

    food_list.removeAt(index);
    final data = {'todaysfood': food_list.join('\\')};
    String jsonString = json.encode(data);

    print(jsonString);
    final http.Response response =
        await http.patch(Uri.parse(url), body: jsonString, headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer ${await storage.read(key: 'jwtToken')}'
    });
    if (response.statusCode != 200) {
      print('삭제 실패!${response.statusCode}');
    } else {
      print('삭제 성공');
      setState(() {});
    }
  }

  Future<void> _add(searchdata, double totalAmount, index) async {
    final String url_get =
        'https://nutrifit-server-h52zonluwa-du.a.run.app/users/profile';
    final String url_post =
        'https://nutrifit-server-h52zonluwa-du.a.run.app/users/update/todaysfood';

    final http.Response response_get = await http.get(Uri.parse(url_get),
        headers: {
          'Authorization': 'Bearer ${await storage.read(key: 'jwtToken')}'
        });
    Map<String, dynamic> dataMap = json.decode(response_get.body);
    List food = dataMap['todays'].split('\\');
    food[index] =
        '${searchdata.split('^')[0]}^${totalAmount}^${searchdata.split('^')[2]}^${searchdata.split('^')[3]}';
    final data = {
      "todaysfood": food.join('\\'),
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
      setState(() {});
      print(jsonString);
    }
  }

  Future food_info(String food_list) async {
    final String url =
        'https://nutrifit-server-h52zonluwa-du.a.run.app/food/todays';
    final data = {'todaysfood': food_list};
    final http.Response response = await http.post(Uri.parse(url),
        body: json.encode(data), headers: {"Content-Type": "application/json"});
    if (response.statusCode == 201) {
      print(response.body);
      return response.body;
    } else {
      print('실패${response.reasonPhrase}');
      print(food_list);
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return FutureBuilder(
        future: _info(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final list = jsonDecode(snapshot.data);
            final food_list = list['todays'].split('\\') == []
                ? ['']
                : list['todays'].split('\\');
            List today_nu = [
              {
                'label': '열량',
                'value': [list['today_energy'], 'kcal', 1, 1]
              },
              {
                'label': '단백질',
                'value': [list['today_protein'], 'g', 0.14, 4]
              },
              {
                'label': '지방',
                'value': [list['today_fat'], 'g', 0.21, 9]
              },
              {
                'label': '탄수화물',
                'value': [list['today_carbohydrate'], 'g', 0.65, 4]
              },
            ];

            return Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 30,
                    ), //수정-여백
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 150,
                                height: 150,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('kcal',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w300)),
                                    Text(
                                      '${(list['today_energy'] / tdee * 100).floor()}%',
                                      style: const TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.w900),
                                    ),
                                  ],
                                ),
                              ),
                              CircularStepProgressIndicator(
                                totalSteps: 100,
                                currentStep:
                                    (list['today_energy'] / tdee * 100).floor(),
                                stepSize: 10,
                                selectedColor: Colors.greenAccent,
                                unselectedColor: Colors.grey[200],
                                padding: 0,
                                width: 180,
                                height: 180,
                                selectedStepSize: 15,
                                roundedCap: (_, __) => true,
                              ),
                            ],
                          ),
                          Flexible(
                              fit: FlexFit.loose,
                              child: SizedBox(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Column(
                                      children: today_nu.map((item) {
                                        double percent = item['value'][0] /
                                            (tdee *
                                                item['value'][2] /
                                                item['value'][3]);
                                        if (percent > 1) {
                                          percent = 1;
                                        } else if (percent < 0) {
                                          percent = 0;
                                        }
                                        return SizedBox(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text('${item['label']} '),
                                                Text(
                                                  '${item['value'][0]}/${(tdee * item['value'][2] / item['value'][3]).floor()}',
                                                  style:
                                                      TextStyle(fontSize: 13),
                                                ),
                                                Text(
                                                  '(${item['value'][1]})',
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            LinearPercentIndicator(
                                              //padding: EdgeInsets.zero,
                                              width: 130,
                                              animation: true,
                                              animationDuration: 1200,
                                              lineHeight: 15,
                                              percent: percent,
                                              center: Text(
                                                '${(item['value'][0] / (tdee * item['value'][2] / item['value'][3]) * 100).floor()}%',
                                              ),
                                              linearGradient: LinearGradient(
                                                colors: [
                                                  Colors.red,
                                                  Colors.orange,
                                                  Colors.yellow,
                                                  Colors.green,
                                                  Colors.blue
                                                ],
                                              ),
                                              clipLinearGradient: true,
                                              barRadius: Radius.circular(16.0),
                                            ),
                                          ],
                                        ));
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      color: Color.fromARGB(255, 211, 210, 210),
                      height: 7,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          '오늘 먹은 음식',
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 160,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: food_list.length,
                              itemBuilder: (BuildContext context, int index) {
                                if (food_list[index] != '') {
                                  return FutureBuilder(
                                      future: food_info(food_list[index]),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          final mylist =
                                              jsonDecode(snapshot.data);
                                          List map_mylist = [
                                            {
                                              'label': '열량',
                                              'value': [
                                                mylist['energy_kcal'],
                                                'kcal'
                                              ]
                                            },
                                            {
                                              'label': '단백질',
                                              'value': [
                                                mylist['protein_g'],
                                                'g'
                                              ]
                                            },
                                            {
                                              'label': '지방',
                                              'value': [mylist['fat_g'], 'g']
                                            },
                                            {
                                              'label': '탄수화물',
                                              'value': [
                                                mylist['carbohydrate_g'],
                                                'g'
                                              ]
                                            },
                                          ];
                                          return Card(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      8.0, 0.0, 8.0, 0.0),
                                              child: SizedBox(
                                                width: 150,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            '${food_list[index].split('^')[2]}',
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        IconButton(
                                                          onPressed: () async {
                                                            await _delete(
                                                                food_list,
                                                                index);
                                                          },
                                                          padding:
                                                              EdgeInsets.zero,
                                                          visualDensity:
                                                              VisualDensity
                                                                  .compact,
                                                          icon:
                                                              Icon(Icons.close),
                                                          iconSize: 20,
                                                          color: Colors.red,
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: map_mylist
                                                            .map((data) {
                                                          if (data['value']
                                                                  [0] !=
                                                              -1) {
                                                            return Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    '${data['label']} : '),
                                                                Text(
                                                                    '${data['value'][0]} ${data['value'][1]}')
                                                              ],
                                                            );
                                                          } else {
                                                            return SizedBox(
                                                              height: 0,
                                                            );
                                                          }
                                                        }).toList()),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    SizedBox(
                                                        height: 15,
                                                        child: ElevatedButton(
                                                            onPressed: () {
                                                              _showDetailDialog(
                                                                  food_list[
                                                                      index],
                                                                  index);
                                                            },
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                                    backgroundColor:
                                                                        Color.fromARGB(
                                                                            255,
                                                                            247,
                                                                            241,
                                                                            241)),
                                                            child: Text(
                                                              '자세히 보기',
                                                              style: TextStyle(
                                                                  fontSize: 10),
                                                            )))
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        } else if (snapshot.hasError) {
                                          return Text('error');
                                        } else if (index == 1) {
                                          return Center(
                                              child: CircularProgressIndicator(
                                            color: Colors.grey,
                                          ));
                                        }
                                        return SizedBox();
                                      });
                                } else {
                                  return SizedBox(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('오늘 섭취한 음식이 없어요!'),
                                    ],
                                  ));
                                }
                              }),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      color: Color.fromARGB(255, 211, 210, 210),
                      height: 7,
                    ),
                    SizedBox(
                      height: 20,
                    ), //수정-버튼 여백
                    SizedBox(
                      height: 80, //높이 수정
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RecommendScreen(
                                        todays: list['todays'],
                                        tdee: tdee))).then((value) {
                              setState(() {});
                            });
                          },
                          child: Text('추천 음식 보기'),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ), //수정 - 여백
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('error');
          }
          return Center(
              child: CircularProgressIndicator(
            color: Colors.grey,
          ));
        });
  }

  void _showDetailDialog(String searchdata, index) {
    double once = double.parse(searchdata.split('^')[3]);
    double totalAmount = double.parse(searchdata.split('^')[1]);
    TextEditingController _consumedAmountController =
        TextEditingController(text: '${totalAmount}');

    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder(
            future: food_info(searchdata),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final food_info = jsonDecode(snapshot.data);
                List data = [
                  {
                    'label': '칼로리',
                    'value': [food_info["energy_kcal"], 'kcal']
                  },
                  {
                    'label': '단백질',
                    'value': [food_info['protein_g'], 'g']
                  },
                  {
                    'label': '지방',
                    'value': [food_info['fat_g'], 'g']
                  },
                  {
                    'label': '탄수화물',
                    'value': [food_info['carbohydrate_g'], 'g']
                  },
                ];
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
                              padding: const EdgeInsets.fromLTRB(
                                  16.0, 16.0, 16.0, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          '${searchdata.split('^')[2]}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 7,
                                  ),
                                  Text(
                                    '(현재 섭취량 : ${searchdata.split('^')[1]}g)',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Text('${totalAmount}g'),
                                      Text(
                                          '(1회 제공량*${(totalAmount / once).toStringAsFixed(2)})',
                                          style: TextStyle(fontSize: 10)),
                                      Text('당 함량'),
                                    ],
                                  ),
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
                              padding: const EdgeInsets.fromLTRB(
                                  16.0, 0, 16.0, 16.0),
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
                                                controller:
                                                    _consumedAmountController,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  hintText: '(1회 제공량 ${once}g)',
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
                                                onSubmitted: (value) {
                                                  setState(
                                                    () {
                                                      totalAmount =
                                                          double.parse(value);
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
                                                        _consumedAmountController
                                                                .text =
                                                            totalAmount
                                                                .toString();
                                                      });
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(0),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(0),
                                                      ),
                                                      alignment:
                                                          Alignment.center,
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
                                                        _consumedAmountController
                                                                .text =
                                                            totalAmount
                                                                .toString();
                                                      });
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(0),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(0),
                                                      ),
                                                      alignment:
                                                          Alignment.center,
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
                                                    _consumedAmountController
                                                        .text) ??
                                                0.0;
                                          });
                                          _add(searchdata, totalAmount, index);
                                          Navigator.pop(context);
                                        },
                                        child: Text('수정하기',
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
              } else if (snapshot.hasError) {
                return Text('error');
              }
              return Center(
                  child: CircularProgressIndicator(
                color: Colors.grey,
              ));
            });
      },
    );
  }
}
