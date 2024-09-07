import 'package:academy_manager/AppBar.dart';  // AppBar.dart 파일에서 MyAppBar를 import
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSettings extends StatefulWidget {


  @override
  _AppSettingsState createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar().build(context),
      drawer: MenuDrawer(name: '현우진', email: 'example@gmail.com', subjects: ['수학']),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "앱 버전: v10.0.4",
              style: TextStyle(fontSize: 18.sp), // 폰트 크기 증가
            ),
            SizedBox(height: 20.h),
            Text(
              "알림 설정",
              style: TextStyle(fontSize: 18.sp), // 폰트 크기 증가
            ),
            SizedBox(height: 30.h),
            ExpansionTile(
              title: Text(
                "약관",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold), // 폰트 크기 증가
              ),
              children: <Widget>[
                ListTile(
                  title: Text(
                    "서비스 이용약관",
                    style: TextStyle(fontSize: 16.sp), // 폰트 크기 증가
                  ),
                  onTap: () {
                    // 서비스 이용약관 클릭 시 동작
                  },
                ),
                ListTile(
                  title: Text(
                    "개인정보처리방침",
                    style: TextStyle(fontSize: 16.sp), // 폰트 크기 증가
                  ),
                  onTap: () {
                    // 개인정보처리방침 클릭 시 동작
                  },
                ),
                ListTile(
                  title: Text(
                    "오픈소스 라이선스",
                    style: TextStyle(fontSize: 16.sp), // 폰트 크기 증가
                  ),
                  onTap: () {
                    // 오픈소스 라이선스 클릭 시 동작
                  },
                ),
              ],
            ),
            Spacer(),
            ListTile(
              title: Text(
                "탈퇴하기",
                style: TextStyle(fontSize: 18.sp, color: Colors.red), // 폰트 크기 증가
              ),
              onTap: () {
                // 탈퇴하기 클릭 시 동작
              },
            ),
          ],
        ),
      ),
    );
  }
}
