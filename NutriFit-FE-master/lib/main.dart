import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutrifit/Loginpage.dart';
import 'package:nutrifit/MyHomePage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'MyData.dart'; //수정

final storage = new FlutterSecureStorage();

double tdee = 0.0;
void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => MyData())],
      child: MyApp(),
    ),
  );
} //수정

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: SplashPage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var count = 0;
  var idcheckmessage = '';
  var passwordchecker = '';

  void add() {
    count += 1;
    notifyListeners();
  }

  void sub() {
    count -= 1;
    notifyListeners();
  }
}

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () => _checkUser(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Nutrifit',
            style: TextStyle(fontFamily: 'Italianno', fontSize: 70)), //#수정
      ),
    );
  }

  void _checkUser(context) async {
    if (await storage.read(key: 'jwtToken') == null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Loginpage()));
      print('null');
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MyHomePage(selectedIndex: 1)));
      print('nonnull');
      print(await storage.read(key: 'jwtToken'));
    }
  }
}
