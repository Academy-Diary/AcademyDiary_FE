import 'package:academy_manager/AppBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'NoticeDetail.dart';  // NoticeDetail 화면을 import

class AfterLoginPage extends StatelessWidget {
  String token;
  AfterLoginPage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context); // ScreenUtil 초기화

    final mainColor = Color(0xFF565D6D);

    return Scaffold(
      appBar: MyAppBar().build(context),
      drawer: const MenuDrawer(name: "현우진", email: "test@abc.com", subjects: ["미적분", "영어", "국어"]),
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '현우진(학생)님 환영합니다',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20.h),
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
                  onPressed: () {},
                  child: Text(
                    '출석인증하기',
                    style: TextStyle(fontSize: 22.sp, color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              "오늘의 수업",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2.0.w),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(16.0.w),
                      child: Text('영어', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0.w),
                    child: Text('16:00~18:00', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              "학원 전체공지",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2.0.w),
                ),
                child: ListView(
                  children: [
                    NoticeTile(
                      title: '공지 1',
                      author: '길영',
                      date: '2024.07.01',
                    ),
                    NoticeTile(
                      title: '공지 2',
                      author: '길영',
                      date: '2024.07.05',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              "오늘의 날씨",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              child: Container(
                color: mainColor,
                padding: EdgeInsets.all(20.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "서울특별시(학원 주소지 지역) 28도",
                      style: TextStyle(fontSize: 20.sp, color: Colors.white),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "최고: 33도 최저: 25도",
                      style: TextStyle(fontSize: 20.sp, color: Colors.white),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      "소나기",
                      style: TextStyle(fontSize: 20.sp, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoticeTile extends StatelessWidget {
  final String title;
  final String author;
  final String date;

  NoticeTile({required this.title, required this.author, required this.date});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 16.sp)),
      subtitle: Text('$author - $date', style: TextStyle(fontSize: 14.sp)),
      onTap: () {
        // 공지사항 상세보기 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoticeDetail(),
          ),
        );
      },
    );
  }
}
