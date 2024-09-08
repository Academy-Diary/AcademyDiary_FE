import 'dart:io';

import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/AppBar.dart';
import 'package:academy_manager/main.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class MemberInfoEdit extends StatefulWidget {
  String name, email, phone, id;
  FileImage image;
  MemberInfoEdit({super.key, required this.name, required this.email, required this.phone, required this.id, required this.image});

  @override
  State<MemberInfoEdit> createState() => _MemberInfoEditState(name: name, email: email, phone: phone, id: id, image: image);
}

class _MemberInfoEditState extends State<MemberInfoEdit> {
  String name, email, phone, id;
  FileImage image;
  XFile? newImage; // 변경 사진 저장 변수
  String? accessToken, refreshToken;
  bool isChangeImage = false; // 프로필 사진이 변경됐는지 여부 확인
  static final storage = new FlutterSecureStorage();

  var dio;

  List<TextEditingController> controller = [];
  final _globalKey = GlobalKey<FormState>();

  _MemberInfoEditState(
      {required this.name, required this.email, required this.phone, required this.id, required this.image});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (int i = 0; i < 3; i++)
      controller.add(new TextEditingController());

    dio = new Dio();
    dio.options.baseUrl =
    'http://192.168.0.118:8000';
    dio.options.connectTimeout = 5000; // 5s
    dio.options.receiveTimeout = 3000;
    dio.options.headers =
    {'Content-Type': 'application/json'};
    dio.interceptors.add(
        InterceptorsWrapper(
            onError: (DioError error, ErrorInterceptorHandler handler) {
              Fluttertoast.showToast(msg: error.response?.data["message"]);
              return handler.next(error);
            }
        )
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });

    controller[1].text = email;
    controller[2].text = phone;
  }

  _asyncMethod() async {
    accessToken = await storage.read(key: 'accessToken');
    refreshToken = await storage.read(key: 'refreshToken');

    dio.options.headers['Authorization'] = 'Bear ' + accessToken.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar().build(context),
      drawer: MenuDrawer(name: name, email: email, subjects: ['수학']),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: newImage == null ? image : FileImage(
                  File(newImage!.path)),
              radius: 50.r,
              backgroundColor: Colors.grey[300],
            ),
            SizedBox(height: 8.h),
            TextButton(
                onPressed: () {
                  changeImage();
                },
                child: Text('사진 편집', style: TextStyle(fontSize: 14.sp))),
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2.w),
              ),
              child: Form(
                key: _globalKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("name: " + name, style: TextStyle(fontSize: 16.sp)),
                    SizedBox(height: 10.h),
                    TextFormField(
                      controller: controller[0],
                      decoration: InputDecoration(labelText: 'password'),
                      obscureText: true,
                    ),
                    SizedBox(height: 10.h),
                    TextFormField(
                      validator: (value) {
                        if (value != controller[0].text) {
                          return "두 비밀번호가 다릅니다.";
                        } else
                          return null;
                      },
                      decoration: InputDecoration(labelText: 'password 확인'),
                      obscureText: true,
                    ),
                    SizedBox(height: 10.h),
                    TextFormField(
                      validator: (value) {
                        if (value
                            .toString()
                            .isEmpty)
                          return "email을 입력하세요";
                        else if (!EmailValidator.validate(value.toString())) {
                          return "올바른 형식의 email을 입력하세요";
                        } else
                          return null;
                      },
                      controller: controller[1],
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    SizedBox(height: 10.h),
                    TextFormField(
                      validator: (value) {
                        if (value
                            .toString()
                            .isEmpty)
                          return "전화번호를 입력하세요";
                        else if (!RegExp(r'^010-?([0-9]{4})-?([0-9]{4})$')
                            .hasMatch(value.toString())) {
                          // 전화번호 형식이 알맞게 입력됐는지 확인
                          return "올바른 형식의 휴대폰번호를 입력하세요";
                        } else
                          return null;
                      },
                      controller: controller[2],
                      decoration: InputDecoration(labelText: 'phone'),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        vertical: 12.h, horizontal: 24.w),
                    backgroundColor: Color(0xFF565D6D),
                  ),
                  onPressed: () {
                    if (_globalKey.currentState!.validate()) {
                      submit();
                    }
                  },
                  child: Text('저장',
                      style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                ),
                TextButton(onPressed: () {
                  delete();
                }, child: Text('탈퇴하기', style: TextStyle(fontSize: 10.sp),))
              ],
            ),
          ],
        ),
      ),
    );
  }

  submit() async {
    try {
      // 기본정보 변경
      var response = await dio.put('/user/' + id + '/basic-info',
          data: {
            "password": controller[0].text,
            'email': controller[1].text,
            'phone_number': controller[2].text,
          }
      );
      // 이미지 변경
      var response2;
      if (isChangeImage) {
        FormData formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(
              newImage!.path, contentType: MediaType('image', newImage!
              .path
              .split('/')
              .last
              .split('.')
              .last))
        });
        dio.options.headers['Content-Type'] = 'multipart/form-data';
        response2 =
        await dio.put('/user/' + id + '/image-info', data: formData);
      }
      if (response.statusCode == 200) {
        if (response2 != null || isChangeImage == false) {
          Fluttertoast.showToast(msg: '정상적으로 변경이 완료되었습니다.');
          Navigator.pop(context, true);
        }
      }
    } catch (err) {
      print(err);
    }
  }

  delete() async {
    dio.options.headers['Content-Type'] = 'application/json';
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

  changeImage() async {
    isChangeImage = true;
    newImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {

    });
  }
}