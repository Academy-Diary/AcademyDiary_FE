import 'dart:convert';
import 'package:academy_manager/Dio/MyDio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart'; // DioError 처리 및 Options 사용

class AppbarApi {
  final _dio = MyDio();
  static final storage = FlutterSecureStorage();

  // 토큰 인터셉터 추가
  Future<void> addTokenInterceptors(String? token, String? refreshToken) async {
    _dio.addResponseInterceptor('Content-Type', 'application/json');

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

  // 로그아웃 처리
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

  // 사용자 정보 가져오기
  Future<Map<String, dynamic>> getInfo() async {
    Map<String, dynamic> ret_value = {};
    ret_value['user_name'] = await storage.read(key: 'user_name');
    ret_value['email'] = await storage.read(key: 'email');
    return ret_value;
  }

  // 토큰 가져오기
  Future<String?> getAccessToken() async {
    return await storage.read(key: 'accessToken');
  }

  Future<String?> getRefreshToken() async {
    return await storage.read(key: 'refreshToken');
  }

  // userId 가져오기 (추가)
  Future<String?> getUserId() async {
    return await storage.read(key: 'id');
  }

  // academyId 가져오기
  Future<String?> getAcademyId() async {
    return await storage.read(key: 'academyId');
  }

  // 수강 중인 과목 조회 API 호출
  Future<List<Map<String, dynamic>>> fetchSubjects(String userId) async {
    try {
      print('과목 불러오기 요청: /student/$userId/lecture');

      final response = await _dio.get('/student/$userId/lecture');
      print('응답: ${response.data}');

      if (response.data == null || response.data['lectures'] == null) {
        throw Exception("서버로부터 유효한 응답을 받지 못했습니다.");
      }

      List<dynamic> data = response.data['lectures'];
      return data.map((lecture) => {
        'lecture_id': lecture['lecture_id'],
        'lecture_name': lecture['lecture_name']
      }).toList();
    } catch (err) {
      if (err is DioError) {
        print('DioError 발생: ${err.message}');
        print('서버 응답: ${err.response?.data ?? "응답 데이터가 없습니다."}');

        if (err.response?.statusCode == 404) {
          throw Exception("수강 중인 강의가 없습니다.");
        } else if (err.response?.statusCode == 400) {
          throw Exception("유효한 user_id가 제공되지 않았습니다.");
        } else {
          throw Exception("Failed to load subjects: ${err.response?.statusCode} - ${err.response?.data}");
        }
      }
      throw Exception("Failed to load subjects: $err");
    }
  }

  // **추가된 메서드: 저장된 과목 목록 가져오기**
  Future<List<Map<String, dynamic>>> getStoredSubjects() async {
    final storedSubjects = await storage.read(key: 'storedSubjects');
    if (storedSubjects != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(storedSubjects));
    }
    return [];
  }

  // **추가된 메서드: 과목 목록 저장하기**
  Future<List<Map<String, dynamic>>> fetchAndStoreSubjects(String userId) async {
    try {
      final subjects = await fetchSubjects(userId); // API 호출
      await storage.write(
        key: 'storedSubjects',
        value: jsonEncode(subjects), // JSON 형식으로 저장
      );
      return subjects;
    } catch (err) {
      throw Exception("Failed to fetch and store subjects: $err");
    }
  }
}
