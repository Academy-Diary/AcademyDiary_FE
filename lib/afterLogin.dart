import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AfterLoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context); // ScreenUtil 초기화

    final mainColor = Color(0xFF565D6D);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: mainColor,
        title: Text(
          'AcademyPro',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      drawer: MenuDrawer(name: "현우진", email: "test@abc.com", subjects: ["미적분", "영어", "국어"]),
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

  _MenuDrawerState({required this.name, required this.email, required this.subjects});

  @override
  Widget build(BuildContext context) {
    List<Widget> menu_subject = [];
    subjects.forEach((subject) {
      menu_subject.add(
        ListTile(
          title: Text(subject, style: TextStyle(fontSize: 14.sp)),
          onTap: () {
            // subject 별 이동 이벤트
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
                    },
                  ),
                  ListTile(
                    title: Text("수업공지", style: TextStyle(fontSize: 15.sp)),
                    onTap: () {
                      // 수업 공지 화면으로 이동
                    },
                  ),
                ],
              ),
            ),
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
                      // 성적조회 화면으로 이동
                    },
                  ),
                  ListTile(
                    shape: Border(bottom: BorderSide(color: Color(0xFFD9D9D9))),
                    title: Text("강의목록", style: TextStyle(fontSize: 15.sp)),
                    onTap: () {
                      setState(() {
                        isSubjectClicked = !isSubjectClicked;
                      });
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
                    title: Text("납부현황", style: TextStyle(fontSize: 15.sp)),
                    onTap: () {
                      // 납부현황 화면으로 이동
                    },
                  ),
                  ListTile(
                    title: Text("납부내역", style: TextStyle(fontSize: 15.sp)),
                    onTap: () {
                      // 납부내역 화면으로 이동
                    },
                  ),
                ],
              ),
            ),
          Spacer(),
          ListTile(
            title: Text("로그아웃", style: TextStyle(fontSize: 16.sp)),
            onTap: () {
              // 로그아웃 처리
            },
          ),
        ],
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
      },
    );
  }
}
