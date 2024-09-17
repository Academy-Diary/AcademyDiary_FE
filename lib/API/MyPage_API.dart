import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:academy_manager/Dio/MyDio.dart';

class MyPageApi {
  final dio = MyDio();
  static final storage = FlutterSecureStorage();  // 정적 변수

  Future<void> initTokens() async {
    String? accessToken = await MyPageApi.storage.read(key: 'accessToken');  // 클래스 이름으로 접근
    String? refreshToken = await MyPageApi.storage.read(key: 'refreshToken');

    // accessToken과 refreshToken에 대해 null 체크
    if (accessToken != null) {
      dio.addResponseInterceptor('Authorization', 'Bearer ' + accessToken);
    }

    if (refreshToken != null) {
      dio.addResponseInterceptor('cookie', refreshToken);
    }
  }

  Future<Map<String, dynamic>> fetchUserInfo(String id) async {
    var response = await dio.get('/user/$id/basic-info');
    return response.data;
  }

  Future<File> downloadUserProfileImage(String id) async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = '${dir.path}/$id${DateTime.now().toString()}';
    await dio.download('/user/$id/image-info', path);
    return File(path);
  }
}
