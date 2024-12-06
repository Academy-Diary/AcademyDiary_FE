import 'package:academy_manager/Dio/MyDio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyPageApi {
  final MyDio dio = MyDio();
  static final storage = FlutterSecureStorage();

  Future<void> initTokens() async {
    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null) {
      dio.addResponseInterceptor('Authorization', 'Bearer $accessToken');
    }
  }

  Future<Map<String, dynamic>> fetchUserInfo(String userId) async {
    try {
      final response = await dio.get('/user/$userId/basic-info');
      return response.data;
    } catch (e) {
      print("Error fetching user info: $e");
      rethrow;
    }
  }

  Future<String?> downloadUserProfileImage(String userId) async {
    try {
      // 로그 추가
      print("Requesting profile image for userId: $userId");

      // API 호출
      final response = await dio.get('/user/$userId/image-info');

      // 성공적인 응답 처리
      if (response.statusCode == 200 && response.data['data']['image'] != null) {
        String imageUrl = response.data['data']['image'];
        print("Profile image URL: $imageUrl");
        return imageUrl;
      }

      // 404 에러 처리
      if (response.statusCode == 404) {
        print("Profile image not found for userId: $userId");
        return null; // 기본 이미지를 표시하도록 설정
      }

      // 기타 상태 코드 처리
      throw Exception("Unexpected error: ${response.statusCode}");
    } catch (e) {
      print("Error downloading profile image: $e");
      return null;
    }
  }


}
