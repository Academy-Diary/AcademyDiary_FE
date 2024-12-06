import 'dart:io';
import 'package:academy_manager/UI/MemberInfoEdit_UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/UI/AppBar_UI.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:academy_manager/API/MyPage_API.dart';

class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final MyPageApi myPageApi = MyPageApi();
  String? profileImageUrl; // 서버에서 제공한 프로필 이미지 URL
  String? name = "", id = "", email = "", phone = "", role = "", family = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      await myPageApi.initTokens();

      String? userId = await MyPageApi.storage.read(key: 'user_id');
      print("불러온 ID: $userId"); // 디버깅용 로그 추가

      if (userId == null || userId.isEmpty) {
        print("ID not found in storage.");
        Fluttertoast.showToast(msg: "ID를 찾을 수 없습니다. 다시 로그인해주세요.");
        return;
      }

      // 사용자 정보 및 이미지 URL 가져오기
      print("Fetching user info for ID: $userId");
      var userInfo = await myPageApi.fetchUserInfo(userId);
      var imageUrl = await myPageApi.downloadUserProfileImage(userId);

      if (mounted) {
        setState(() {
          id = userId;
          name = userInfo['data']['user_name'] ?? '';
          email = userInfo['data']['email'] ?? '';
          phone = userInfo['data']['phone_number'] ?? '';
          role = userInfo['data']['role'] == "STUDENT" ? "학생" : "학부모";
          family = userInfo['data']['family'] ?? '';
          profileImageUrl = imageUrl ?? ''; // 이미지 URL
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
      if (mounted) {
        Fluttertoast.showToast(msg: "회원 정보를 불러오는 중 오류가 발생했습니다.");
      }
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
                foregroundImage: (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                    ? NetworkImage(profileImageUrl!)
                    : AssetImage('img/default.png') as ImageProvider,
                radius: 60.r,
                backgroundColor: Colors.grey[300],
              ),
            ),
            SizedBox(height: 30.h),
            _buildUserInfo(),
            if (role == "학부모" && family != null && family!.isNotEmpty) ...[
              SizedBox(height: 20.h),
              _buildStudentInfo(),
            ],
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

  Widget _buildStudentInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      width: double.infinity,
      decoration: BoxDecoration(border: Border.all(color: Colors.blue, width: 2.w)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("학생 아이디: $family", style: TextStyle(fontSize: 18.sp, color: Colors.blue)),
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
        var refresh = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemberInfoEdit(
              name: name.toString(),
              email: email.toString(),
              phone: phone.toString(),
              id: id.toString(),
              image: profileImageUrl != null && profileImageUrl!.isNotEmpty
                  ? NetworkImage(profileImageUrl!)
                  : AssetImage('img/default.png'), // 기본 이미지 전달
            ),
          ),
        );
        if (refresh['refresh']) {
          _loadData();
        }
      },
      child: Text('회원정보 수정', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
    );
  }
}
