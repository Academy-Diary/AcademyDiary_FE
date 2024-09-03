import 'package:academy_manager/AppBar.dart';  // AppBar.dart 파일에서 MyAppBar를 import
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/MemberInfoEdit.dart';  // MemberInfoEdit.dart 파일 import

class MyPage extends StatelessWidget {
  String token;
  MyPage({super.key, required this.token});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar().build(context),
      drawer: MenuDrawer(name: '현우진', email: 'example@gmail.com', subjects: ['수학']),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60.r,
                backgroundColor: Colors.grey[300],
              ),
            ),
            SizedBox(height: 30.h),
            Container(
              padding: EdgeInsets.all(16.w),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("name: 현우진", style: TextStyle(fontSize: 18.sp)),
                  SizedBox(height: 10.h),
                  Text("ID: exampleID", style: TextStyle(fontSize: 18.sp)),
                  SizedBox(height: 10.h),
                  Text("Email: example1@gmail.com", style: TextStyle(fontSize: 18.sp)),
                  SizedBox(height: 10.h),
                  Text("phone: 010-0000-0000", style: TextStyle(fontSize: 18.sp)),
                ],
              ),
            ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 36.w),
                backgroundColor: Color(0xFF565D6D),
              ),
              onPressed: () {
                // MemberInfoEdit 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MemberInfoEdit()),
                );
              },
              child: Text('회원정보 수정', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
            ),
          ],
        ),
      ),
    );
  }
}
