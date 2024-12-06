import 'package:academy_manager/Dio/MyDio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NoticeListApi {
  static final dio = MyDio();
  static final storage = FlutterSecureStorage();

  // 사용자 ID 가져오기
  Future<String?> getId() async {
    return await storage.read(key: 'user_id');
  }

  // 사용자 AccessToken 가져오기
  Future<String?> getAccessToken() async {
    return await storage.read(key: 'accessToken');
  }

  // 공지사항 목록 가져오기
  Future<Map<String, dynamic>> fetchNotices({
    required int lectureId,
    required int page,
    required int pageSize,
  }) async {
    try {
      // AccessToken 가져오기
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null) {
        throw Exception('AccessToken이 없습니다.');
      }

      // Authorization 헤더 설정
      dio.addResponseInterceptor('Authorization', 'Bearer $accessToken');
      // URL에 직접 쿼리 매개변수를 포함
      String url = '/notice/list?lecture_id=$lectureId&page=$page&page_size=$pageSize';
      final response = await dio.get(url);
      return response.data;
    } catch (e) {
      throw Exception('공지사항 데이터를 가져오는 중 오류 발생: $e');
    }
  }

  // **수업 목록 가져오기 (추가된 메서드)**
  Future<Map<String, dynamic>> fetchLectures() async {
    try {
      // AccessToken 가져오기
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null) {
        throw Exception('AccessToken이 없습니다.');
      }

      // Authorization 헤더 설정
      dio.addResponseInterceptor('Authorization', 'Bearer $accessToken');

      // 수업 목록 API 호출
      final response = await dio.get('/lecture/list'); // 수업 목록 API 경로
      return response.data;
    } catch (e) {
      throw Exception('수업 목록을 가져오는 중 오류 발생: $e');
    }
  }
}
