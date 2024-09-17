import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/UI/AppBar_UI.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:academy_manager/API/MemberInfoEdit_API.dart';
import 'package:email_validator/email_validator.dart';

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
  XFile? newImage;
  bool isChangeImage = false;

  final List<TextEditingController> controller = [];
  final _globalKey = GlobalKey<FormState>();
  final MemberInfoApi memberInfoApi = MemberInfoApi();

  _MemberInfoEditState({required this.name, required this.email, required this.phone, required this.id, required this.image});

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      controller.add(TextEditingController());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      memberInfoApi.initTokens();
    });

    controller[1].text = email;
    controller[2].text = phone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(isSettings: true).build(context),
      drawer: MenuDrawer(name: name, email: email, subjects: ['수학']),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: newImage == null ? image : FileImage(File(newImage!.path)),
              radius: 50.r,
              backgroundColor: Colors.grey[300],
            ),
            SizedBox(height: 8.h),
            TextButton(
                onPressed: () => changeImage(),
                child: Text('사진 편집', style: TextStyle(fontSize: 14.sp))),
            SizedBox(height: 20.h),
            _buildInfoForm(),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w), backgroundColor: Color(0xFF565D6D)),
                  onPressed: () {
                    if (_globalKey.currentState!.validate()) {
                      submit();
                    }
                  },
                  child: Text('저장', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoForm() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2.w)),
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
                }
                return null;
              },
              decoration: InputDecoration(labelText: 'password 확인'),
              obscureText: true,
            ),
            SizedBox(height: 10.h),
            TextFormField(
              validator: (value) {
                if (value.toString().isEmpty) return "email을 입력하세요";
                if (!EmailValidator.validate(value.toString())) {
                  return "올바른 형식의 email을 입력하세요";
                }
                return null;
              },
              controller: controller[1],
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 10.h),
            TextFormField(
              validator: (value) {
                if (value.toString().isEmpty) return "전화번호를 입력하세요";
                if (!RegExp(r'^010-?([0-9]{4})-?([0-9]{4})$').hasMatch(value.toString())) {
                  return "올바른 형식의 휴대폰번호를 입력하세요";
                }
                return null;
              },
              controller: controller[2],
              decoration: InputDecoration(labelText: 'phone'),
            ),
          ],
        ),
      ),
    );
  }

  void submit() async {
    try {
      var response = await memberInfoApi.updateBasicInfo(id, controller[0].text, controller[1].text, controller[2].text);

      if (isChangeImage) {
        await memberInfoApi.updateProfileImage(id, newImage!);
      }

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "정상적으로 변경이 완료되었습니다.", backgroundColor: Colors.grey);
        Navigator.pop(context, {
          'refresh': true,
          if (isChangeImage) 'profile': File(newImage!.path),
        });
      }
    } catch (err) {
      print(err);
    }
  }

  void changeImage() async {
    newImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (newImage != null) {
      setState(() {
        isChangeImage = true;
      });
    }
  }
}
