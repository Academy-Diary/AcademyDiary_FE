import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyAppBar extends StatelessWidget{
  const MyAppBar({super.key});

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
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {},
        ),
      ],
    );
  }
}


class MenuDrawer extends StatefulWidget {
  final String name;
  final String email;
  final List<String> subjects;
  final String token;
  const MenuDrawer({super.key, required this.token, required this.name, required this.email, required this.subjects});

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

