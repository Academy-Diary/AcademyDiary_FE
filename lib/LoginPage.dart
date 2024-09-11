import 'package:academy_manager/AfterLogin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart'; // DIO 패키지로 http 통신
import 'dart:convert'; // Json encode, Decode를 위한 패키지
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 로그인 정보 저장하는 저장소에 사용될 패키지
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginpageState();
}

class _LoginpageState extends State<LoginPage> {
  // 입력 받은 아이디/비밀번호를 가져오기 위한 컨트롤러
  TextEditingController _idController = TextEditingController();
  TextEditingController _pwController = TextEditingController();
  String? userInfo; // user 정보 저장을 위한 변수

  // 자동로그인 체크 여부 저장 변수
  bool isAutoLogin = false;

  // 엔터키 눌렀을 때 다음 항목으로 이동시키기 위한 FocusNode()
  final _pwFocusNode = FocusNode();

  // Secure Storage 접근을 위한 변수 초기화
  static final storage = FlutterSecureStorage();

  var dio;

  @override
  void initState() {
    super.initState();

    dio = Dio();
    dio.interceptors.add(
        InterceptorsWrapper(
          onError: (DioError error, ErrorInterceptorHandler handler) {
            if (error.response?.statusCode == 400) {
              Map<String, dynamic> res = jsonDecode(error.response.toString());
              Fluttertoast.showToast(msg: res["message"]);
            }
            return handler.next(error);
          },
        )
    );
    dio.options.baseUrl = 'http://192.168.199.185:8000'; // 개발 중 백엔드 서버 주소
    dio.options.connectTimeout = 5000; // 5s
    dio.options.receiveTimeout = 3000;
    dio.options.headers = {'Content-Type': 'application/json'};
  }

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
              SizedBox(
                width: 341.99.w,
                height: 51.43.h,
                child: TextField(
                  controller: _idController,
                  autofocus: true,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                      hintText: "ID",
                      hintStyle: TextStyle(fontSize: 18)
                  ),
                  onSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_pwFocusNode);
                  },
                ),
              ),
              30.verticalSpace,
              SizedBox(
                width: 341.99.w,
                height: 51.43.h,
                child: TextField(
                  focusNode: _pwFocusNode,
                  controller: _pwController,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                      hintText: "Password",
                      hintStyle: TextStyle(fontSize: 18)
                  ),
                  obscureText: true,
                ),
              ),
              13.verticalSpace,
              SizedBox(
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
                        print(isAutoLogin);
                      },
                    ),
                    Text(
                      "자동로그인",
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
              ),
              30.verticalSpace,
              SizedBox(
                width: 342.0.w,
                height: 63.0.h,
                child: ElevatedButton(
                  onPressed: () async {
                    String id = _idController.text;
                    String pw = _pwController.text;
                    if (id.isEmpty) {
                      Fluttertoast.showToast(
                        msg: "id를 입력해주세요!",
                        backgroundColor: Colors.grey,
                        fontSize: 16.0,
                        textColor: Colors.white,
                      );
                    } else if (pw.isEmpty) {
                      Fluttertoast.showToast(
                        msg: "pw를 입력해주세요",
                        backgroundColor: Colors.grey,
                        fontSize: 16.0,
                        textColor: Colors.white,
                      );
                    } else {
                      try {
                        var response = await dio.post(
                          '/user/login',
                          data: {"user_id": id, "password": pw},
                        );
                        if (isAutoLogin) {
                          await storage.write(
                            key: "login",
                            value: "user_id $id password $pw",
                          );
                        }
                        await storage.delete(key: 'accessToken');
                        await storage.write(
                          key: 'accessToken',
                          value: response.data['accessToken'],
                        );
                        await storage.delete(key: 'refreshToken');
                        await storage.write(
                          key: "refreshToken",
                          value: response.headers['set-cookie'][0],
                        );

                        Fluttertoast.showToast(
                          msg: "로그인중...",
                          backgroundColor: Colors.grey,
                          fontSize: 16,
                          timeInSecForIosWeb: 1,
                          gravity: ToastGravity.BOTTOM,
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AfterLoginPage(),
                          ),
                        );
                      } catch (err) {
                        // 오류 처리 필요
                      }
                    }
                  },
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
              ),
              SizedBox(
                width: 280.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FindIdPage(),
                          ),
                        );
                      },
                      child: Text(
                        "ID 찾기",
                        style: TextStyle(
                          fontSize: 24.0,
                          color: Color(0xff6A6666),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // 비밀번호 찾기 페이지 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResetPasswordPage(),
                          ),
                        );
                      },
                      child: Text(
                        "비밀번호 찾기",
                        style: TextStyle(
                          fontSize: 24.0,
                          color: Color(0xff6A6666),
                        ),
                      ),
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
}

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    dio.options.baseUrl = 'http://192.168.199.185:8000'; // 백엔드 서버 주소
    dio.options.connectTimeout = 5000;
    dio.options.receiveTimeout = 3000;
    dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  Future<void> _resetPassword() async {
    String userId = _idController.text;
    String email = _emailController.text;
    String phoneNumber = _phoneController.text;

    if (userId.isEmpty || email.isEmpty || phoneNumber.isEmpty) {
      Fluttertoast.showToast(msg: "모든 정보를 입력해주세요.");
      return;
    }

    try {
      Response response = await dio.post(
        '/user/reset-password',
        data: {
          'user_id': userId,
          'email': email,
          'phone_number': phoneNumber,
        },
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: response.data['message']);
        Navigator.pop(context); // 성공 시 이전 페이지로 돌아가기
      }
    } on DioError catch (error) {
      if (error.response?.statusCode == 400) {
        Fluttertoast.showToast(msg: error.response?.data['message']);
      } else if (error.response?.statusCode == 404) {
        Fluttertoast.showToast(msg: "해당하는 유저가 존재하지 않습니다.");
      } else if (error.response?.statusCode == 500) {
        Fluttertoast.showToast(msg: "서버에 오류가 발생했습니다. 다시 시도해주세요.");
      } else {
        Fluttertoast.showToast(msg: "예상치 못한 오류가 발생했습니다.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('비밀번호 초기화')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: '아이디 입력'),
            ),
            SizedBox(height: 16),
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
              onPressed: _resetPassword,
              child: Text('비밀번호 초기화'),
            ),
          ],
        ),
      ),
    );
  }
}

class FindIdPage extends StatefulWidget {
  @override
  _FindIdPageState createState() => _FindIdPageState();
}

class _FindIdPageState extends State<FindIdPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    dio.options.baseUrl = 'http://192.168.199.185:8000'; // 백엔드 서버 주소
    dio.options.connectTimeout = 5000;
    dio.options.receiveTimeout = 3000;
    dio.options.headers = {
      'Content-Type': 'application/json',
    };
  }

  Future<void> _findId() async {
    String email = _emailController.text;
    String phoneNumber = _phoneController.text;

    if (email.isEmpty || phoneNumber.isEmpty) {
      Fluttertoast.showToast(msg: "email과 phone_number를 입력해주세요.");
      return;
    }

    try {
      Response response = await dio.post(
        '/user/find-id',
        data: {
          'email': email,
          'phone_number': phoneNumber,
        },
      );

      if (response.statusCode == 200) {
        String userId = response.data['user_id'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FindIdResultPage(userId: userId),
          ),
        );
      }
    } on DioError catch (error) {
      if (error.response?.statusCode == 400) {
        Fluttertoast.showToast(msg: error.response?.data['message']);
      } else if (error.response?.statusCode == 404) {
        Fluttertoast.showToast(msg: "해당하는 유저가 존재하지 않습니다.");
      } else if (error.response?.statusCode == 500) {
        Fluttertoast.showToast(msg: "서버에 오류가 발생했습니다. 다시 시도해주세요.");
      } else {
        Fluttertoast.showToast(msg: "예상치 못한 오류가 발생했습니다.");
      }
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
