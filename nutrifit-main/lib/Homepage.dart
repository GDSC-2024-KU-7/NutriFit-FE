import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:nutrifit/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:nutrifit/recommend_page.dart';

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
    final data = {
      {'todays': food_list.join(',')}
    };
    String jsonString = json.encode(data);

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

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return FutureBuilder(
        future: _info(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final list = jsonDecode(snapshot.data);
            final food_list = list['todays'].split(',');
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
                                              percent: item['value'][0] /
                                                          (tdee *
                                                              item['value'][2] /
                                                              item['value']
                                                                  [3]) >
                                                      1
                                                  ? 1
                                                  : item['value'][0] /
                                                      (tdee *
                                                          item['value'][2] /
                                                          item['value'][3]),
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
                          height: 150,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: food_list.length,
                              itemBuilder: (BuildContext context, int index) {
                                if (food_list[index] != '') {
                                  return Card(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                                width: 100,
                                                child: Center(
                                                    child: Text(
                                                  '${food_list[index].split('_')[0]}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ))),
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  food_list.removeAt(index);
                                                  _delete(food_list, index);
                                                  print(food_list);
                                                });
                                              },
                                              padding: EdgeInsets.zero,
                                              visualDensity:
                                                  VisualDensity.compact,
                                              icon: Icon(Icons.close),
                                              iconSize: 20,
                                              color: Colors.red,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                            height: 15,
                                            child: ElevatedButton(
                                                onPressed: () {},
                                                child: Text(
                                                  '자세히 보기',
                                                  style:
                                                      TextStyle(fontSize: 10),
                                                )))
                                      ],
                                    ),
                                  );
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
                      height: 30,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          '오늘의 추천 음식',
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      height: 50,
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RecommendPage()));
                          },
                          child: Text('추천 음식 보기'),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('error');
          }
          return CircularProgressIndicator();
        });
  }
}

class SecondRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
        appBar: AppBar(
          title: Text('M-burger 의 성분'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
              child: Container(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Text(
                      '열량 :',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      '탄수화물 :',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      '단백질 :',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      '지방 :',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      '당 :',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                            width: 30,
                            height: 30,
                            color: const Color.fromARGB(255, 215, 209, 209),
                            child: IconButton(
                                onPressed: () {
                                  appState.add();
                                },
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                icon: Icon(Icons.add))),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(appState.count.toString()),
                        ),
                        Container(
                            width: 30,
                            height: 30,
                            color: const Color.fromARGB(255, 215, 209, 209),
                            child: IconButton(
                                onPressed: () {
                                  appState.sub();
                                },
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                icon: Icon(Icons.remove)))
                      ],
                    ),
                  ]),
            ),
          )),
        ));
  }
}
