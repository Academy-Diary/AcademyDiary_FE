import 'dart:io';
import 'dart:ui';

import 'package:academy_manager/AfterLogin.dart';
import 'package:academy_manager/AppBar.dart';  // AppBar.dart 파일에서 MyAppBar를 import
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/MemberInfoEdit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:academy_manager/MyDio.dart';

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

  File? file;

  var path; // 이미지 저장하는 위치

  var response, dir;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    dio = new MyDio();

    WidgetsBinding.instance.addPostFrameCallback((_){
      _asyncMethod();
    });

  }



  _asyncMethod() async{
    accessToken = await storage.read(key: 'accessToken');
    refreshToken = await storage.read(key: 'refreshToken');
    // 헤더에 accessToken과 refreshToken을 저장
    dio.addResponseInterceptor('Authorization', 'Bear '+accessToken.toString());
    dio.addResponseInterceptor('cookie', refreshToken);
    id = await storage.read(key: 'id');
    dir = await getApplicationDocumentsDirectory(); // application 저장소 접근
    // 기존에 있던 이미지 파일 삭제
    try{
      File(path);
      await File(file!.path).delete(); // 기존에 있던 파일 삭제
      file = null;
    }catch(err){print(err);}

    path = dir.path+'/'+id.toString()+DateTime.now().toString(); // 시간대별로 새로운 이미지 이름을 만들어 저장

    response = await dio.get('/user/'+id.toString()+'/basic-info');

    await dio.download('/user/'+id.toString()+'/image-info', path);
    file = File(path);

    setState(() {
      print("start setState");
      file = null;
      file = File(path);

      name = response.data['user_name'];
      id = id;
      email = response.data['email'];
      phone = response.data['phone_number'];
      print("end setState");
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(isSettings: true,).build(context),
      drawer: MenuDrawer(name: name.toString(), email: email.toString(), subjects: ['수학']),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: CircleAvatar(
                foregroundImage: (file != null)? FileImage(file!): AssetImage('img/default.png'),
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
              onPressed: () async {
                // MemberInfoEdit 화면으로 이동
                var refresh = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MemberInfoEdit(name: name.toString(), email: email.toString(), phone: phone.toString(), id: id.toString(),image: FileImage(file!))),
                );
                if(refresh['refresh']){
                  Navigator.popAndPushNamed(context, "/myPage");
                  print(true);
                }

              },
              child: Text('회원정보 수정', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
            ),
          ],
        ),
      ),
    );
  }
}