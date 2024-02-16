import 'dart:convert';
import 'create_profile.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'main.dart';
import 'Loginpage.dart';

class Mypage extends StatelessWidget {
  Future<void> delete(context) async {
    await storage.deleteAll();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Loginpage()));
  }

  Future _info() async {
    final response = await http.get(
        Uri.parse(
            'https://nutrifit-server-h52zonluwa-du.a.run.app/users/profile'),
        headers: {
          'Authorization': 'Bearer ${await storage.read(key: 'jwtToken')}'
        });
    return response.body;
  }

  Future<void> info_update(info) async {
    final url = Uri.parse(
        'https://nutrifit-server-h52zonluwa-du.a.run.app/users/update');
    await http.patch(url,
        body: jsonEncode({
          'water': 'user_id',
          'protein': 'user_password',
          'mineral': 'user_name',
          'fat': 'user_age',
          'weight': '',
          'muscle': ''
        }));
  }

  Future singout(context) async {
    final response = await http.delete(
        Uri.parse(
            'https://nutrifit-server-h52zonluwa-du.a.run.app/users/delete'),
        headers: {
          'Authorization': 'Bearer ${await storage.read(key: 'jwtToken')}'
        });
    if (response.statusCode != 200) {
      print('회원 탈퇴 실패!${response.statusCode}');
    } else {
      storage.deleteAll();
      print('회원 탈퇴 완료');
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Loginpage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _info(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final list = jsonDecode(snapshot.data);
          List<Map<String, String?>> data = [
            {'label': '성별', 'value': '${list["gender"]}'},
            {'label': '나이', 'value': '${list["age"]} 세'},
            {'label': '체중', 'value': '${list['weight']} kg'},
            {'label': '키', 'value': '${list['height']} cm'},
            {'label': '활동 정도', 'value': '${list['activity']}'},
          ];
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 90,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => create_profile(
                                            navigator: 'tomypage',
                                          )));
                            },
                            child: Text('수정하기'))
                      ], //수정 - 수정하기 버튼
                    ),
                    SizedBox(
                      height: 30,
                    ), //수정-여백
                    Card(
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: data.map((item) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    color: Colors.white,
                                    child: Row(
                                      children: [
                                        // Label
                                        Container(
                                          width: 100,
                                          alignment: Alignment.center, //
                                          child: Text(
                                            item['label'] ?? '',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 45,
                                        ),
                                        // Value
                                        Container(
                                          width: 100,
                                          alignment: Alignment.centerRight,
                                          child: Text(item['value'] ?? ''),
                                        ),
                                      ], //수정 - 너비
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ), //수정-여백
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('로그아웃'),
                                  content: Text('로그아웃 하시겠습니까?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          delete(context);
                                        },
                                        child: Text('예')),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // '아니오'를 누르면 팝업 닫기
                                      },
                                      child: Text('아니오'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text('로그아웃'),
                        ), //수정 - 회원 탈퇴
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('계정 삭제'),
                                  content: Text('탈퇴하시겠습니까?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        singout(context); // singout 함수 호출
                                      },
                                      child: Text('예'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // '아니오'를 누르면 팝업 닫기
                                      },
                                      child: Text('아니오'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text('회원탈퇴'),
                        ) //수정 - 회원 탈퇴
                      ],
                    ), //수정 - 로그아웃 회원탈퇴 버튼
                  ],
                ),
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
      },
    );
  }
}
