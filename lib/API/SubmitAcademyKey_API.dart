import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:academy_manager/Dio/MyDio.dart';

class SubmitAcademyKeyApi {
  final dio = MyDio();
  static final storage = FlutterSecureStorage();

  Future<void> initToken() async {
    String? accessToken = await storage.read(key: 'accessToken');
    dio.addResponseInterceptor('Authorization', 'Bearer $accessToken');
  }

  Future<dynamic> submitAcademyKey(String userId, String academyKey) async {
    return await dio.post('/registeration/request/user', data: {
      'user_id': userId,
      'academy_key': academyKey,
      'role': 'STUDENT'
    });
  }
}
