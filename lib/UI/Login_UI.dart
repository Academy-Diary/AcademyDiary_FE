import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:academy_manager/UI/AfterLogin_UI.dart';
import 'package:academy_manager/UI/AfterSignup_UI.dart';
import 'package:academy_manager/API/Login_API.dart'; // LoginService import
import 'package:academy_manager/UI/FindId_UI.dart';
import 'package:academy_manager/UI/ResetPassword_UI.dart';
import 'package:dio/dio.dart';  // Dio 패키지 import

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginpageState();
}

class _LoginpageState extends State<LoginPage> {
  // 입력 받은 아이디/비밀번호를 가져오기 위한 컨트롤러
  TextEditingController _idController = TextEditingController();
  TextEditingController _pwController = TextEditingController();
  bool isAutoLogin = false;  // 자동 로그인 체크 여부 저장 변수
  final LoginApi loginApi = LoginApi();  // LoginService 인스턴스 생성

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xff565D6D);
    const backColor = Color(0xffD9D9D9);

    return Scaffold(
      backgroundColor: backColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Log in",
                style: TextStyle(
                  fontSize: 40.0.sp,
                ),
              ),
              104.verticalSpace,
              _buildTextField(_idController, "ID", true),
              30.verticalSpace,
              _buildTextField(_pwController, "Password", false, isPassword: true),
              13.verticalSpace,
              _buildAutoLoginCheckbox(),
              30.verticalSpace,
              _buildLoginButton(mainColor),
              _buildFooterButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // 로그인 버튼 생성
  Widget _buildLoginButton(Color mainColor) {
    return SizedBox(
      width: 342.0.w,
      height: 63.0.h,
      child: ElevatedButton(
        onPressed: _handleLogin,
        child: Text(
          "로그인",
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: mainColor,
        ),
      ),
    );
  }

  // 자동 로그인 체크박스
  Widget _buildAutoLoginCheckbox() {
    return SizedBox(
      width: 341.99.w,
      height: 51.43.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Checkbox(
            value: isAutoLogin,
            onChanged: (bool? value) {
              setState(() {
                isAutoLogin = value!;
              });
            },
          ),
          Text(
            "자동로그인",
            style: TextStyle(fontSize: 20.0),
          ),
        ],
      ),
    );
  }

  // 로그인 처리 함수
  Future<void> _handleLogin() async {
    String id = _idController.text;
    String pw = _pwController.text;

    if (id.isEmpty || pw.isEmpty) {
      Fluttertoast.showToast(msg: "ID와 PW를 입력해주세요!");
      return;
    }

    try {
      var response = await loginApi.login(id, pw);  // 로그인 API 호출
      await loginApi.saveLoginInfo(id, pw, isAutoLogin);  // 자동 로그인 정보 저장
      await loginApi.saveTokens(response, id);  // 토큰 저장

      if (response.data['user']['role'] == "STUDENT" || response.data['user']['role'] == "PARENT") {
        _navigateToNextPage(response, id);  // 다음 페이지로 이동
      } else {
        _showErrorSnackBar("학생과 학부모만 로그인이 가능합니다.");
      }
    } catch (err) {
      print(err);
    }
  }

  // ID 및 비밀번호 입력 필드
  Widget _buildTextField(TextEditingController controller, String hintText, bool autofocus, {bool isPassword = false}) {
    return SizedBox(
      width: 341.99.w,
      height: 51.43.h,
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        obscureText: isPassword,
        style: TextStyle(fontSize: 18),
        decoration: InputDecoration(hintText: hintText, hintStyle: TextStyle(fontSize: 18)),
      ),
    );
  }

  // 하단 버튼 (ID 찾기, 비밀번호 찾기)
  Widget _buildFooterButtons() {
    return SizedBox(
      width: 280.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FindIdPage()));
            },
            child: Text(
              "ID 찾기",
              style: TextStyle(fontSize: 24.0, color: Color(0xff6A6666)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordPage()));
            },
            child: Text(
              "비밀번호 찾기",
              style: TextStyle(fontSize: 24.0, color: Color(0xff6A6666)),
            ),
          ),
        ],
      ),
    );
  }

  // 에러 스낵바 표시
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // 로그인 후 다음 페이지로 이동
  void _navigateToNextPage(Response response, String id) {
    String name = response.data['user']['user_name'];
    String email = response.data['user']['email'];
    String phone = response.data['user']['phone_number'];

    if (response.data['userStatus'] != null && response.data['userStatus']['status'] == "APPROVED") {
      loginApi.saveUserInfo(response.data); // 이름, 이메일, 전화번호를 secure_storage에 저장
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AfterLoginPage(name: name, email: email, id: id, phone: phone),
        ),
      );
    } else {
      String role = response.data['user']['role'];
      int roleValue = (role == "STUDENT") ? 1 : 0;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AfterSignUp(name: name, role: roleValue, isKey: false),
        ),
      );
    }
  }
}
