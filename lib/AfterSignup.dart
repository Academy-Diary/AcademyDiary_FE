import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // 화면크기에 따라 ui 크기 설정 및 재배치

class AfterSignUp extends StatelessWidget {
  final String name;
  final int role;
  final bool isKey; //학원 키를 받았는지 여부
  const AfterSignUp({super.key, required this.name, required this.role, required this.isKey});
  // 실제 navigator를 사용하여 인자를 받을 때는 다른 방식 사용.



  @override
  Widget build(BuildContext context) {
    String s_role = (role == 1)? "학생" : "학부모";
    const mainColor = Color(0xFF565D6D);
    const backColor = Color(0xFFD9D9D9);

    return Scaffold(
      backgroundColor: backColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: Text(
                  "Academy Pro",
                  style: TextStyle(
                    fontSize: 40.sp,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    name+"("+s_role+")",
                    style: TextStyle(
                      fontSize: 32.sp,
                    ),
                  ),
                  Text(
                    "회원가입을 환영합니다!",
                    style: TextStyle(
                      fontSize: 32.sp,
                    ),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 100.h),
                child: SizedBox(
                  width: 342.w,
                  height: 63.h,
                  child: ElevatedButton(
                    onPressed: (){

                    },
                    child: Text(
                      (isKey) ?"홈으로" : "학원 등록 요청하기",
                      style: TextStyle(
                        fontSize: 24.sp
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                    ),
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
