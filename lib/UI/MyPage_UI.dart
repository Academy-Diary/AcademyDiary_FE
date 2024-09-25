import 'dart:io';
import 'package:academy_manager/UI/MemberInfoEdit_UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/UI/AppBar_UI.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:academy_manager/API/MyPage_API.dart';

class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final MyPageApi myPageApi = MyPageApi();
  File? file;
  String? name = "", id = "", email = "", phone = "", role = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await myPageApi.initTokens();

    // id가 null인지 확인
    String? userId = await MyPageApi.storage.read(key: 'id');

    if (userId != null) {
      // 사용자 정보 및 프로필 이미지 가져오기
      var userInfo = await myPageApi.fetchUserInfo(userId);
      var profileImage = await myPageApi.downloadUserProfileImage(userId);

      setState(() {
        id = userId; // id 반영
        name = userInfo['user_name'];
        email = userInfo['email'];
        phone = userInfo['phone_number'];
        role = userInfo['role']== "STUDENT"? "학생" : "학부모";
        file = profileImage;
      });
    } else {
      // id가 null일 경우 처리
      Fluttertoast.showToast(msg: "ID를 찾을 수 없습니다.");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(isSettings: true).build(context),
      drawer: MenuDrawer(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: CircleAvatar(
                foregroundImage: (file != null && file!.existsSync())
                    ? FileImage(file!)
                    : AssetImage('img/default.png') as ImageProvider, // 기본 이미지 경로
                radius: 60.r,
                backgroundColor: Colors.grey[300],
              ),
            ),

            SizedBox(height: 30.h),
            _buildUserInfo(),
            Spacer(),
            _buildEditButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      width: double.infinity,
      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2.w)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("name: $name($role)", style: TextStyle(fontSize: 18.sp)),
          SizedBox(height: 10.h),
          Text("ID: $id", style: TextStyle(fontSize: 18.sp)),
          SizedBox(height: 10.h),
          Text("Email: $email", style: TextStyle(fontSize: 18.sp)),
          SizedBox(height: 10.h),
          Text("phone: $phone", style: TextStyle(fontSize: 18.sp)),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 36.w),
        backgroundColor: Color(0xFF565D6D),
      ),
      onPressed: () async {
        // 회원정보 수정 화면으로 이동
        var refresh = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MemberInfoEdit(
            name: name.toString(),
            email: email.toString(),
            phone: phone.toString(),
            id: id.toString(),
            image: FileImage(file!),
          )),
        );
        if (refresh['refresh']) {
          _loadData(); // 데이터 다시 로드
        }
      },
      child: Text('회원정보 수정', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
    );
  }
}
