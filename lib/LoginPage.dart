import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginpageState();
}

class _LoginpageState extends State<LoginPage> {
  // 입력 받은 아이디/비밀번호를 가져오기 위한 컨트롤러
  TextEditingController _idController = TextEditingController();
  TextEditingController _pwController = TextEditingController();
  // 자동로그인 체크 여부 저장 변수
  bool isAutoLogin = false;

  // 엔터키 눌렀을 때 다음 항목으로 이동시키기 위한 FocusNode()
  final _pwFocusNode = FocusNode();

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
                    onPressed: (){
                      String id = _idController.text;
                      String pw = _pwController.text;
                      // id, pw를 서버에 보내 맞는 정보인지 확인.
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

