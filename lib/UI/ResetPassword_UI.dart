import 'package:flutter/material.dart';
import 'package:academy_manager/API/ResetPassword_API.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final ResetPasswordApi resetPasswordApi = ResetPasswordApi();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _resetPassword() async {
    String userId = _idController.text;
    String email = _emailController.text;
    String phoneNumber = _phoneController.text;

    if (userId.isEmpty || email.isEmpty || phoneNumber.isEmpty) {
      Fluttertoast.showToast(msg: "모든 정보를 입력해주세요.");
      return;
    }

    try {
      Response response = await resetPasswordApi.resetPassword(userId, email, phoneNumber);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: response.data['message']);
        Navigator.pop(context); // 성공 시 이전 페이지로 돌아가기
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
      appBar: AppBar(title: Text('비밀번호 초기화')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: '아이디 입력'),
            ),
            SizedBox(height: 16),
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
              onPressed: _resetPassword,
              child: Text('비밀번호 초기화'),
            ),
          ],
        ),
      ),
    );
  }
}
