import 'package:academy_manager/API/AppBar_API.dart';
import 'package:academy_manager/AppBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MenuDrawer extends StatefulWidget {
  final String name;
  final String email;
  final List<String> subjects;
  const MenuDrawer({super.key, required this.name, required this.email, required this.subjects});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState(name: name, email: email, subjects: subjects);
}

class _MenuDrawerState extends State<MenuDrawer> {
  final String name;
  final String email;
  final List<String> subjects;
  bool isNoticeClicked = false;
  bool isGradeClicked = false;
  bool isExpenseClicked = false;
  bool isSubjectClicked = false;
  String? token;
  String? refreshToken;

  final AuthService _authService = AuthService();

  _MenuDrawerState({ required this.name, required this.email, required this.subjects});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTokens();
    });
  }

  Future<void> _initializeTokens() async {
    token = await _authService.getAccessToken();
    refreshToken = await _authService.getRefreshToken();

    if (token != null && refreshToken != null) {
      await _authService.addTokenInterceptors(token, refreshToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 메뉴 및 UI 관련 코드
    List<Widget> menu_subject = [];
    subjects.forEach((subject) {
      menu_subject.add(
        ListTile(
          title: Text(subject, style: TextStyle(fontSize: 14.sp)),
          onTap: () {
            // 과목 선택 시 이벤트
          },
        ),
      );
    });

    return Drawer(
      child: Column(
        children: [
          SizedBox(
            height: 140.h,
            child: UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF565D6D),
              ),
              accountName: Text(name, style: TextStyle(fontSize: 18.sp)),
              accountEmail: Text(email, style: TextStyle(fontSize: 14.sp)),
            ),
          ),
          // 공지사항 메뉴 및 기타 UI
          // ...
          Spacer(),
          ListTile(
            title: Text("로그아웃", style: TextStyle(fontSize: 16.sp)),
            onTap: () async {
              try {
                await _authService.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MyAppBar()),
                      (route) => false,
                );
              } catch (err) {
                // 오류 처리
              }
            },
          ),
        ],
      ),
    );
  }
}
