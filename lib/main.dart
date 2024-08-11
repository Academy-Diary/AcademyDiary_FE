import 'package:flutter/material.dart';
import 'afterLogin.dart';  // afterLogin.dart 파일을 import

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AcademyPro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),  // AfterLoginPage를 초기 화면으로 설정
    );
  }
}
