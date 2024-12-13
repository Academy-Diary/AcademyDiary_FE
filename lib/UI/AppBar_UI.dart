import 'dart:convert'; // FlutterSecureStorage 데이터 변환용
import 'package:academy_manager/API/AppBar_API.dart';
import 'package:academy_manager/UI/AppSettings_UI.dart';
import 'package:academy_manager/UI/BillList_UI.dart';
import 'package:academy_manager/UI/Bill_UI.dart';
import 'package:academy_manager/UI/ChattingList_UI.dart';
import 'package:academy_manager/UI/MyPage_UI.dart';
import 'package:academy_manager/UI/PushList_UI.dart';
import 'package:academy_manager/UI/NoticeList_UI.dart';
import 'package:academy_manager/UI/QuizList_UI.dart';
import 'package:academy_manager/UI/ScoreGraph_UI.dart';
import 'package:academy_manager/UI/ViewScore_UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // SecureStorage 추가
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/main.dart';

class MyAppBar extends StatelessWidget {
  final bool isSettings;
  final String? token;

  const MyAppBar({super.key, this.isSettings = false, this.token});

  @override
  PreferredSizeWidget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(color: Color(0xFF064420)),
      backgroundColor: const Color(0xFFEEEBDD),
      title: const Text(
        '아카데미 다이어리',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Color(0xFF064420)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PushList()),
            );
          },
        ),
        IconButton(
          icon: isSettings
              ? const Icon(Icons.settings, color: Color(0xFF064420))
              : const Icon(Icons.person, color: Color(0xFF064420)),
          onPressed: () {
            if (isSettings) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AppSettings()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyPage()),
              );
            }
          },
        ),
      ],
    );
  }
}

class MenuDrawer extends StatefulWidget {
  const MenuDrawer();

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  String? name;
  String? email;
  List<Map<String, dynamic>> subjects = [];
  bool isNoticeClicked = false;
  bool isGradeClicked = false;
  bool isExpenseClicked = false;
  bool isSubjectClicked = false;

  final AppbarApi _appBarApi = AppbarApi();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    try {
      final userInfo = await _appBarApi.getInfo();
      final fetchedSubjects = await _appBarApi.fetchAndStoreSubjects();

      setState(() {
        name = userInfo['user_name'];
        email = userInfo['email'];
        subjects = fetchedSubjects;
      });
    } catch (err) {
      print("초기화 중 오류 발생: $err");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> menuSubjects = subjects.map((subject) {
      return ListTile(
        title: Text(subject['lecture_name'], style: TextStyle(fontSize: 14.sp)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (builder) => ScoreGraph(subjectName: subject['lecture_name']),
            ),
          );
        },
      );
    }).toList();

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // 상단 헤더 부분
        Container(
        height: 62.h,
        color: const Color(0xFFEEEBDD),
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 8.h), // 글씨를 아래로 내리기 위해 추가
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
        Expanded(
        child: Center( // 글씨를 정확히 가운데 정렬
        child: Text(
          "전체 메뉴",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    ),
    Padding(
    padding: EdgeInsets.only(right: 20.w), // 햄버거 아이콘 오른쪽 여백
    child: const Icon(Icons.menu, color: Colors.black),
    ),
              ],
            ),
          ),
          // 공지사항 섹션
          _buildMenuSection(
            title: "공지사항",
            isExpanded: isNoticeClicked,
            onTap: () => setState(() => isNoticeClicked = !isNoticeClicked),
            children: [
              _buildSubMenu("학원 공지", () => Navigator.push(context, MaterialPageRoute(builder: (builder) => const NoticeList()))),
              _buildSubMenu("수업 공지", () => Navigator.push(context, MaterialPageRoute(builder: (builder) => const NoticeList(isAcademy: false)))),
            ],
          ),
          // 성적 관리 섹션
          _buildMenuSection(
            title: "성적 관리",
            isExpanded: isGradeClicked,
            onTap: () => setState(() => isGradeClicked = !isGradeClicked),
            children: [
              _buildSubMenu("전체성적조회", () => Navigator.push(context, MaterialPageRoute(builder: (builder) => ViewScore(subjects: subjects, academyId: '')))),
              _buildSubMenu("강의 목록", () => setState(() => isSubjectClicked = !isSubjectClicked)),
              if (isSubjectClicked)
                Padding(
                  padding: EdgeInsets.only(left: 20.w),
                  child: Column(children: menuSubjects),
                ),
            ],
          ),
          // 학원비 섹션
          _buildMenuSection(
            title: "학원비",
            isExpanded: isExpenseClicked,
            onTap: () => setState(() => isExpenseClicked = !isExpenseClicked),
            children: [
              _buildSubMenu("청구서 확인", () => Navigator.push(context, MaterialPageRoute(builder: (builder) => const Bill()))),
              _buildSubMenu("납부 현황", () => Navigator.push(context, MaterialPageRoute(builder: (builder) => const BillList()))),
            ],
          ),
          ListTile(
            title: const Text("쪽지시험",
            style: TextStyle(
              fontSize: 20
            ),),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (builder) => QuizListPage())),
          ),
          ListTile(
            title: const Text("채팅",
            style: TextStyle(
              fontSize: 20
            ),),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (builder) => ChattingListUI())),
          ),
          const Spacer(),
          ListTile(
            title: const Text("로그아웃"),
            onTap: () async {
              await _appBarApi.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return Column(
      children: [
        ListTile(
          title: Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          trailing: Icon(isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
          onTap: onTap,
        ),
        if (isExpanded) Column(children: children),
      ],
    );
  }

  Widget _buildSubMenu(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 14.sp)),
      onTap: onTap,
    );
  }
}
