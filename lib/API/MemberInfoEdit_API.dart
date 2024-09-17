import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:academy_manager/Dio/MyDio.dart';

class MemberInfoApi {
  final dio = MyDio();
  static final storage = FlutterSecureStorage();

  Future<void> initTokens() async {
    String? accessToken = await storage.read(key: 'accessToken');
    dio.addResponseInterceptor('Authorization', 'Bearer $accessToken');
  }

  Future<Response> updateBasicInfo(String id, String password, String email, String phoneNumber) async {
    return await dio.put('/user/$id/basic-info', data: {
      "password": password,
      'email': email,
      'phone_number': phoneNumber,
    });
  }

  Future<Response?> updateProfileImage(String id, XFile image) async {
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        image.path,
        contentType: MediaType('image', image.path.split('/').last.split('.').last),
      ),
    });
    dio.addResponseInterceptor('Content-Type', 'multipart/form-data');
    return await dio.put('/user/$id/image-info', data: formData);
  }
}
