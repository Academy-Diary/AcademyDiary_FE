import 'package:dio/dio.dart';
import 'package:academy_manager/Dio/MyDio.dart';

class SignupApi {
  final dio = MyDio();

  Future<Response> checkId(String userId) async {
    return await dio.get('/user/check-id/$userId');
  }

  Future<Response> signupUser(Map<String, dynamic> data) async {
    return await dio.post('/user/signup', data: data);
  }

  Future<Response> loginUser(String userId, String password) async {
    return await dio.post('/user/login', data: {
      'user_id': userId,
      'password': password,
    });
  }

  Future<Response> registerAcademy(String userId, String academyKey, String role) async {
    return await dio.post('/registeration/request/user', data: {
      'user_id': userId,
      'academy_key': academyKey,
      'role': role,
    });
  }
}
