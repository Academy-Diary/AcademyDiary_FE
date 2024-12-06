import 'package:academy_manager/Dio/MyDio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class BillApi {
  final MyDio dio = MyDio();
  static final storage = FlutterSecureStorage();

  // 사용자 이름 가져오기
  Future<String?> getName() async {
    return await storage.read(key: 'user_name');
  }

  // 사용자 ID 가져오기
  Future<String?> getUserId() async {
    return await storage.read(key: 'user_id');
  }

  // 청구서 목록 조회
  Future<List<Map<String, dynamic>>> fetchBills(String userId) async {
    try {
      // 토큰 읽기
      String? accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null) {
        throw Exception('토큰이 없습니다.');
      }

      // API 호출
      final response = await dio.dio.get(
        '/bill/my/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['responseBillList']);
      } else if (response.statusCode == 401) {
        // 토큰 갱신 및 재시도
        await refreshToken();
        return await fetchBills(userId); // 재귀 호출로 재시도
      } else {
        throw Exception('청구서 조회 중 오류 발생: ${response.statusCode}');
      }
    } catch (e) {
      print("Error: $e");
      throw Exception('청구서 조회 중 오류 발생: $e');
    }
  }

  // 토큰 갱신
  Future<void> refreshToken() async {
    try {
      String? refreshToken = await storage.read(key: 'refreshToken');
      if (refreshToken == null) {
        throw Exception('리프레시 토큰이 없습니다.');
      }

      final response = await dio.dio.post(
        '/user/refresh-token',
        options: Options(
          headers: {
            'Authorization': 'Bearer $refreshToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        await storage.write(key: 'accessToken', value: response.data['accessToken']);
        print('Access Token 갱신 완료');
      } else {
        throw Exception('토큰 갱신 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('토큰 갱신 중 오류 발생: $e');
      throw e;
    }
  }
}
