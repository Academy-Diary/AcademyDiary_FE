import 'package:academy_manager/API/AppBar_API.dart';
import 'package:academy_manager/UI/AppSettings_UI.dart';
import 'package:academy_manager/UI/BillList_UI.dart';
import 'package:academy_manager/UI/Bill_UI.dart';
import 'package:academy_manager/UI/MyPage_UI.dart';
import 'package:academy_manager/UI/PushList_UI.dart';
import 'package:academy_manager/UI/NoticeList_UI.dart';
import 'package:academy_manager/UI/ScoreGraph_UI.dart';
import 'package:academy_manager/UI/ViewScore_UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/main.dart';

class MyAppBar extends StatelessWidget {
  final bool isSettings; // isSettings 플래그 추가
  final String? token;

  const MyAppBar({super.key, this.isSettings = false, this.token}); // 기본값은 false로 설정

  @override
  PreferredSizeWidget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Color(0xFF565D6D),
      title: Text(
        'AcademyPro',
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () {
            // 알림 버튼 클릭 시 처리할 로직
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PushList())
            );
          },
        ),
        IconButton(
          icon: isSettings ? Icon(Icons.settings) : Icon(Icons.person),
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

  MenuDrawer();

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  String? name;
  String? email;
  List<Map<String, dynamic>> subjects = [];  // 수강 중인 과목을 리스트로 저장
  bool isNoticeClicked = false;
  bool isGradeClicked = false;
  bool isExpenseClicked = false;
  bool isSubjectClicked = false;
  String? token;
  String? refreshToken;
  String? userId;  // userId 추가

  final AppbarApi _appBarApi = AppbarApi(); // AuthService 객체 생성

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  // 토큰 초기화 && Drawer 상단 이름, 이메일
  Future<void> _initialize() async {
    token = await _appBarApi.getAccessToken();
    refreshToken = await _appBarApi.getRefreshToken();
    userId = await _appBarApi.getUserId();  // userId 가져오기

    if (token != null && refreshToken != null) {
      await _appBarApi.addTokenInterceptors(token, refreshToken);
    }

    var info = await _appBarApi.getInfo();
    setState(() {
      name = info['user_name'];
      email = info['email'];
    });

    // 과목 리스트 불러오기
    await _loadSubjects();
  }

  // **수강 중인 과목 불러오기**
  Future<void> _loadSubjects() async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인 정보가 유효하지 않습니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      print("Fetching subjects for userId: $userId");
      List<Map<String, dynamic>> fetchedSubjects = await _appBarApi.fetchSubjects(userId!);
      setState(() {
        subjects = fetchedSubjects;  // 수강 중인 과목 리스트를 업데이트
      });
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("과목 불러오기 실패: $err"),  // 구체적인 에러 메시지 출력
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 과목 리스트 저장
    List<Widget> menu_subject = subjects.map((subject) {
      return ListTile(
        title: Text(subject['lecture_name'], style: TextStyle(fontSize: 14.sp)),
        onTap: () {
          // 과목 클릭 시 처리할 로직
          Navigator.push(
            context,
            MaterialPageRoute(builder: (builder) => ScoreGraph(subjectName: subject['lecture_name'])),
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
              decoration: BoxDecoration(
                color: Color(0xFF565D6D),
              ),
              accountName: Text(name.toString(), style: TextStyle(fontSize: 18.sp)),
              accountEmail: Text(email.toString(), style: TextStyle(fontSize: 14.sp)),
            ),
          ),
          // 공지사항 메뉴
          ListTile(
            shape: Border(bottom: BorderSide(color: Color(0xFFD9D9D9))),
            title: Text("공지사항", style: TextStyle(fontSize: 16.sp)),
            onTap: () {
              setState(() {
                isNoticeClicked = !isNoticeClicked;
              });
            },
            trailing: !isNoticeClicked
                ? Icon(Icons.arrow_drop_down)
                : Icon(Icons.arrow_drop_up),
          ),
          if (isNoticeClicked)
            Padding(
              padding: EdgeInsets.fromLTRB(15.w, 0, 0, 0),
              child: Column(
                children: [
                  ListTile(
                    title: Text("학원공지", style: TextStyle(fontSize: 15.sp)),
                    onTap: () {
                      // 학원 공지 화면으로 이동
                      Navigator.push(context, MaterialPageRoute(builder: (builder) => NoticeList()));
                    },
                  ),
                  ListTile(
                    title: Text("수업공지", style: TextStyle(fontSize: 15.sp)),
                    onTap: () {
                      // 수업 공지 화면으로 이동
                      Navigator.push(context, MaterialPageRoute(builder: (builder) => NoticeList(isAcademy: false)));
                    },
                  ),
                ],
              ),
            ),
          // 성적 관리 메뉴
          ListTile(
            shape: Border(bottom: BorderSide(color: Color(0xFFD9D9D9))),
            title: Text("성적관리", style: TextStyle(fontSize: 16.sp)),
            onTap: () {
              setState(() {
                isGradeClicked = !isGradeClicked;
                if (!isGradeClicked) isSubjectClicked = false;
              });
            },
            trailing: !isGradeClicked
                ? Icon(Icons.arrow_drop_down)
                : Icon(Icons.arrow_drop_up),
          ),
          if (isGradeClicked)
            Padding(
              padding: EdgeInsets.fromLTRB(15.w, 0, 0, 0),
              child: Column(
                children: [
                  ListTile(
                    title: Text("성적조회", style: TextStyle(fontSize: 15.sp)),
                    onTap: () {
                      // 성적 조회 화면으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (builder) => ViewScore()),
                      );
                    },
                  ),
                  ListTile(
                    shape: Border(bottom: BorderSide(color: Color(0xFFD9D9D9))),
                    title: Text("강의목록", style: TextStyle(fontSize: 15.sp)),
                    onTap: () async {
                      setState(() {
                        isSubjectClicked = !isSubjectClicked;
                      });

                      if (isSubjectClicked) {
                        await _loadSubjects();  // 강의 목록 클릭 시 과목 조회
                      }
                    },
                    trailing: !isSubjectClicked
                        ? Icon(Icons.arrow_drop_down)
                        : Icon(Icons.arrow_drop_up),
                  ),
                  if (isSubjectClicked)
                    Padding(
                      padding: EdgeInsets.fromLTRB(15.w, 0, 0, 0),
                      child: Column(
                        children: menu_subject,
                      ),
                    ),
                ],
              ),
            ),
          // 학원비 메뉴
          ListTile(
            shape: Border(bottom: BorderSide(color: Color(0xFFD9D9D9))),
            title: Text("학원비", style: TextStyle(fontSize: 16.sp)),
            onTap: () {
              setState(() {
                isExpenseClicked = !isExpenseClicked;
              });
            },
            trailing: !isExpenseClicked
                ? Icon(Icons.arrow_drop_down)
                : Icon(Icons.arrow_drop_up),
          ),
          if (isExpenseClicked)
            Padding(
              padding: EdgeInsets.fromLTRB(15.w, 0, 0, 0),
              child: Column(
                children: [
                  ListTile(
                    title: Text("청구서 조회", style: TextStyle(fontSize: 15.sp)),
                    onTap: () {
                      // 청구서 조회 화면으로 이동
                      Navigator.push(context, MaterialPageRoute(builder: (builder) => Bill()));
                    },
                  ),
                  ListTile(
                    title: Text("납부 현황", style: TextStyle(fontSize: 15.sp)),
                    onTap: () {
                      // 납부 현황 화면으로 이동
                      Navigator.push(context, MaterialPageRoute(builder: (builder) => BillList()));
                    },
                  ),
                ],
              ),
            ),
          Spacer(),
          // 로그아웃 메뉴
          ListTile(
            title: Text("로그아웃", style: TextStyle(fontSize: 16.sp)),
            onTap: () async {
              try {
                await _appBarApi.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                      (route) => false,
                );
              } catch (err) {
                // 오류 처리 로직
              }
            },
          ),
        ],
      ),
    );
  }
}
