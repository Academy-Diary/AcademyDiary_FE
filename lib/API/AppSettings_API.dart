import 'package:academy_manager/Dio/MyDio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

class AppSettingsApi {
  static final dio = MyDio();
  static final storage = FlutterSecureStorage();

  Future<String?> getId() async {
    return await storage.read(key: 'id');
  }

  Future<String?> getAccessToken() async {
    return await storage.read(key: 'accessToken');
  }

  Future<Map<String, dynamic>> fetchUserInfo(String id, String accessToken) async {
    dio.addResponseInterceptor('Authorization', 'Bearer $accessToken');
    final response = await dio.get('/user/$id/basic-info');
    return response.data;
  }

  Future<void> deleteUser(String id) async {
    dio.addResponseInterceptor('Content-Type', 'application/json');
    await dio.delete('/user/$id');
  }

  // 에러 인터셉터 추가 메서드
  void addErrorInterceptor(BuildContext context) {
    dio.addErrorInterceptor(context);
  }
}
