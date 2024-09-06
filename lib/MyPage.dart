import 'package:academy_manager/AppBar.dart';  // AppBar.dart 파일에서 MyAppBar를 import
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/MemberInfoEdit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';  // MemberInfoEdit.dart 파일 import

class MyPage extends StatefulWidget {
  MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  var dio;

  static final storage = new FlutterSecureStorage();
  String? accessToken;
  String? refreshToken;

  String? name="", id="", email="", phone="";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dio = new Dio();
    dio.options.baseUrl =
    'http://192.168.0.118:8000'; //개발 중 백엔드 서버는 본인이 돌림.
    dio.options.connectTimeout = 5000; // 5s
    dio.options.receiveTimeout = 3000;
    dio.options.headers =
    {'Content-Type': 'application/json'};

    WidgetsBinding.instance.addPostFrameCallback((_){
      _asyncMethod();
    });

  }

  _asyncMethod() async{
    accessToken = await storage.read(key: 'accessToken');
    refreshToken = await storage.read(key: 'refreshToken');
    // 헤더에 accessToken과 refreshToken을 저장
    dio.options.headers['Authorization'] = 'Bear '+accessToken.toString();
    dio.options.headers['cookie'] = refreshToken;
    id = await storage.read(key: 'id');

    var response = await dio.get('/user/'+id.toString()+'/basic-info');
    name = response.data['user_name'];
    email = response.data['email'];
    phone = response.data['phone_number'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar().build(context),
      drawer: MenuDrawer(name: name.toString(), email: email.toString(), subjects: ['수학']),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60.r,
                backgroundColor: Colors.grey[300],
              ),
            ),
            SizedBox(height: 30.h),
            Container(
              padding: EdgeInsets.all(16.w),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("name: "+name.toString(), style: TextStyle(fontSize: 18.sp)),
                  SizedBox(height: 10.h),
                  Text("ID: "+id.toString(), style: TextStyle(fontSize: 18.sp)),
                  SizedBox(height: 10.h),
                  Text("Email: "+email.toString(), style: TextStyle(fontSize: 18.sp)),
                  SizedBox(height: 10.h),
                  Text("phone: "+phone.toString(), style: TextStyle(fontSize: 18.sp)),
                ],
              ),
            ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 36.w),
                backgroundColor: Color(0xFF565D6D),
              ),
              onPressed: () {
                // MemberInfoEdit 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MemberInfoEdit()),
                );
              },
              child: Text('회원정보 수정', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
            ),
          ],
        ),
      ),
    );
  }
}