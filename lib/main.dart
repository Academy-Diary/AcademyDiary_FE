import 'package:academy_manager/AppSettings.dart';
import 'package:academy_manager/MemberInfoEdit.dart';
import 'package:academy_manager/MyPage.dart';
import 'package:flutter/material.dart';
import 'afterLogin.dart';  // afterLogin.dart 파일을 import
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
          "/afterLogin": (context) => AfterLoginPage(), // 경로 추가
        },
      ),
    );
  }
}

class MainPage extends StatelessWidget {
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
}
