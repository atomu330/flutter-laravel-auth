import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/pages/login.dart';
import 'package:flutter_app/utils/network.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  String? _name;
  String? _email;
  bool _isLoading = false;

  @override
  void initState() {
    _loadUserData();
    super.initState();
  }

  _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user')!);

    if (user != null) {
      setState(() {
        _name = user['name'];
        _email = user['email'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _logout() async {
      setState(() {
        _isLoading = true;
      });

      Response? res;
      try {
        res = await Network().getData('/logout');
      } catch (e) {
        debugPrint(e.toString());
      }
      if (res == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("エラーが発生しました。")),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      var body = json.decode(res.body);

      if (res.statusCode != 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body['message'])),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.remove('user');
      localStorage.remove('token');

      if (!mounted) return;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Login()));
    }

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("ホーム"),
        ),
        body: SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Center(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 32,
                        ),
                        const Text("ログインに成功しました！"),
                        const SizedBox(
                          height: 32,
                        ),
                        const Text("名前"),
                        Text(_name ?? ""),
                        const SizedBox(
                          height: 16,
                        ),
                        const Text("メールアドレス"),
                        Text(_email ?? ""),
                        const SizedBox(
                          height: 32,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              _logout();
                            },
                            child: const Text("ログアウト"))
                      ],
                    ),
                  )));
  }
}
