import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/UI/AppBar_UI.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:academy_manager/API/MemberInfoEdit_API.dart';
import 'package:email_validator/email_validator.dart';

class MemberInfoEdit extends StatefulWidget {
  final String name, email, phone, id;
  final ImageProvider image;

  MemberInfoEdit({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.id,
    required this.image,
  });

  @override
  State<MemberInfoEdit> createState() => _MemberInfoEditState();
}

class _MemberInfoEditState extends State<MemberInfoEdit> {
  XFile? newImage;
  bool isChangeImage = false;

  final List<TextEditingController> controller = [];
  final _globalKey = GlobalKey<FormState>();
  final MemberInfoApi memberInfoApi = MemberInfoApi();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      controller.add(TextEditingController());
    }

    controller[1].text = widget.email;
    controller[2].text = widget.phone;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      memberInfoApi.initTokens();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar().build(context),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            _buildProfileImage(),
            SizedBox(height: 30.h),
            _buildInfoForm(),
            SizedBox(height: 20.h),
            _buildSaveButton(),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Column(
      children: [
        CircleAvatar(
          backgroundImage: newImage == null
              ? widget.image
              : FileImage(File(newImage!.path)),
          radius: 70.r,
          backgroundColor: Colors.grey[300],
        ),
        SizedBox(height: 10.h),
        GestureDetector(
          onTap: changeImage,
          child: Column(
            children: [
              Divider(
                color: Colors.black,
                thickness: 1.w,
                indent: 100.w,
                endIndent: 100.w,
              ),
              Text(
                "사진 편집",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoForm() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2.w),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Form(
        key: _globalKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabelField("name", widget.name),
            SizedBox(height: 10.h),
            _buildPasswordField("password", controller[0]),
            SizedBox(height: 10.h),
            _buildPasswordField("password 확인", controller[0], isConfirm: true),
            SizedBox(height: 10.h),
            _buildTextField("Email", controller[1], true),
            SizedBox(height: 10.h),
            _buildTextField("phone", controller[2], false),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelField(String label, String value) {
    return Row(
      children: [
        SizedBox(width: 70.w, child: Text("$label :", style: TextStyle(fontSize: 16.sp))),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController ctrl, {bool isConfirm = false}) {
    return TextFormField(
      controller: ctrl,
      obscureText: true,
      validator: isConfirm
          ? (value) {
        if (value != ctrl.text) return "두 비밀번호가 다릅니다.";
        return null;
      }
          : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, bool isEmail) {
    return TextFormField(
      controller: ctrl,
      validator: (value) {
        if (value!.isEmpty) return "$label을 입력하세요.";
        if (isEmail && !EmailValidator.validate(value)) {
          return "올바른 형식의 Email을 입력하세요.";
        }
        if (!isEmail && !RegExp(r'^010-?([0-9]{4})-?([0-9]{4})$').hasMatch(value)) {
          return "올바른 형식의 휴대폰번호를 입력하세요.";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF565D6D),
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 80.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
        ),
        onPressed: () {
          if (_globalKey.currentState!.validate()) submit();
        },
        child: Text("저장", style: TextStyle(color: Colors.white, fontSize: 18.sp)),
      ),
    );
  }

  void submit() async {
    try {
      var response = await memberInfoApi.updateBasicInfo(
          widget.id, controller[0].text, controller[1].text, controller[2].text);

      if (isChangeImage) {
        await memberInfoApi.updateProfileImage(widget.id, newImage!);
      }

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "정상적으로 변경이 완료되었습니다.", backgroundColor: Colors.grey);
        Navigator.pop(context, {'refresh': true});
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
