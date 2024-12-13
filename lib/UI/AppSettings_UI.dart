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
  String name = "", email = "";
  final AppSettingsApi appSettingsApi = AppSettingsApi();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData(); // 사용자 정보 로드
    });
  }

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
    appSettingsApi.addErrorInterceptor(context);

    return Scaffold(
      appBar: const MyAppBar().build(context), // 상단 AppBar
      drawer: const MenuDrawer(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            _buildSettingsBox(),
            const Spacer(),
            _buildDeleteAccountButton(),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  // 설정 박스 UI
  Widget _buildSettingsBox() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.5.w),
        borderRadius: BorderRadius.circular(10.r), // 박스 둥글게
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppVersion(),
          Divider(thickness: 1.w, height: 20.h),
          _buildNotificationSettings(),
          Divider(thickness: 1.w, height: 20.h),
          _buildTermsSection(),
        ],
      ),
    );
  }

  // 앱 버전 정보
  Widget _buildAppVersion() {
    return Text(
      "앱 버전 : v10.0.4",
      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
    );
  }

  // 알림 설정
  Widget _buildNotificationSettings() {
    return Text(
      "알림 설정",
      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
    );
  }

  // 약관 섹션
  Widget _buildTermsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "약관",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10.h),
        _buildTermsTile("서비스 이용약관"),
        _buildTermsTile("개인정보처리방침"),
        _buildTermsTile("오픈소스 라이선스"),
      ],
    );
  }

  // 약관 항목
  Widget _buildTermsTile(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: InkWell(
        onTap: () {
          // 약관 클릭 시 동작
        },
        child: Text(
          title,
          style: TextStyle(fontSize: 15.sp, color: Colors.grey[800]),
        ),
      ),
    );
  }

  // 계정 탈퇴 버튼
  Widget _buildDeleteAccountButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => _deleteAccount(),
        child: Text(
          "탈퇴하기",
          style: TextStyle(fontSize: 16.sp, color: Colors.red),
        ),
      ),
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
        String errorMessage = "알 수 없는 오류가 발생했습니다.";
        if (err is DioError) {
          errorMessage = err.response?.data['message'] ?? errorMessage;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage, textAlign: TextAlign.center),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
