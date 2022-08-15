import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';

class Network {
  // Androidシュミレーターを使う場合はlocalhostを10.0.2.2に変更する
  final String _url = 'http://localhost/api';
  String? token;

  // SharedPreferencesからトークンを取得
  _setToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String? localToken = localStorage.getString('token');
    
    // なぜか"が入っていたので入らないように見直す！！！！！！！
    if (localToken != null) {
      token = localToken.replaceAll('"', '');
    }
  }

  // ヘッダー情報をセット
  _getHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      };

  // POST
  Future<Response> postData(data, String apiUrl) async {
    await _setToken();
    Uri fullUrl = Uri.parse(_url + apiUrl);
    return await post(fullUrl, body: jsonEncode(data), headers: _getHeaders());
  }

  // GET
  Future<Response> getData(String apiUrl) async {
    await _setToken();
    Uri fullUrl = Uri.parse(_url + apiUrl);
    Response res = await get(fullUrl, headers: _getHeaders());    
    return res;
  }
}
