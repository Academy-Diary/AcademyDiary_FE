import 'package:academy_manager/Dio/MyDio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BillApi{
  static final dio = MyDio();
  static final storage = FlutterSecureStorage();

  Future<String?> getName() async{
    return await storage.read(key: 'user_name');
  }
}