import 'package:flutter/material.dart';
import 'afterLogin.dart';  // afterLogin.dart 파일을 import
import 'package:academy_manager/LoginPage.dart';
import 'package:academy_manager/SignupPage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';// 화면크기에 따라 ui 크기 설정 및 재배치

void main(){
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),//figma 기준 화면 사이즈
      splitScreenMode: true,
      builder: (context, child) =>MaterialApp(
          debugShowCheckedModeBanner: false, //앱내 우측 상단 debug 라벨 없애기
          title: 'Academy Manager',
          theme: ThemeData(
            useMaterial3: false,
          ),
          home: const MainPage(),
          routes: {
            "/login" : (context) => const LoginPage(),
            "/signin" : (context) => const SignupPage(),
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
                  fontSize: 40.sp
                ),
              ),
              86.5.verticalSpace,
              SizedBox(
                width: 185.0.w,
                height: 63.0.h,
                child: ElevatedButton(
                  child: Text("로그인", style: TextStyle(
                    fontSize: 24,
                  ),),
                  onPressed: (){
                    Navigator.of(context).pushNamedAndRemoveUntil("/login", (route)=>false); // 로그인 페이지 이동, 첫화면은 지움
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                  ),
                ),
              ),
              50.verticalSpace,
              SizedBox(
                width: 185.0.w,
                height: 63.0.h,
                child: ElevatedButton(
                  child: Text("회원가입",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  onPressed: (){
                    Navigator.of(context).pushNamed("/signin");// 회원가입 페이지 이동. 첫 화면은 지우지 않음.
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


