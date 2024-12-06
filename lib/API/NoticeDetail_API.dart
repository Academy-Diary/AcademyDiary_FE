import 'package:academy_manager/Dio/MyDio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NoticeDetailApi {
  final dio = MyDio();
  static final storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> fetchNoticeDetail(String noticeId) async {
    try {
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null) {
        throw Exception('AccessToken이 없습니다.');
      }
      dio.addResponseInterceptor('Authorization', 'Bearer $accessToken');

      final response = await dio.get('/notice/$noticeId');
      return response.data;
    } catch (e) {
      throw Exception('공지사항 상세 조회 중 오류 발생: $e');
    }
  }
}
