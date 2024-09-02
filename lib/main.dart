import 'dart:convert';

import 'package:academy_manager/AppSettings.dart';
import 'package:academy_manager/MemberInfoEdit.dart';
import 'package:academy_manager/MyPage.dart';
import 'package:academy_manager/NoticeList.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'AfterLogin.dart';  // AfterLogin.dart 파일을 import
import 'package:academy_manager/LoginPage.dart';
import 'package:academy_manager/SignupPage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // 화면크기에 따라 ui 크기 설정 및 재배치

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932), // Figma 기준 화면 사이즈
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false, // 앱내 우측 상단 debug 라벨 없애기
        title: 'Academy Manager',
        theme: ThemeData(
          useMaterial3: false,
        ),
        home: MainPage(), // 앱 시작 시 MainPage를 표시
        routes: {
          "/login": (context) => const LoginPage(),
          "/signin": (context) => const SignupPage(),
        },
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static final storage = new FlutterSecureStorage();
  String? userInfo;
  var dio; // dio 패키지 사용을 위한 변수

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // 비동기로 Flutter Secure Storage 정보를 불러오는 작업
    WidgetsBinding.instance.addPostFrameCallback((_){
      _asyncMethod();
    });

    dio = new Dio();
    dio.options.baseUrl =
    'http://192.168.0.118:8000'; //개발 중 백엔드 서버는 본인이 돌림.
    dio.options.connectTimeout = 5000; // 5s
    dio.options.receiveTimeout = 3000;
    dio.options.headers =
    {'Content-Type': 'application/json'};
  }

  _asyncMethod()async{
    userInfo = await storage.read(key: "login");
    print(userInfo);
    if(userInfo != null){
      // userInfo가 있으면? 로그인하여 토큰값을 가져와 페이지를 넘긴다..
      String? id = userInfo?.split(" ")[1];
      String? pw = userInfo?.split(" ")[3];
      var response = await dio.post("/user/login", data: {"user_id" : id, "password" : pw});
      Map<String, dynamic> res = jsonDecode(response.toString());
      Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
              builder: (context) => AfterLoginPage(
                token: res['accessToken'],
              ),
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const backColor = Color(0xffD9D9D9);
    const mainColor = Color(0xff565D6D);
    return Scaffold(

      backgroundColor: backColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 화면 세로 중앙으로 정렬
            children: [
              Text(
                "AcademyPro",
                style: TextStyle(
                  fontSize: 40.sp,
                ),
              ),
              SizedBox(height: 86.5.h), // 수직 간격 조정
              SizedBox(
                width: 185.0.w,
                height: 63.0.h,
                child: ElevatedButton(
                  child: Text(
                    "로그인",
                    style: TextStyle(
                      fontSize: 24.sp, // 텍스트 크기 조정
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false); // 로그인 페이지 이동, 첫 화면은 지움
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                  ),
                ),
              ),
              SizedBox(height: 50.h), // 수직 간격 조정
              SizedBox(
                width: 185.0.w,
                height: 63.0.h,
                child: ElevatedButton(
                  child: Text(
                    "회원가입",
                    style: TextStyle(
                      fontSize: 24.sp, // 텍스트 크기 조정
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed("/signin"); // 회원가입 페이지 이동. 첫 화면은 지우지 않음.
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



/*class MainPage extends StatelessWidget {
  const MainPage({super.key});


  @override
  Widget build(BuildContext context) {
    const backColor = Color(0xffD9D9D9);
    const mainColor = Color(0xff565D6D);
    return Scaffold(

      backgroundColor: backColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 화면 세로 중앙으로 정렬
            children: [
              Text(
                "AcademyPro",
                style: TextStyle(
                  fontSize: 40.sp,
                ),
              ),
              SizedBox(height: 86.5.h), // 수직 간격 조정
              SizedBox(
                width: 185.0.w,
                height: 63.0.h,
                child: ElevatedButton(
                  child: Text(
                    "로그인",
                    style: TextStyle(
                      fontSize: 24.sp, // 텍스트 크기 조정
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false); // 로그인 페이지 이동, 첫 화면은 지움
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                  ),
                ),
              ),
              SizedBox(height: 50.h), // 수직 간격 조정
              SizedBox(
                width: 185.0.w,
                height: 63.0.h,
                child: ElevatedButton(
                  child: Text(
                    "회원가입",
                    style: TextStyle(
                      fontSize: 24.sp, // 텍스트 크기 조정
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed("/signin"); // 회원가입 페이지 이동. 첫 화면은 지우지 않음.
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/
