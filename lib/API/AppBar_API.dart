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
    return {
      'user_name': await storage.read(key: 'user_name'),
      'email': await storage.read(key: 'email'),
    };
  }

  // 토큰 가져오기
  Future<String?> getAccessToken() async {
    return await storage.read(key: 'accessToken');
  }

  Future<String?> getRefreshToken() async {
    return await storage.read(key: 'refreshToken');
  }

  // userId 가져오기
  Future<String?> getUserId() async {
    final userId = await storage.read(key: 'user_id'); // Key 수정
    if (userId == null || userId.isEmpty) {
      throw Exception("user_id가 저장되어 있지 않습니다.");
    }
    return userId;
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
      final subjects = data.map((lecture) => {
        'lecture_id': lecture['lecture_id'],
        'lecture_name': lecture['lecture_name'],
      }).toList();

      await storage.write(key: 'storedSubjects', value: jsonEncode(subjects)); // 저장
      return subjects;
    } catch (err) {
      if (err is DioError) {
        print('DioError 발생: ${err.message}');
        print('서버 응답: ${err.response?.data ?? "응답 데이터가 없습니다."}');
      }
      throw Exception("Failed to load subjects: $err");
    }
  }

  // 저장된 과목 목록 가져오기
  Future<List<Map<String, dynamic>>> getStoredSubjects() async {
    final storedSubjects = await storage.read(key: 'storedSubjects');
    if (storedSubjects != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(storedSubjects));
    }
    return [];
  }

  // API와 저장소 통합 호출
  Future<List<Map<String, dynamic>>> fetchAndStoreSubjects() async {
    try {
      // Access Token 가져오기
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();

      if (accessToken == null || refreshToken == null) {
        throw Exception("Access Token 또는 Refresh Token이 유효하지 않습니다.");
      }

      // Token 설정
      await addTokenInterceptors(accessToken, refreshToken);

      // userId 가져오기
      final userId = await getUserId();
      if (userId == null) {
        throw Exception("userId가 유효하지 않습니다.");
      }

      // 과목 API 호출
      final subjects = await fetchSubjects(userId);
      return subjects;
    } catch (err) {
      print("Error fetching and storing subjects: $err");
      return [];
    }
  }



}
