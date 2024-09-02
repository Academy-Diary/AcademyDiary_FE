import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/AppBar.dart';  // AppBar.dart 파일에서 MyAppBar를 import

class NoticeDetail extends StatelessWidget {
  String token;
  NoticeDetail({super.key, required this.token});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar().build(context),
      drawer: MenuDrawer(token: token, name: '현우진', email: 'example@gmail.com', subjects: ['수학']),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DropdownButton<String>(
                  value: '게시판',
                  items: <String>['게시판', '공지'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(fontSize: 18.sp)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    // 드롭다운 선택 시 처리
                  },
                ),
                Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    backgroundColor: Color(0xFF565D6D),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // 목록 버튼 클릭 시 이전 화면으로 이동
                  },
                  child: Text('목록', style: TextStyle(fontSize: 16.sp)),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(16.w),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("제목: ~", style: TextStyle(fontSize: 18.sp)),
                  SizedBox(height: 10.h),
                  Text("작성자 / 날짜 / View", style: TextStyle(fontSize: 16.sp)),
                  SizedBox(height: 20.h),
                  Text("본문: ~", style: TextStyle(fontSize: 16.sp)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
