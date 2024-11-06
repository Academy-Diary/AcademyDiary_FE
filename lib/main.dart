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
    userInfo = await loginApi.getUserInfo();
    if (userInfo != null) {
      Fluttertoast.showToast(
        msg: "로그인중...",
        fontSize: 16.0,
        backgroundColor: Colors.grey,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );

      String? id = userInfo?.split(" ")[1];
      String? pw = userInfo?.split(" ")[3];
      try {
        var response = await loginApi.login(id!, pw!);

        // Save tokens from response headers and accessToken from response data
        await loginApi.saveTokens(response, id);

        String name = response.data['user']['user_name'];
        String email = response.data['user']['email'];
        String phone = response.data['user']['phone_number'];
        String role = response.data['user']['role'];

        if (response.data['userStatus'] != null &&
            response.data['userStatus']['status'] == "APPROVED") {
          // 원장의 승인 된 경우 AfterLoginPage로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AfterLoginPage(
                name: name,
                email: email,
                id: id,
                phone: phone,
                role: role
              ),
            ),
          );
        } else {
          // 원장의 승인이 없으면 초대키 입력 창으로 이동
          String tmp = response.data['user']['role'];
          int role = (tmp == "STUDENT") ? 1 : 0;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AfterSignUp(name: name, role: role, isKey: false),
            ),
          );
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "로그인 중 오류가 발생했습니다.");
      }
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "AcademyPro",
                style: TextStyle(fontSize: 40.sp),
              ),
              SizedBox(height: 86.5.h),
              SizedBox(
                width: 185.0.w,
                height: 63.0.h,
                child: ElevatedButton(
                  child: Text(
                    "로그인",
                    style: TextStyle(fontSize: 24.sp),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                  ),
                ),
              ),
              SizedBox(height: 50.h),
              SizedBox(
                width: 185.0.w,
                height: 63.0.h,
                child: ElevatedButton(
                  child: Text(
                    "회원가입",
                    style: TextStyle(fontSize: 24.sp),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed("/signin");
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
