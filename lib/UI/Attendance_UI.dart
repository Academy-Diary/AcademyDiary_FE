import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/UI/AppBar_UI.dart';

class Attendance extends StatelessWidget {
  final String name;
  final String role; // 역할 추가 (STUDENT 또는 PARENT)

  Attendance({super.key, required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    final mainColor = Color(0xFF565D6D);

    return Scaffold(
      appBar: MyAppBar().build(context), // 기존 AppBar 유지
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                role == "PARENT"
                    ? '$name 님, 자녀의 출석이 확인되었습니다.'
                    : '$name 님, 출석인증을 진행해주세요.',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 40.h),
            if (role == "STUDENT") ...[
              // 학생일 때만 인증 입력 필드 표시
              Text(
                "인증번호를 입력하세요",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '인증번호',
                  hintText: '여기에 인증번호를 입력하세요',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 40.h),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      padding: EdgeInsets.symmetric(vertical: 16.0.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0.r),
                      ),
                    ),
                    onPressed: () {
                      // 출석 인증 처리 로직 추가
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('출석이 인증되었습니다!')),
                      );
                    },
                    child: Text(
                      '인증 제출',
                      style: TextStyle(fontSize: 22.sp, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ] else ...[
              // 학부모일 때는 "출석이 확인되었습니다" 메시지 표시
              Center(
                child: Text(
                  "출석이 확인되었습니다.",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue, // 파란색 글씨
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
