import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/home.dart';
import 'package:flutter_app/utils/network.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<Register> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _name;
  String? _email;
  String? _password;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Map<String, String> data = {
      'name': _name!,
      'email': _email!,
      'password': _password!
    };

    Response? res;
    try {
      res = await Network().postData(data, '/register');
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

    // エラーの場合
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

    // 会員登録成功の場合
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.setString('token', json.encode(body['token']));
    localStorage.setString('user', json.encode(body['user']));

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Home()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("会員登録"),
        ),
        body: SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Form(
                    key: _formKey,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextFormField(
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              hintText: "名前",
                            ),
                            validator: (nameValue) {
                              if (nameValue == null || nameValue == "") {
                                return '名前は必ず入力してください。';
                              }
                              _name = nameValue;
                              return null;
                            },
                          ),
                          TextFormField(
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              hintText: "メールアドレス",
                            ),
                            validator: (emailValue) {
                              if (emailValue == null || emailValue == "") {
                                return 'メールアドレスは必ず入力してください。';
                              }
                              _email = emailValue;
                              return null;
                            },
                          ),
                          TextFormField(
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              hintText: "パスワード",
                            ),
                            obscureText: true,
                            validator: (passwordValue) {
                              if (passwordValue == null ||
                                  passwordValue == "") {
                                return 'パスワードは必ず入力してください。';
                              }
                              _password = passwordValue;
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 32,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                _register();
                              },
                              child: const Text("会員登録"))
                        ],
                      ),
                    ))));
  }
}
