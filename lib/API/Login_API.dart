import 'package:academy_manager/Dio/MyDio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class LoginApi {
  final dio = MyDio();
  static final storage = FlutterSecureStorage();

  // 로그인 API 호출
  Future<Response> login(String id, String pw) async {
    return await dio.post('/user/login', data: {"user_id": id, "password": pw});
  }

  // ID 체크 API 호출
  Future<Response> checkId(String id) async {
    return await dio.get('/user/check-id/$id');
  }

  // 회원가입 API 호출
  Future<Response> signupUser(Map<String, dynamic> signupData) async {
    return await dio.post('/user/signup', data: signupData);
  }

  // 학원 등록 요청 API 호출
  Future<Response> registerAcademy(String userId, String academyKey, String role) async {
    final accessToken = await storage.read(key: 'accessToken');
    dio.addResponseInterceptor('Authorization', 'Bearer $accessToken');
    return await dio.post('/registeration/request/user', data: {
      'user_id': userId,
      'academy_key': academyKey,
      'role': role
    });
  }

  // 자동 로그인 정보 저장
  Future<void> saveLoginInfo(String id, String pw, bool isAutoLogin) async {
    if (isAutoLogin) {
      await storage.write(key: "login", value: "user_id $id password $pw");
    }
  }

  // 토큰 및 사용자 ID 저장
  Future<void> saveTokens(Response response, String id) async {
    try {
      await storage.delete(key: 'accessToken');
      await storage.write(key: 'accessToken', value: response.data['accessToken']);
      await storage.write(key: 'accessTokenTime', value: DateTime.now().toString());

      final setCookie = response.headers['set-cookie'];
      if (setCookie != null && setCookie.isNotEmpty) {
        await storage.delete(key: 'refreshToken');
        await storage.write(key: 'refreshToken', value: setCookie[0]);
      }

      // user_id 저장
      await storage.delete(key: 'user_id');
      await storage.write(key: 'user_id', value: id);

      // 저장된 user_id 로그 출력
      String? storedId = await storage.read(key: 'user_id');
      print("저장된 user_id: $storedId");
    } catch (e) {
      print("Error saving tokens: $e");
    }
  }

  // 사용자 정보 저장 (이름, 이메일, 전화번호)
  Future<void> saveUserInfo(Map<String, dynamic> data) async {
    await storage.write(key: 'user_name', value: data['user']['user_name']);
    await storage.write(key: 'email', value: data['user']['email']);
    await storage.write(key: 'phone', value: data['user']['phone_number']);

    if (data['user']['academy_id'] != null) {
      await storage.write(key: 'academy_id', value: data['user']['academy_id']);
    }
  }

  // 학원 ID 저장
  Future<void> saveAcademyId(String academyId) async {
    await storage.write(key: 'academy_id', value: academyId);
  }

  // 저장된 사용자 ID 가져오기
  Future<String?> getUserId() async {
    String? userId = await storage.read(key: 'user_id');
    print("저장된 user_id: $userId");
    return userId;
  }

  // 저장된 학원 ID 가져오기
  Future<String?> getAcademyId() async {
    String? academyId = await storage.read(key: 'academy_id');
    print("저장된 academy_id: $academyId");
    return academyId;
  }

  // 저장된 로그인 정보 가져오기
  Future<String?> getUserInfo() async {
    try {
      String? loginInfo = await storage.read(key: "login");
      print("저장된 로그인 정보: $loginInfo");
      return loginInfo;
    } catch (e) {
      print("Error retrieving login info: $e");
      return null;
    }
  }
}
