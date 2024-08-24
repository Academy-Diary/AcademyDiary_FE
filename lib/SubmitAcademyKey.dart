import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // 화면크기에 따라 ui 크기 설정 및 재배치

class SubmitAcademyKey extends StatefulWidget {
  const SubmitAcademyKey({super.key});

  @override
  State<SubmitAcademyKey> createState() => _SubmitAcademyKeyState();
}

class _SubmitAcademyKeyState extends State<SubmitAcademyKey> {
  late ScrollController _scrollController = ScrollController();
  

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    Color mainColor = Color(0xFF565D6D);
    Color backColor = Color(0xFFD9D9D9);
    return Scaffold(
      backgroundColor: backColor,
      body: SafeArea(
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView (
            controller: _scrollController,
            child: Center(
              child: Column(
                children: [
                  Text(
                    "AcademyPro",
                    style: TextStyle(
                      fontSize: 40.sp,
                    ),
                  ),
                  SizedBox(
                    height: 239.h,
                  ),
                  Text(
                    "(학생이름)님 환영합니다. \n\n아래 학원키를 입력 후 등록요청하기를 눌러주세요.",
                    style: TextStyle(
                      fontSize: 20.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 103.h,
                  ),
                  SizedBox(
                    width: 341.w,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "학원키 입력",
                        hintStyle: TextStyle(
                          fontSize: 18.sp
                        )
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 103.h,
                  ),
                  SizedBox(
                    width: 342.w,
                    height: 63.h,
                    child: ElevatedButton(
                        onPressed: (){},
                        child: Text(
                          "학원 등록 요청하기",
                          style: TextStyle(
                            fontSize: 24.sp
                          ),
                        ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
