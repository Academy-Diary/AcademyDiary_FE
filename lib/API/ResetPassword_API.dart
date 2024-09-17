import 'package:dio/dio.dart';
import 'package:academy_manager/Dio/MyDio.dart';

class ResetPasswordApi {
  final dio = MyDio();

  Future<Response> resetPassword(String userId, String email, String phoneNumber) async {
    return await dio.post(
      '/user/reset-password',
      data: {
        'user_id': userId,
        'email': email,
        'phone_number': phoneNumber,
      },
    );
  }
}
