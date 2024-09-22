import 'package:academy_manager/UI/AppBar_UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/main.dart';
import 'package:academy_manager/API/AppSettings_API.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';

class AppSettings extends StatefulWidget {
  @override
  _AppSettingsState createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  String? id, accessToken;
  String name = "",
      email = "";
  final AppSettingsApi appSettingsApi = AppSettingsApi();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData(); // 사용자 정보 로드
    });
  }

  // 사용자 정보 초기화
  Future<void> _initializeData() async {
    id = await appSettingsApi.getId();
    accessToken = await appSettingsApi.getAccessToken();

    if (id != null && accessToken != null) {
      final userInfo = await appSettingsApi.fetchUserInfo(id!, accessToken!);
      setState(() {
        name = userInfo['user_name'];
        email = userInfo['email'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 에러 인터셉터 추가
    appSettingsApi.addErrorInterceptor(context);

    return Scaffold(
      appBar: MyAppBar().build(context),
      drawer: MenuDrawer(name: name, email: email, subjects: ['수학']),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppVersion(),
            SizedBox(height: 20.h),
            _buildNotificationSettings(),
            SizedBox(height: 30.h),
            _buildTermsSection(),
            Spacer(),
            _buildDeleteAccountButton(),
          ],
        ),
      ),
    );
  }

  // 앱 버전 정보
  Widget _buildAppVersion() {
    return Text(
      "앱 버전: v10.0.4",
      style: TextStyle(fontSize: 18.sp), // 폰트 크기 증가
    );
  }

  // 알림 설정
  Widget _buildNotificationSettings() {
    return Text(
      "알림 설정",
      style: TextStyle(fontSize: 18.sp), // 폰트 크기 증가
    );
  }

  // 약관 섹션
  Widget _buildTermsSection() {
    return ExpansionTile(
      title: Text(
        "약관",
        style: TextStyle(
            fontSize: 18.sp, fontWeight: FontWeight.bold), // 폰트 크기 증가
      ),
      children: <Widget>[
        _buildTermsTile("서비스 이용약관"),
        _buildTermsTile("개인정보처리방침"),
        _buildTermsTile("오픈소스 라이선스"),
      ],
    );
  }

  // 약관 타일
  Widget _buildTermsTile(String title) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 16.sp), // 폰트 크기 증가
      ),
      onTap: () {
        // 약관 클릭 시 동작
      },
    );
  }

  // 계정 탈퇴 버튼
  Widget _buildDeleteAccountButton() {
    return ListTile(
      title: Text(
        "탈퇴하기",
        style: TextStyle(fontSize: 18.sp, color: Colors.red), // 폰트 크기 증가
      ),
      onTap: () {
        // 탈퇴하기 클릭 시 동작
        _deleteAccount();
      },
    );
  }

  // 계정 탈퇴 로직
  Future<void> _deleteAccount() async {
    if (id != null) {
      try {
        await appSettingsApi.deleteUser(id!);
        Fluttertoast.showToast(msg: "정상탈퇴 되었습니다.");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
              (route) => false,
        );
      } catch (err) {
        // 에러가 발생했을 때 DioError로 캐스팅하여 처리
        if (err is DioError) {
          final errorMessage = err.response?.data['message'] ??
              "탈퇴에 실패했습니다."; // 서버로부터 받은 에러 메시지 출력
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage, textAlign: TextAlign.center),
              backgroundColor: Colors.red, // 배경색 빨간색으로 설정
            ),
          );
        } else {
          // DioError 외의 에러 처리
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("알 수 없는 오류가 발생했습니다.", textAlign: TextAlign.center),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

