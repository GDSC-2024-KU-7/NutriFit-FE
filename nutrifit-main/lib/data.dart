import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> fetchData() async {
  var url =
      Uri.parse('https://nutrifit-server-h52zonluwa-du.a.run.app/food/NO/4');
  var response = await http.get(url);

  var responseBody = response.body;

  List<dynamic> list = jsonDecode(responseBody);

  if (response.statusCode == 200) {
    // 성공적으로 데이터를 받음
    print('Response data${response.body}');
  } else {
    // 에러 처리
    print('Request failed${response.statusCode}');
  }
}
