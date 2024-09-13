import 'package:academy_manager/AppBar.dart';  // AppBar.dart 파일에서 MyAppBar를 import
import 'package:academy_manager/MyDio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/main.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppSettings extends StatefulWidget {

  @override
  _AppSettingsState createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  String? id, accessToken;

  String name="", email="";

  static final dio = new MyDio();

  static final storage = new FlutterSecureStorage();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_){
      _asyncMethod();
    });
  }

  _asyncMethod() async{
    id = await storage.read(key: 'id');
    accessToken = await storage.read(key: 'accessToken');

    dio.addResponseInterceptor('Authorization', 'Bear '+accessToken.toString());

    var response = await dio.get('/user/'+id.toString()+'/basic-info');
    setState(() {
      name = response.data['user_name'];
      email = response.data['email'];
    });
  }

  @override
  Widget build(BuildContext context) {
    dio.addErrorInterceptor(context);
    return Scaffold(
      appBar: MyAppBar().build(context),
      drawer: MenuDrawer(name: name, email: email, subjects: ['수학']),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "앱 버전: v10.0.4",
              style: TextStyle(fontSize: 18.sp), // 폰트 크기 증가
            ),
            SizedBox(height: 20.h),
            Text(
              "알림 설정",
              style: TextStyle(fontSize: 18.sp), // 폰트 크기 증가
            ),
            SizedBox(height: 30.h),
            ExpansionTile(
              title: Text(
                "약관",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold), // 폰트 크기 증가
              ),
              children: <Widget>[
                ListTile(
                  title: Text(
                    "서비스 이용약관",
                    style: TextStyle(fontSize: 16.sp), // 폰트 크기 증가
                  ),
                  onTap: () {
                    // 서비스 이용약관 클릭 시 동작
                  },
                ),
                ListTile(
                  title: Text(
                    "개인정보처리방침",
                    style: TextStyle(fontSize: 16.sp), // 폰트 크기 증가
                  ),
                  onTap: () {
                    // 개인정보처리방침 클릭 시 동작
                  },
                ),
                ListTile(
                  title: Text(
                    "오픈소스 라이선스",
                    style: TextStyle(fontSize: 16.sp), // 폰트 크기 증가
                  ),
                  onTap: () {
                    // 오픈소스 라이선스 클릭 시 동작
                  },
                ),
              ],
            ),
            Spacer(),
            ListTile(
              title: Text(
                "탈퇴하기",
                style: TextStyle(fontSize: 18.sp, color: Colors.red), // 폰트 크기 증가
              ),
              onTap: () {
                // 탈퇴하기 클릭 시 동작
                delete();
              },
            ),
          ],
        ),
      ),
    );
  }

  delete() async {
    dio.addResponseInterceptor('Content-Type', 'application/json');
    try {
      var response = await dio.delete('/user/'+id.toString());
      if(response.statusCode == 200){
        Fluttertoast.showToast(msg: "정상탈퇴 되었습니다.");
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>MyApp()), (route)=>false);
      }
    } catch (err) {
      print(err);
      Navigator.pop(context);
    }
  }
}
