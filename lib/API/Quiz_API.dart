import 'package:academy_manager/Dio/MyDio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class QuizAPI {
  final MyDio dio = MyDio(); // MyDio 인스턴스 사용
  static final storage = FlutterSecureStorage();

  // 퀴즈 목록 조회 (exam_type_id 기본값: 3)
  Future<List<Map<String, dynamic>>> fetchQuizList({
    required int lectureId,
    int examTypeId = 3, // 기본값으로 3 설정
  }) async {
    try {
      // 요청 전 토큰 설정
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken != null) {
        dio.addResponseInterceptor('Authorization', 'Bearer $accessToken');
      }

      // 퀴즈 목록 조회 API 호출
      final response = await dio.get('/lecture/$lectureId/exam?exam_type_id=$examTypeId');
      if (response.statusCode == 200) {
        // 성공적으로 데이터를 반환받은 경우
        return List<Map<String, dynamic>>.from(response.data['data']['exams']);
      } else {
        throw Exception('퀴즈 목록을 가져오는 중 오류 발생: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioError && e.response?.statusCode == 404) {
        print("404 Error: ${e.response?.data['message']}");
        throw Exception(e.response?.data['message'] ?? "퀴즈 목록을 가져오는 중 오류 발생");
      }
      throw Exception('퀴즈 목록을 가져오는 중 오류 발생: $e');
    }
  }

  // 특정 문제 조회
  Future<Map<String, dynamic>> fetchQuestion(int examId, int quizNum) async {
    try {
      // 요청 전 토큰 설정
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken != null) {
        dio.addResponseInterceptor('Authorization', 'Bearer $accessToken');
      }

      // 특정 문제 조회 API 호출
      print("Fetching question for examId: $examId, quizNum: $quizNum");
      final response = await dio.get('/quiz/$examId/$quizNum');
      print("API Response: ${response.data}");

      if (response.statusCode == 200) {
        final key = quizNum.toString(); // 숫자형 문자열 키
        if (!response.data.containsKey(key)) {
          throw Exception("API 응답에 문제 데이터가 없습니다. 키: $key");
        }
        return Map<String, dynamic>.from(response.data[key]);
      } else {
        throw Exception('문제를 가져오는 중 오류 발생: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioError && e.response?.statusCode == 404) {
        print("404 Error: ${e.response?.data['message']}");
        throw Exception(e.response?.data['message'] ?? "문제가 존재하지 않습니다.");
      }
      throw Exception('문제를 가져오는 중 오류 발생: $e');
    }
  }

  // 수강 중인 과목 조회
  Future<List<Map<String, dynamic>>> fetchSubjects() async {
    try {
      // 저장된 user_id 가져오기
      final userId = await storage.read(key: 'user_id');
      if (userId == null) {
        throw Exception("User ID not found in storage.");
      }

      // 저장된 accessToken 가져오기
      final accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null) {
        throw Exception("Access Token not found in storage.");
      }

      // 요청 전에 Authorization 헤더 설정
      dio.addResponseInterceptor('Authorization', 'Bearer $accessToken');

      print("Fetching subjects for user_id: $userId");
      final response = await dio.get('/student/$userId/lecture');

      if (response.statusCode == 200) {
        print("Fetched subjects from API: ${response.data}");
        return List<Map<String, dynamic>>.from(response.data['lectures']);
      } else {
        throw Exception("Failed to fetch subjects: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching subjects: $e");
      throw e;
    }
  }

  // 퀴즈 채점 API 호출
  Future<Map<String, dynamic>> submitQuiz({
    required int examId,
    required List<int> markedAnswers,
  }) async {
    try {
      // 요청 전 토큰 설정
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken != null) {
        dio.addResponseInterceptor('Authorization', 'Bearer $accessToken');
      }

      // 채점 API 호출
      final response = await dio.post(
        '/quiz/mark',
        data: {
          "exam_id": examId,
          "marked": markedAnswers,
        },
      );

      if (response.statusCode == 200) {
        return response.data; // 채점 결과 반환
      } else {
        throw Exception('채점 중 오류 발생: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('채점 중 오류 발생: $e');
    }
  }
}
