import 'package:academy_manager/UI/AfterSignup_UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:academy_manager/Dio/MyDio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/UI/Signup_UI.dart';
import 'package:dio/dio.dart';

class SignupPageAPI {
  static final MyDio dio = MyDio();

  static Future<void> checkDuplicateID(
      BuildContext context,
      String id,
      Function(bool) setState,  // 상태를 업데이트하는 함수
      ) async {
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "아이디 값을 입력하세요",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      try {
        var response = await dio.get('/user/check-id/$id');

        if (response.statusCode == 200) {
          var responseData = response.data;

          if (responseData['message'] == '사용 가능한 아이디입니다.') {
            setState(true);  // 중복체크 성공 시 true로 상태 업데이트
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "사용 가능한 아이디입니다.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
                duration: Duration(seconds: 1),
              ),
            );
          } else {
            setState(false);  // 중복된 아이디인 경우 false로 상태 업데이트
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "중복된 아이디입니다.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
                duration: Duration(seconds: 1),
              ),
            );
          }
        }
      } catch (e) {
        setState(false);  // 오류 발생 시에도 false로 상태 업데이트

        // MyDio의 ErrorInterceptor에서 서버로부터 받은 에러 메시지를 가져오기
        if (e is DioError && e.response != null && e.response?.data != null) {
          // 서버로부터 받은 에러 메시지가 있을 경우 해당 메시지 출력
          final errorMessage = e.response?.data['message'] ?? "통신 중 오류가 발생하였습니다.";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // 서버 메시지가 없을 경우 일반 통신 오류 메시지 출력
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "통신 중 오류가 발생하였습니다.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }


  static Future<void> signup(
      BuildContext context,
      List<TextEditingController> controllers,
      Role role,
      GlobalKey<FormState> formKey,
      bool idck,
      FlutterSecureStorage storage,
      Function setState,
      ) async {
    if (!idck) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "아이디 중복확인을 누르세요",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    if (formKey.currentState!.validate()) {
      List<String> values = controllers.map((controller) => controller.text).toList();

      var response = await dio.post('/user/signup', data: {
        "user_id": values[1],
        "email": values[3],
        "user_name": values[0],
        "password": values[2],
        "phone_number": values[4],
        "birth_date": values[5] + "T00:00:00Z",
        "role": role == Role.STUDENT ? "STUDENT" : "PARENT",
      });

      if (response.statusCode == 201) {
        if (values[6].isEmpty) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => AfterSignUp(
                name: values[0],
                role: role == Role.STUDENT ? 1 : 0,
                isKey: false,
              ),
            ),
                (route) => false,
          );
        } else {
          if (role == Role.STUDENT) {
            // 학생일 경우 기존 로직대로 registeration/request/user 호출
            await _registerWithInviteKey(context, values, role, storage);
          } else if (role == Role.PARENT) {
            // 학부모일 경우 새로운 API 호출 (추후 개발 예정)
            // 아래 부분은 추후 학부모 회원가입 API가 개발되면 대체
            print("학부모 회원가입 - 새로운 API 호출 필요");

          }
        }
      }
    }
  }


  static Future<void> _registerWithInviteKey(
      BuildContext context,
      List<String> values,
      Role role,
      FlutterSecureStorage storage,
      ) async {
    var loginResponse = await dio.post('/user/login', data: {
      "user_id": values[1],
      "password": values[2]
    });

    String token = loginResponse.data['accessToken'];
    await storage.write(key: 'accessToken', value: token);
    await storage.write(key: 'refreshToken', value: loginResponse.headers['set-cookie'][0]);
    await storage.write(key: 'id', value: values[1]);

    dio.addResponseInterceptor('Authorization', 'Bearer $token');

    var response = await dio.post('/registeration/request/user', data: {
      "user_id": values[1],
      "academy_key": values[6],
      "role": role == Role.STUDENT ? "STUDENT" : "PARENT"
    });

    if (response.statusCode == 201) {
      Fluttertoast.showToast(
        msg: "회원가입 및 학원 등록 요청이 완료되었습니다.",
        backgroundColor: Colors.grey,
        fontSize: 18.sp,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => AfterSignUp(
            name: values[0],
            role: role == Role.STUDENT ? 1 : 0,
            isKey: true,
          ),
        ),
            (route) => false,
      );
    }
  }
}
