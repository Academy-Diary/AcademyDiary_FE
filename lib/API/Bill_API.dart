import 'package:academy_manager/Dio/MyDio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BillApi {
  static final dio = MyDio();
  static final storage = FlutterSecureStorage();

  Future<String?> getName() async {
    return await storage.read(key: 'user_name');
  }

  Future<String?> getUserId() async {
    return await storage.read(key: 'user_id');
  }

  Future<List<Map<String, dynamic>>> fetchBills(String userId) async {
    try {
      final response = await dio.get('/bill/$userId');
      List<Map<String, dynamic>> bills = List<Map<String, dynamic>>.from(response.data['responseBillList']);
      return bills;
    } catch (e) {
      throw Exception('청구서 목록을 가져오는 중 오류 발생: $e');
    }
  }
}
