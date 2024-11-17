import 'package:academy_manager/Dio/MyDio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TeacherApi {
  final MyDio dio = MyDio(); // MyDio 인스턴스 사용
  static final storage = FlutterSecureStorage();

  // 학원 ID로 강사 목록 조회
  Future<List<Map<String, dynamic>>> fetchTeachers(String academyId) async {
    try {
      // 요청 전 토큰 설정
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken != null) {
        dio.addResponseInterceptor('Authorization', 'Bearer $accessToken');
      }

      // 강사 목록 조회 API 호출
      final response = await dio.get('/teacher/$academyId');
      List<dynamic> users = response.data['data']['user'];
      List<Map<String, dynamic>> teachers = [];

      // 각 강사의 정보만 추출하여 리스트에 추가
      for (var user in users) {
        teachers.add({
          'user_name': user['user_name'],
          'email': user['email'],
          'phone_number': user['phone_number'],
          'lectures': user['lectures'] // 강사가 담당하는 강의 목록
        });
      }

      return teachers;
    } catch (e) {
      throw Exception('강사 목록을 가져오는 중 오류 발생: $e');
    }
  }
}
