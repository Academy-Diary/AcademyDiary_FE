import 'package:academy_manager/API/SubmitAcademyKey_API.dart';
import 'package:academy_manager/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SubmitAcademyKey extends StatefulWidget {
  final String name;

  SubmitAcademyKey({super.key, required this.name});

  @override
  State<SubmitAcademyKey> createState() => _SubmitAcademyKeyState(name);
}

class _SubmitAcademyKeyState extends State<SubmitAcademyKey> {
  final String name;
  final SubmitAcademyKeyApi submitAcademyKeyApi = SubmitAcademyKeyApi();
  late ScrollController _scrollController = ScrollController();
  TextEditingController keyInput = TextEditingController();

  _SubmitAcademyKeyState(this.name);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeService();
    });
  }

  Future<void> _initializeService() async {
    await submitAcademyKeyApi.initToken();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color mainColor = Color(0xFF565D6D);
    Color backColor = Color(0xFFD9D9D9);

    return Scaffold(
      backgroundColor: backColor,
      body: SafeArea(
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Center(
              child: Column(
                children: [
                  Text(
                    "AcademyPro",
                    style: TextStyle(fontSize: 40.sp),
                  ),
                  SizedBox(height: 239.h),
                  Text(
                    "$name님 환영합니다. \n\n아래 학원키를 입력 후 등록요청하기를 눌러주세요.",
                    style: TextStyle(fontSize: 20.sp),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 103.h),
                  SizedBox(
                    width: 341.w,
                    child: TextField(
                      controller: keyInput,
                      decoration: InputDecoration(
                        hintText: "학원키 입력",
                        hintStyle: TextStyle(fontSize: 18.sp),
                      ),
                    ),
                  ),
                  SizedBox(height: 103.h),
                  SizedBox(
                    width: 342.w,
                    height: 63.h,
                    child: ElevatedButton(
                      onPressed: () => _submitAcademyKey(),
                      child: Text(
                        "학원 등록 요청하기",
                        style: TextStyle(fontSize: 24.sp),
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

  Future<void> _submitAcademyKey() async {
    String? userId = await SubmitAcademyKeyApi.storage.read(key: 'id');
    String academyKey = keyInput.text;

    try {
      var response = await submitAcademyKeyApi.submitAcademyKey(userId!, academyKey);
      if (response.statusCode == 201) {
        Fluttertoast.showToast(
          msg: "학원 등록 요청이 완료되었습니다.",
          backgroundColor: Colors.grey,
          fontSize: 18.sp,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (builder) => MyApp()),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "학원 등록 요청 중 오류가 발생했습니다.");
    }
  }
}
