import 'package:academy_manager/API/FindId_API.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:academy_manager/UI/FindIdResult_UI.dart';
import 'package:academy_manager/API/FindId_API.dart';

class FindIdPage extends StatefulWidget {
  @override
  _FindIdPageState createState() => _FindIdPageState();
}

class _FindIdPageState extends State<FindIdPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final FindIdApi findIdApi = FindIdApi();

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
      String userId = await findIdApi.findId(email, phoneNumber);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FindIdResultPage(userId: userId),
        ),
      );
    } catch (error) {
      Fluttertoast.showToast(msg: error.toString());
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
