import 'package:academy_manager/UI/AppBar_UI.dart';
import 'package:academy_manager/UI/Attendance_UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AfterLoginPage extends StatelessWidget {
  final String name, id, email, phone, role;

  AfterLoginPage({
    super.key,
    required this.name,
    required this.id,
    required this.email,
    required this.phone,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    final mainColor = Color(0xFF064420); // 메인 색상
    final lightBg = Color(0xFFEEEBDD); // 밝은 배경

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppBar().build(context),
      drawer: MenuDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              // 캘린더 스타일 컨테이너
              Center(
                child: Stack(
                  children: [
                    // 캘린더 배경 이미지
                    Container(
                      margin: EdgeInsets.only(top: 10.h),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/icons/calender.png"),
                          fit: BoxFit.fill,
                        ),
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      width: double.infinity,
                      height: 180.h,
                    ),
                    // 출석 인증 내용
                    Positioned(
                      top: 40.h,
                      left: 20.w,
                      right: 20.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$name (학생)",
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "국민대학교 부설학원",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Center(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainColor,
                                padding: EdgeInsets.symmetric(
                                    vertical: 14.h, horizontal: 20.w),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.r),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        Attendance(role: role, name: name),
                                  ),
                                );
                              },
                              icon: Icon(Icons.check_box, color: Colors.white),
                              label: Text(
                                "출석인증하기",
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // 오늘의 수업 섹션
              _buildSectionTitle("오늘의 수업"),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(color: mainColor, width: 1.5.w),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLesson("미적분", "16:30 ~ 18:00", "김현우"),
                    _buildLesson("확률과 통계", "19:00 ~ 20:30", "김철수"),
                    _buildLesson("수학II", "20:40 ~ 21:40", "이태윤"),
                  ],
                ),
              ),

              // 학원 전체공지 섹션
              _buildSectionTitle("학원 전체공지"),
              _buildNoticeCard("공지 1", "김00", "2024.07.01"),
              _buildNoticeCard("공지 2", "김00", "2024.07.05"),
            ],
          ),
        ),
      ),
    );
  }

  // 섹션 제목
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Text(
        title,
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  // 수업 카드
  Widget _buildLesson(String subject, String time, String teacher) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject,
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              Text("강사: $teacher",
                  style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
            ],
          ),
          Text(
            time,
            style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // 공지사항 카드
  Widget _buildNoticeCard(String title, String author, String date) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              Text("작성자: $author, $date",
                  style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
            ],
          ),
          Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.black54),
        ],
      ),
    );
  }
}
