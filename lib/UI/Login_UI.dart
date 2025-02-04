import 'package:academy_manager/UI/MyPage_UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:academy_manager/UI/AfterLogin_UI.dart';
import 'package:academy_manager/UI/AfterSignup_UI.dart';
import 'package:academy_manager/API/Login_API.dart';
import 'package:academy_manager/UI/FindId_UI.dart';
import 'package:academy_manager/UI/ResetPassword_UI.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginpageState();
}

class _LoginpageState extends State<LoginPage> {
  TextEditingController _idController = TextEditingController();
  TextEditingController _pwController = TextEditingController();
  bool isAutoLogin = false;
  final LoginApi loginApi = LoginApi();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "아카데미 다이어리",
          style: TextStyle(
            fontSize: 20.sp,
            fontFamily: 'PretendardSemiBold',
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFEEEBDD),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Color(0xFF064420)),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Color(0xFF064420)),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person, color: Color(0xFF064420)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView( // 스크롤 가능하게 변경
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50.h),
                Icon(Icons.person, size: 60.sp, color: Colors.black),
                SizedBox(height: 20.h),
                Text(
                  "로그인 하기",
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontFamily: 'PretendardSemiBold',
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 40.h),
                _buildTextField(_idController, "아이디"),
                SizedBox(height: 20.h),
                _buildTextField(_pwController, "비밀번호", isPassword: true),
                SizedBox(height: 10.h),
                _buildAutoLoginCheckbox(),
                SizedBox(height: 30.h),
                _buildLoginButton(),
                SizedBox(height: 20.h),
                _buildFooterButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: 342.0.w,
      height: 50.h,
      child: ElevatedButton.icon(
        onPressed: _handleLogin,
        icon: Icon(Icons.arrow_forward, size: 24.sp),
        label: Text(
          "로그인",
          style: TextStyle(
            fontSize: 20.sp,
            fontFamily: 'PretendardRegular',
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF024F51),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
        ),
      ),
    );
  }

  Widget _buildAutoLoginCheckbox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
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
          style: TextStyle(
            fontSize: 18.sp,
            fontFamily: 'PretendardRegular',
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    String id = _idController.text;
    String pw = _pwController.text;

    if (id.isEmpty || pw.isEmpty) {
      Fluttertoast.showToast(msg: "ID와 PW를 입력해주세요!");
      return;
    }

    try {
      var response = await loginApi.login(id, pw);

      // API 응답에서 academy_id 가져오기
      String academyId = response.data['user']['academy_id'];
      String userName = response.data['user']['user_name'];

      // 로그인 정보 저장 (user_id와 academy_id)
      await loginApi.saveTokens(response, id);
      await LoginApi.storage.write(key: 'academy_id', value: academyId);
      await LoginApi.storage.write(key: 'user_name', value: userName);

      print("로그인 후 저장된 academy_id: $academyId");

      String? storedId = await LoginApi.storage.read(key: 'user_id');
      if (storedId != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AfterLoginPage(
              name: response.data['user']['user_name'],
              email: response.data['user']['email'],
              id: id,
              phone: response.data['user']['phone_number'],
              role: response.data['user']['role'],
            ),
          ),
        );
      } else {
        Fluttertoast.showToast(msg: "로그인에 실패했습니다. ID 저장 오류.");
      }
    } catch (err) {
      print("로그인 중 오류 발생: $err");
      Fluttertoast.showToast(msg: "로그인 중 오류가 발생했습니다.");
    }
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(fontSize: 18.sp, fontFamily: 'PretendardRegular'),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 18.sp, fontFamily: 'PretendardLight'),
        contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.r),
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildFooterButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => FindIdPage()));
          },
          child: Text(
            "아이디 찾기",
            style: TextStyle(fontSize: 16.sp, fontFamily: 'PretendardRegular', color: Colors.black),
          ),
        ),
        Text("|", style: TextStyle(fontSize: 16.sp)),
        TextButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ResetPasswordPage()));
          },
          child: Text(
            "비밀번호 찾기",
            style: TextStyle(fontSize: 16.sp, fontFamily: 'PretendardRegular', color: Colors.black),
          ),
        ),
      ],
    );
  }
}
