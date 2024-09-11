import 'package:flutter/material.dart';

class FindIdResultPage extends StatelessWidget {
  final String userId;

  FindIdResultPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('아이디 찾기 결과')),
      body: Center(
        child: Text(
          '내 아이디: $userId',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
