import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:nutrifit/MyHomePage.dart';
import 'main.dart';
import 'create_profile.dart';
import 'package:provider/provider.dart';

class Loginpage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final sharedStorage = storage;

  Future<void> _saveToken(String token) async {
    await storage.write(key: 'jwtToken', value: token);
  }

  Future<void> _login(context) async {
    final String url = 'https://nutrifit-server-h52zonluwa-du.a.run.app/signin';
    final Map<String, String> data = {
      'user_id': usernameController.text,
      'user_password': passwordController.text,
    };

    final http.Response response = await http.post(
      Uri.parse(url),
      body: data,
    );

    if (response.statusCode == 201) {
      _saveToken(response.body);
      print('로그인 성공');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MyHomePage(
                    selectedIndex: 1,
                  )));
      // JWT 토큰을 저장, 홈페이지로 진입
    } else {
      // 로그인 실패 시
      dialog(context);
      print('로그인 실패: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('로그인하기'),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'id'),
            ),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: TextField(
              obscureText: true,
              controller: passwordController,
              decoration: InputDecoration(labelText: 'password'),
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
                onPressed: () {
                  _login(context);
                },
                child: Text('로그인')),
            TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Signuppage()));
                },
                child: Text('회원가입하기'))
          ],
        ),
      ]),
    );
  }
  void dialog(context){
     showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('알림'),
            content: Text('아이디 또는 비밀번호가 올바르지 않습니다.'),
            actions: [
              TextButton(
                child: Text('닫기'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
  }
}

class Signuppage extends StatefulWidget {
  @override
  State<Signuppage> createState() => _SignuppageState();
}

class _SignuppageState extends State<Signuppage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordcheckController = TextEditingController();
  bool idvalid = true;
  bool passwordvalid = true;
  bool checkpassword = true;
  String idcheckmessage = '';

  void _checkpassword(value) {
    if (passwordController.text == value) {
      checkpassword = true;
    } else {
      checkpassword = false;
    }
  }

  Future<void> _saveToken(String token) async {
    await storage.write(key: 'jwtToken', value: token);
  }

  Future<void> _login() async {
    final String url = 'https://nutrifit-server-h52zonluwa-du.a.run.app/signin';
    final Map<String, String> data = {
      'user_id': usernameController.text,
      'user_password': passwordController.text,
    };

    final http.Response response = await http.post(
      Uri.parse(url),
      body: data,
    );

    if (response.statusCode == 201) {
      _saveToken(response.body);
      print('로그인 성공');
      // JWT 토큰을 저장
    } else {
      // 로그인 실패 시
      print('로그인 실패: ${response.reasonPhrase}');
    }
  }

  Future<void> _signup(context) async {
    final String url =
        'https://nutrifit-server-h52zonluwa-du.a.run.app/users/signup';
    final Map<String, String> data = {
      'user_id': usernameController.text,
      'user_password': passwordController.text,
    };

    final http.Response response = await http.post(
      Uri.parse(url),
      body: data,
    );

    if (response.statusCode != 201) {
      print('회원가입을 다시 시도해 주세요 ${response.statusCode}');
    } else {
      print('회원가입 성공');
      _login();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => create_profile(
                    navigator: 'tologin',
                  )));
      //navigator > create user's profile 창으로 이동
    }
  }

  Future<void> _idvalid(value) async {
    final String url =
        'https://nutrifit-server-h52zonluwa-du.a.run.app/users/checkid';
    final Map<String, String> data = {
      'user_id': value,
    };

    final http.Response response = await http.post(
      Uri.parse(url),
      body: data,
    );

    if (response.statusCode != 201) {
      idvalid = false;
      if (response.statusCode == 409) {
        idcheckmessage = '이미 존재하는 아이디입니다';
      } else {
        idcheckmessage = '글자수가 맞지 않습니다.';
      }
      print(idvalid);
    } else {
      // statuscode = 201
      print('사용 가능합니다');
      idvalid = true;
    }
  }

  Future<void> _passwordvalid(value) async {
    final String url =
        'https://nutrifit-server-h52zonluwa-du.a.run.app/users/checkpassword';
    final Map<String, String> data = {
      'user_password': value,
    };

    final http.Response response = await http.post(
      Uri.parse(url),
      body: data,
    );

    if (response.statusCode != 201) {
      passwordvalid = false;
      print('사용 가능하지 않은 비밀번호');
    } else {
      // statuscode = 201
      print('사용 가능합니다');
      passwordvalid = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입하기'),
      ),
      body: ListView(children: [
        SizedBox(
          height: 30,
        ), //#수정-여백
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: TextField(
              controller: usernameController,
              decoration: InputDecoration(
                  labelText: 'id',
                  errorText: idvalid ? null : "${idcheckmessage}",
                  errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red))),
              onChanged: (value) async {
                await _idvalid(value);
                setState(() {});
              },
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: InputDecoration(
                        labelText: 'password',
                        errorText: passwordvalid ? null : '사용 가능하지 않은 비밀번호입니다.',
                        errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red))),
                    onChanged: (value) async {
                      await _passwordvalid(value);
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Card(
                  child: TextField(
                    obscureText: true,
                    controller: passwordcheckController,
                    decoration: InputDecoration(
                        labelText: 'Re-enter password',
                        errorText: checkpassword ? null : '비밀번호가 일치하지 않습니다.',
                        errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red))),
                    onChanged: (value) {
                      setState(() {
                        _checkpassword(value);
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 30,
                ), //#수정
                ElevatedButton(
                    onPressed: () {
                      _signup(context);
                    },
                    child: Text('sign up'))
              ],
            )),
      ]),
    );
  }
}
