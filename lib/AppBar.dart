import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:academy_manager/main.dart';

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
  String? token; // 토큰
  String? refreshToken; //refreshToken

  var dio = new Dio();

  static final storage = new FlutterSecureStorage();

  _MenuDrawerState({ required this.name, required this.email, required this.subjects});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
      _asyncMethod();
    });

    // http 통신을 위한 기본 option 설정
    dio.options.baseUrl='http://192.168.0.118:8000';
    dio.options.connectTimeout = 5000; // 5s
    dio.options.receiveTimeout = 3000;
  }

  _asyncMethod() async{
    token = await storage.read(key: 'accessToken');
    refreshToken = await storage.read(key: 'refreshToken');

    // header 추가
    dio.options.headers={
      'Content-Type': 'application/json',
    };

    dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler){
            options.headers['Authorization'] = token;
            options.headers['cookie'] = refreshToken;
            return handler.next(options);
          },
            onError: (DioError error, ErrorInterceptorHandler handler){
              if(error.response?.statusCode == 400){
                Map<String, dynamic> res = jsonDecode(error.response.toString());
                Fluttertoast.showToast(msg: res["message"]);
              }
              return handler.next(error);
            }
        )
    );
  }

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
            onTap: () async{
              // 로그아웃 처리
              var response;
              try{
                response = await dio.post('/user/logout');
                Map<String, dynamic> res = jsonDecode(response.toString());
                await storage.delete(key: "login"); // secure storage에 저장된 아이디,패스워드 값 지우기
                await storage.delete(key: 'accessToken');
                await storage.delete(key: 'refreshToken');
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyApp()));
              }catch(err){

              }
            },
          ),
        ],
      ),
    );
  }
}

