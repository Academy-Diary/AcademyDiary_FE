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
  String? userInfo; //user 정보 저장을 위한 변수


  // 자동로그인 체크 여부 저장 변수
  bool isAutoLogin = false;

  // 엔터키 눌렀을 때 다음 항목으로 이동시키기 위한 FocusNode()
  final _pwFocusNode = FocusNode();

  //Secure Storage 접근을 위한 변수 초기화
  static final storage = new FlutterSecureStorage();

  var dio;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    dio = new Dio();
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
    ); // StatusCode가 400일 때 서버에서 리턴하는 "message"를 toastMessage로 출력
    dio.options.baseUrl =
    'http://192.168.199.185:8000'; //개발 중 백엔드 서버는 본인이 돌림.
    dio.options.connectTimeout = 5000; // 5s
    dio.options.receiveTimeout = 3000;
    dio.options.headers =
    {'Content-Type': 'application/json'};
  }

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xff565D6D);
    const backColor = Color(0xffD9D9D9);

    return Scaffold(
      backgroundColor: backColor,
      body: SafeArea(
        //minimum: EdgeInsets.fromLTRB(30.w, 20.h, 30.w, 0.w),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Log in",
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
                    //labelText: "ID",
                    hintText: "ID",
                    hintStyle:TextStyle(fontSize: 18)
                  ),
                  onSubmitted: (_){
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
                    hintStyle:TextStyle(fontSize: 18)
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
                        onChanged: (bool? value){
                          setState(() {
                            isAutoLogin = value!;
                          });
                          print(isAutoLogin);
                        },

                    ),
                    Text("자동로그인",
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
                      if(id.isEmpty){
                        Fluttertoast.showToast(
                          msg: "id를 입력해주세요!",
                          backgroundColor: Colors.grey,
                          fontSize: 16.0,
                          textColor: Colors.white,
                        );
                      }else if(pw.isEmpty) {
                        Fluttertoast.showToast(
                          msg: "pw를 입력해주세요",
                          backgroundColor: Colors.grey,
                          fontSize: 16.0,
                          textColor: Colors.white,
                        );
                      }
                      else {
                        // id, pw를 서버에 보내 맞는 정보인지 확인.
                        var response;
                        try {
                          response = await dio.post('/user/login',
                              data: {"user_id": id, "password": pw});
                          if(isAutoLogin){
                            await storage.write(
                                key: "login",
                                value: "useer_id $id password $pw"
                            );
                          }
                          storage.delete(key: 'accessToken');
                          storage.write(key: 'accessToken', value: response.data['accessToken']);
                          storage.delete(key: 'refreshToken');
                          storage.write(key: "refreshToken", value: response.headers['set-cookie'][0]);

                          Fluttertoast.showToast(
                              msg: "로그인중...",
                            backgroundColor: Colors.grey,
                            fontSize: 16,
                            timeInSecForIosWeb: 1,
                            gravity: ToastGravity.BOTTOM,
                          );

                          Navigator.pushReplacement(context,
                            MaterialPageRoute(
                                builder: (context)=> AfterLoginPage(),
                              ),
                          );
                        } catch (err) {

                        }
                      }
                    },
                    child: Text("로그인",
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
                      onPressed: (){
                        // ID찾기 페이지 이동
                      },
                      child: Text("ID 찾기",
                        style: TextStyle(
                          fontSize: 24.0,
                          color: Color(0xff6A6666)
                        ),
                      )
                    ),

                    TextButton(
                        onPressed: (){
                          // 비밀번호 찾기 페이지 이동
                        },
                        child: Text("비밀번호 찾기",
                          style: TextStyle(
                              fontSize: 24.0,
                              color: Color(0xff6A6666)
                          ),
                        )
                    )
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

