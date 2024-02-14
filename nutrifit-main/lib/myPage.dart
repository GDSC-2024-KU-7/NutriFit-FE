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
                        ElevatedButton(
                            onPressed: () {
                              delete(context);
                            },
                            child: Text('로그아웃')),
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
                      ],
                    ),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(item['label'] ?? ''),
                                        Text(item['value'] ?? ''),
                                      ],
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
                    ElevatedButton(
                        onPressed: () {
                          singout(context);
                        },
                        child: Text('회원탈퇴'))
                  ],
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('error');
        }
        return CircularProgressIndicator();
      },
    );
  }
}
