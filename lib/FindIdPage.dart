import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:academy_manager/FindIdResultPage.dart';
import 'package:academy_manager/MyDio.dart';

class FindIdPage extends StatefulWidget {
  @override
  _FindIdPageState createState() => _FindIdPageState();
}

class _FindIdPageState extends State<FindIdPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final dio =new MyDio();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _findId() async {
    String email = _emailController.text;
    String phoneNumber = _phoneController.text;

    if (email.isEmpty || phoneNumber.isEmpty) {
      Fluttertoast.showToast(msg: "email과 phone_number를 입력해주세요.");
      return;
    }

    try {
      Response response = await dio.post(
        '/user/find-id',
        data: {
          'email': email,
          'phone_number': phoneNumber,
        },
      );

      if (response.statusCode == 200) {
        String userId = response.data['user_id'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FindIdResultPage(userId: userId),
          ),
        );
      }
    } on DioError catch (error) {
      if (error.response?.statusCode == 400) {
        Fluttertoast.showToast(msg: error.response?.data['message']);
      } else if (error.response?.statusCode == 404) {
        Fluttertoast.showToast(msg: "해당하는 유저가 존재하지 않습니다.");
      } else if (error.response?.statusCode == 500) {
        Fluttertoast.showToast(msg: "서버에 오류가 발생했습니다. 다시 시도해주세요.");
      } else {
        Fluttertoast.showToast(msg: "예상치 못한 오류가 발생했습니다.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('아이디 찾기')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: '이메일 입력'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: '휴대폰 번호 입력'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _findId,
              child: Text('아이디 찾기'),
            ),
          ],
        ),
      ),
    );
  }
}
