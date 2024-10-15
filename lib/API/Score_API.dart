import 'package:academy_manager/Dio/MyDio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class ScoreApi {
  final dio = MyDio();
  static final storage = FlutterSecureStorage();  // FlutterSecureStorage 사용

  Future<void> initTokens() async {
    String? accessToken = await storage.read(key: 'accessToken');  // storage 사용
    if (accessToken != null) {
      dio.addResponseInterceptor('Authorization', 'Bearer $accessToken');
    } else {
      throw Exception('토큰을 찾을 수 없습니다.');
    }
  }

  // 사용자 ID를 storage에서 가져옴
  Future<String> getUserId() async {
    return await storage.read(key: 'id') ?? "";
  }

  // 학원 ID를 storage에서 가져옴 (수정된 부분)
  Future<String> getAcademyId() async {
    String? academyId = await storage.read(key: 'academy_id');
    print('academy_id: $academyId');  // 여기서 academy_id를 확인
    return academyId ?? "";
  }


  // 시험 유형 조회 API 호출 (academy_id 추가)
  Future<List<Map<String, dynamic>>> fetchExamTypes(String academyId) async {
    try {
      var response = await dio.get('/exam-type/academy/$academyId');
      List<Map<String, dynamic>> examTypes = List<Map<String, dynamic>>.from(response.data['data']['exam_types']);
      return examTypes;
    } catch (e) {
      throw Exception('시험 유형을 가져오는 중 오류 발생: $e');
    }
  }

  // 성적 조회 API 호출
  Future<List<Map<String, dynamic>>> fetchScores({
    required String userId,
    required int lectureId,
    required String examTypeId,  // examType -> examTypeId로 수정
    required bool asc,
  }) async {
    try {
      // exam_type을 exam_type_id로 수정
      var response = await dio.get(
        '/lecture/$lectureId/score?user_id=$userId&exam_type_id=$examTypeId&asc=$asc',
      );
      List<Map<String, dynamic>> scores = List<Map<String, dynamic>>.from(response.data['data']['exam_data']['exam_list']);
      return scores;
    } catch (e) {
      throw Exception('성적을 가져오는 중 오류 발생: $e');
    }
  }
}
