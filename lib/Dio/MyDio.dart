import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyDio{
  var dio = new Dio();
  var response;
  MyDio() {
    // 기본 정보
    dio.options.baseUrl =
    'http://192.168.199.188:8000'; //개발 중 주소는 내 아이피 localhost는 x
    dio.options.connectTimeout = 5000; // 5s
    dio.options.receiveTimeout = 3000;
    dio.options.headers =
    {'Content-Type': 'application/json'};
  }

  //post 요청
  dynamic post(String path, {data})async{
    response = await dio.post(path, data:data);
    return response;
  }
  // get요청
  dynamic get(String path) async{
    response = await dio.get(path.toString());
    return response;
  }
  //delete 요청
  dynamic delete(String path) async{
    response = await dio.delete(path);
    return response;
  }
  // put 요청
  dynamic put(String path, {data}) async{
    response = await dio.put(path, data: data);
    return response;
  }

  // download 요청
  dynamic download(String path, String savePath) async{
    response = await dio.download(path, savePath);
    return response;
  }

  // 에러 인터셉터 추가 코드
  void addErrorInterceptor(BuildContext context){
    dio.interceptors.add(InterceptorsWrapper(
      onError: (DioError error, ErrorInterceptorHandler handler){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                error.response!.data['message'], //에러코드 : 에러메세지
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.redAccent,
          )
        );
        return handler.next(error);
      }
    ));
  }

  void addResponseInterceptor(String headerKey, String headerValue){
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler){
            options.headers[headerKey] = headerValue;
            return handler.next(options);
          }
        )
      );
  }



}