import 'package:academy_manager/Dio/MyDio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NoticelistApi{
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
}