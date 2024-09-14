import 'package:academy_manager/MyDio.dart';
import 'package:academy_manager/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart'; // 화면크기에 따라 ui 크기 설정 및 재배치

class SubmitAcademyKey extends StatefulWidget {
  String name;
  MyDio? dio;
  SubmitAcademyKey({super.key, required this.name, this.dio});

  @override
  State<SubmitAcademyKey> createState() => _SubmitAcademyKeyState(this.name, this.dio);
}

class _SubmitAcademyKeyState extends State<SubmitAcademyKey> {
  String name;
  MyDio? dio;
  _SubmitAcademyKeyState(this.name, this.dio); // SignupPage에서 만든 MyDio()인스턴스를 가져옴
  late ScrollController _scrollController = ScrollController();
  TextEditingController keyInput = TextEditingController();

  // Secure Storage 접근을 위한 변수 초기화
  static final storage = FlutterSecureStorage();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(dio == null){
      //MyDio를 넘겨받지 않았을 때
      dio = new MyDio();
      _asyncMethod();

    }
  }

  _asyncMethod() async{
    String? accessToken = await storage.read(key: 'accessToken');
    dio!.addResponseInterceptor('Authorization', 'Bear ' + accessToken.toString());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    dio!.addErrorInterceptor(context);
    Color mainColor = Color(0xFF565D6D);
    Color backColor = Color(0xFFD9D9D9);
    return Scaffold(
      backgroundColor: backColor,
      body: SafeArea(
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView (
            controller: _scrollController,
            child: Center(
              child: Column(
                children: [
                  Text(
                    "AcademyPro",
                    style: TextStyle(
                      fontSize: 40.sp,
                    ),
                  ),
                  SizedBox(
                    height: 239.h,
                  ),
                  Text(
                    "${name}님 환영합니다. \n\n아래 학원키를 입력 후 등록요청하기를 눌러주세요.",
                    style: TextStyle(
                      fontSize: 20.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 103.h,
                  ),
                  SizedBox(
                    width: 341.w,
                    child: TextField(
                      controller: keyInput,
                      decoration: InputDecoration(
                        hintText: "학원키 입력",
                        hintStyle: TextStyle(
                          fontSize: 18.sp
                        )
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 103.h,
                  ),
                  SizedBox(
                    width: 342.w,
                    height: 63.h,
                    child: ElevatedButton(
                        onPressed: (){
                          submitAcademyKey();
                        },
                        child: Text(
                          "학원 등록 요청하기",
                          style: TextStyle(
                            fontSize: 24.sp
                          ),
                        ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  submitAcademyKey()async{
    String? user_id = await storage.read(key: 'id');
    String academyKey = keyInput.text;
    var response = await dio!.post('/registeration/request/user', data: {
      'user_id' : user_id.toString(),
      'academy_key' : academyKey,
      'role' : 'STUDENT'
    });
    if(response.statusCode == 201){
      Fluttertoast.showToast(
          msg: "학원 등록 요청이 완료되었습니다.",
        backgroundColor: Colors.grey,
        fontSize: 18.sp
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder)=>MyApp()));
    }
  }
}
