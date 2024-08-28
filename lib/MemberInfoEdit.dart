import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/AppBar.dart';

class MemberInfoEdit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar().build(context),
      drawer: MenuDrawer(name: '현우진', email: 'example@gmail.com', subjects: ['수학']),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50.r,
              backgroundColor: Colors.grey[300],
            ),
            SizedBox(height: 8.h),
            Text('사진 편집', style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("name: 현우진", style: TextStyle(fontSize: 16.sp)),
                  SizedBox(height: 10.h),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'password'),
                    obscureText: true,
                  ),
                  SizedBox(height: 10.h),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'password 확인'),
                    obscureText: true,
                  ),
                  SizedBox(height: 10.h),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Email'),
                    initialValue: 'example1@gmail.com',
                  ),
                  SizedBox(height: 10.h),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'phone'),
                    initialValue: '010-0000-0000',
                  ),
                ],
              ),
            ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
                backgroundColor: Color(0xFF565D6D),
              ),
              onPressed: () {},
              child: Text('저장', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
            ),
          ],
        ),
      ),
    );
  }
}
