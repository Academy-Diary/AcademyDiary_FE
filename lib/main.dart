import 'package:academy_manager/API/Login_API.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:academy_manager/UI/AfterLogin_UI.dart';
import 'package:academy_manager/UI/MyPage_UI.dart';
import 'package:academy_manager/UI/AfterSignup_UI.dart';
import 'package:academy_manager/UI/Login_UI.dart';
import 'package:academy_manager/UI/Signup_UI.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Academy Manager',
        theme: ThemeData(
          fontFamily: 'Pretendard', // 기본 폰트 Pretendard 적용
          useMaterial3: false,
        ),
        home: MainPage(),
        routes: {
          "/login": (context) => const LoginPage(),
          "/signin": (context) => const SignupPage(),
          "/myPage": (context) => MyPage(),
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
  final LoginApi loginApi = LoginApi();
  String? userInfo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLogin();
    });
  }

  Future<void> _initializeLogin() async {
    try {
      userInfo = await loginApi.getUserId();
      print("불러온 로그인 정보: $userInfo");
    } catch (e) {
      print("자동 로그인 처리 중 오류 발생: $e");
      Fluttertoast.showToast(msg: "자동 로그인 중 오류가 발생했습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경 흰색
      appBar: AppBar(
        title: Text(
          "아카데미 다이어리",
          style: TextStyle(
            fontSize: 20.sp,
            fontFamily: 'PretendardSemiBold', // Pretendard 폰트 지정
            color: Colors.black, // 글씨 검은색
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFEEEBDD), // 헤더바 색상
        elevation: 0, // 그림자 없앰
        leading: IconButton(
          icon: Icon(Icons.menu, color: Color(0xFF064420)), // 햄버거 메뉴 색상
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Color(0xFF064420)), // 알림 아이콘 색상
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person, color: Color(0xFF064420)), // 마이페이지 아이콘 색상
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 150.h),
              Text(
                "아카데미 다이어리",
                style: TextStyle(
                    fontSize: 40.sp,
                    fontFamily: 'PretendardSemiBold'),
              ),
              SizedBox(height: 30.h),
              Text(
                "우리들의 스마트한 학습 관리",
                style: TextStyle(
                    fontSize: 22.sp,
                    fontFamily: 'PretendardThin',
                    color: Colors.black),
              ),
              SizedBox(height: 100.h),
              _buildButton(
                context,
                label: "로그인",
                icon: Icons.person,
                color: Color(0xFF024F51),
                route: "/login",
              ),
              SizedBox(height: 30.h),
              _buildButton(
                context,
                label: "회원가입",
                icon: Icons.person_add,
                color: Color(0xFFFEC749),
                route: "/signin",
              ),
              SizedBox(height: 30.h),
              GestureDetector(
                onTap: () {
                  // 카카오 로그인 처리
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/icons/kakao_icon.png",
                      width: 24.w,
                      height: 24.h,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "카카오 계정으로 로그인 하기",
                      style: TextStyle(fontSize: 20.sp, color: Colors.black, fontFamily: 'PretendardLight'), // 검은색 글씨
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, {
        required String label,
        required IconData icon,
        required Color color,
        required String route,
      }) {
    return Column(
      children: [
        Container(
          width: 250, // 버튼 가로 크기 최대
          height: 50.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.r),
            color: color,
          ),
          child: ElevatedButton.icon(
            icon: Icon(icon, size: 22.sp),
            label: Text(label, style: TextStyle(fontSize: 22.sp,
            fontFamily: 'PretendardRegular')),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(route);
            },
          ),
        ),
        SizedBox(height: 4.h), // 버튼과 줄 사이 간격
        Container(
          height: 6.h,
          width: 250, // 줄 크기 버튼과 동일
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(30.r), // 아래 줄도 둥글게
          ),
        ),
      ],
    );
  }
}
