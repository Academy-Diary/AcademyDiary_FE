import 'package:academy_manager/Dio/MyDio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppbarApi {
  final _dio = MyDio();
  static final storage = FlutterSecureStorage();

  Future<void> addTokenInterceptors(String? token, String? refreshToken) async {
    _dio.addResponseInterceptor('Content-Type', 'application/json');

    // token과 refreshToken이 null인지 체크
    if (token != null) {
      _dio.addResponseInterceptor('Authorization', 'Bearer $token');
    } else {
      throw Exception("Access token is null");
    }

    if (refreshToken != null) {
      _dio.addResponseInterceptor('cookie', refreshToken);
    } else {
      throw Exception("Refresh token is null");
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/user/logout');
      await storage.delete(key: "login");
      await storage.delete(key: 'accessToken');
      await storage.delete(key: 'refreshToken');
    } catch (err) {
      throw Exception("Logout failed: $err");
    }
  }


  Future<Map<String, dynamic>> getInfo() async{
    Map<String, dynamic> ret_value = {};
    ret_value['user_name'] = await storage.read(key: 'user_name');
    ret_value['email'] = await storage.read(key: 'email');
    return ret_value;
  }

  Future<String?> getAccessToken() async {
    return await storage.read(key: 'accessToken');
  }

  Future<String?> getRefreshToken() async {
    return await storage.read(key: 'refreshToken');
  }
}