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
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/main.dart';

class MyAppBar extends StatelessWidget {
  final bool isSettings;
  final String? token;

  const MyAppBar({super.key, this.isSettings = false, this.token});

  @override
  PreferredSizeWidget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: const Color(0xFF565D6D),
      title: const Text(
        'AcademyPro',
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PushList()),
            );
          },
        ),
        IconButton(
          icon: isSettings ? const Icon(Icons.settings) : const Icon(Icons.person),
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
  String? token;
  String? refreshToken;
  String? userId;
  String? academyId;

  final AppbarApi _appBarApi = AppbarApi();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    token = await _appBarApi.getAccessToken();
    refreshToken = await _appBarApi.getRefreshToken();
    userId = await _appBarApi.getUserId();
    academyId = await _appBarApi.getAcademyId();

    if (token != null && refreshToken != null) {
      await _appBarApi.addTokenInterceptors(token, refreshToken);
    }

    var info = await _appBarApi.getInfo();
    setState(() {
      name = info['user_name'];
      email = info['email'];
    });

    await _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    try {
      final fetchedSubjects = await _appBarApi.getStoredSubjects();
      setState(() {
        subjects = fetchedSubjects;
      });
    } catch (err) {
      print("Error loading subjects: $err");
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
      child: Column(
        children: [
          SizedBox(
            height: 140.h,
            child: UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF565D6D)),
              accountName: Text(name ?? "Loading...", style: TextStyle(fontSize: 18.sp)),
              accountEmail: Text(email ?? "Loading...", style: TextStyle(fontSize: 14.sp)),
            ),
          ),
          _buildMenuSection(
            title: "공지사항",
            isExpanded: isNoticeClicked,
            onTap: () => setState(() => isNoticeClicked = !isNoticeClicked),
            children: [
              _buildSubMenu("학원공지", () => Navigator.push(context, MaterialPageRoute(builder: (builder) => const NoticeList()))),
              _buildSubMenu("수업공지", () => Navigator.push(context, MaterialPageRoute(builder: (builder) => const NoticeList(isAcademy: false)))),
            ],
          ),
          _buildMenuSection(
            title: "성적관리",
            isExpanded: isGradeClicked,
            onTap: () => setState(() => isGradeClicked = !isGradeClicked),
            children: [
              _buildSubMenu("성적조회", () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (builder) => ViewScore(subjects: subjects, academyId: academyId ?? ''),
                ),
              )),
              _buildSubMenu("강의목록", () => setState(() => isSubjectClicked = !isSubjectClicked)),
              if (isSubjectClicked)
                Padding(
                  padding: EdgeInsets.fromLTRB(15.w, 0, 0, 0),
                  child: Column(children: menuSubjects),
                ),
            ],
          ),
          _buildMenuSection(
            title: "학원비",
            isExpanded: isExpenseClicked,
            onTap: () => setState(() => isExpenseClicked = !isExpenseClicked),
            children: [
              _buildSubMenu("청구서 조회", () => Navigator.push(context, MaterialPageRoute(builder: (builder) => const Bill()))),
              _buildSubMenu("납부 현황", () => Navigator.push(context, MaterialPageRoute(builder: (builder) => const BillList()))),
            ],
          ),
          ListTile(
            title: const Text("쪽지시험"),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (builder) => QuizListPage())),
          ),
          ListTile(
            title: const Text("채팅"),
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
          title: Text(title, style: TextStyle(fontSize: 16.sp)),
          trailing: Icon(isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
          onTap: onTap,
        ),
        if (isExpanded) Padding(padding: EdgeInsets.only(left: 15.w), child: Column(children: children)),
      ],
    );
  }

  Widget _buildSubMenu(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 15.sp)),
      onTap: onTap,
    );
  }
}
