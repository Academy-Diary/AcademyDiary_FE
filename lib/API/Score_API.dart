import 'package:academy_manager/Dio/MyDio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class ScoreApi {
  final dio = MyDio();
  static final storage = FlutterSecureStorage(); // FlutterSecureStorage 사용

  // 토큰 초기화
  Future<void> initTokens() async {
    String? accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null) {
      dio.addResponseInterceptor('Authorization', 'Bearer $accessToken');
      print("Access token added to headers.");
    } else {
      throw Exception('Access token not found.');
    }
  }

  // 사용자 ID를 storage에서 가져옴
  Future<String> getUserId() async {
    String? userId = await storage.read(key: 'user_id');
    if (userId != null) {
      print("Fetched user_id: $userId");
      return userId;
    } else {
      throw Exception('User ID not found in storage.');
    }
  }

  // 학원 ID를 storage에서 가져옴
  Future<String> getAcademyId() async {
    String? academyId = await storage.read(key: 'academy_id');
    if (academyId != null) {
      print("Fetched academy_id: $academyId");
      return academyId;
    } else {
      throw Exception('Academy ID not found in storage.');
    }
  }

  // 시험 유형 조회 API 호출
  Future<List<Map<String, dynamic>>> fetchExamTypes(String academyId) async {
    try {
      print("Fetching exam types for academyId: $academyId");
      var response = await dio.get('/exam-type/academy/$academyId');
      print("Response: ${response.data}");

      List<Map<String, dynamic>> examTypes =
      List<Map<String, dynamic>>.from(response.data['data']['exam_types']);
      return examTypes;
    } catch (e) {
      print("Error fetching exam types: $e");
      throw Exception('Error while fetching exam types: $e');
    }
  }

  // 성적 조회 API 호출
  Future<List<Map<String, dynamic>>> fetchScores({
    required String userId,
    required int lectureId,
    required String examTypeId,
    required bool asc,
  }) async {
    try {
      print("Fetching scores with the following parameters:");
      print("User ID: $userId");
      print("Lecture ID: $lectureId");
      print("Exam Type ID: $examTypeId");
      print("Ascending Order: $asc");

      var response = await dio.get(
        '/lecture/$lectureId/score?user_id=$userId&exam_type_id=$examTypeId&asc=$asc',
      );

      final data = response.data['data'];

      if (data.containsKey('exam_data') && data['exam_data'] != null) {
        final examData = data['exam_data'];
        final examTypeId = examData['exam_type']['exam_type_id'];
        final examTypeName = examData['exam_type']['exam_type_name'];
        final examList = List<Map<String, dynamic>>.from(examData['exam_list']);

        print('Fetched exam_type_id: $examTypeId');
        print('Fetched exam_type_name: $examTypeName');
        print('Fetched exam_list: $examList');

        final scores = examList.map((score) {
          return {
            ...score,
            'exam_type_id': examTypeId.toString(),
            'exam_type_name': examTypeName,
          };
        }).toList();

        return scores;
      } else {
        print("No exam data found.");
        return [];
      }
    } catch (e) {
      print("Error fetching scores: $e");
      throw Exception('Error while fetching scores: $e');
    }
  }
}
