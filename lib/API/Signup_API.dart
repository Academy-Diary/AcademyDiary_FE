import 'package:academy_manager/UI/AfterSignup_UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:academy_manager/Dio/MyDio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/UI/Signup_UI.dart';

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
          await _registerWithInviteKey(context, values, role, storage);
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
