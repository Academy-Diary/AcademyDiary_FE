import 'package:academy_manager/Dio/MyDio.dart';
import 'package:dio/dio.dart';

class FindIdApi {
  final dio = MyDio();

  Future<String> findId(String email, String phoneNumber) async {
    try {
      Response response = await dio.post(
        '/user/find-id',
        data: {
          'email': email,
          'phone_number': phoneNumber,
        },
      );

      if (response.statusCode == 200) {
        return response.data['user_id'];
      } else {
        throw Exception("Failed to find ID");
      }
    } on DioError catch (error) {
      if (error.response?.statusCode == 400) {
        throw Exception(error.response?.data['message']);
      } else if (error.response?.statusCode == 404) {
        throw Exception("해당하는 유저가 존재하지 않습니다.");
      } else if (error.response?.statusCode == 500) {
        throw Exception("서버에 오류가 발생했습니다. 다시 시도해주세요.");
      } else {
        throw Exception("예상치 못한 오류가 발생했습니다.");
      }
    }
  }
}
