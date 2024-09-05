import 'package:academy_manager/AfterSignup.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:email_validator/email_validator.dart'; // 이메일 형식 확인
import 'package:flutter_screenutil/flutter_screenutil.dart'; // 화면 사이즈 유틸
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late ScrollController _scrollControl = ScrollController(); // Scroll위젯을 컨트롤

  // 각 필드에서 값을 가져오기 위한 컨트롤러 화면에 나타나있는 순서대로 리스트 저장
  // 0->이름필드, 1-> id필드 등등.. 비밀번호 확인 필드는 제외
  List<TextEditingController> controllers = [];

  //form의 globalKey
  final _formKey = GlobalKey<FormState>();

  // 엔터키를 누르면 필드로 커서가 자동으로 옮겨갈 수 있도록 FocusNode 구정
  final _idFocusNode = FocusNode();
  final _pw1FocusNode = FocusNode();
  final _pw2FocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _birthFocusNode = FocusNode();
  final _keyFocusNode = FocusNode();

  // 생년월일의 초기 값 : 현재
  DateTime initialDate = DateTime.now();

  // securestorage
  static final storage = new FlutterSecureStorage();

  Map<String, String> info = Map();
  bool idck = false; // id 중복검사 여부 체크

  // http 통신을 위한 dio
  var dio;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 7개의 컨드롤러를 controllers 리스트에 저장
    for(int i = 0; i<7; i++)
      controllers.add(TextEditingController());


    dio = new Dio();
    dio.options.baseUrl =
    'http://192.168.199.185:8000';
    dio.options.connectTimeout = 5000; // 5s
    dio.options.receiveTimeout = 3000;
    dio.options.headers =
    {'Content-Type': 'application/json'};
    dio.interceptors.add(
        InterceptorsWrapper(
            onError: (DioError error, ErrorInterceptorHandler handler){
              Fluttertoast.showToast(msg: error.response?.data["message"]);
              return handler.next(error);
            }
        )
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollControl.dispose();
    _idFocusNode.dispose();
    _pw1FocusNode.dispose();
    _pw2FocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _birthFocusNode.dispose();
    _keyFocusNode.dispose();

  }

  static const mainColor = Color(0xff565D6D);
  static const backColor = Color(0xffD9D9D9);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backColor,
        body:SafeArea(
          child: Scrollbar(
            controller: _scrollControl,
            child: Center(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  controller: _scrollControl,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 10.h),
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 40.sp,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 342.w,
                        height: 51.h,
                        child: TextFormField(
                          autofocus: true,
                          controller: controllers[0],
                          validator: (value){
                            if(value!.isEmpty){
                              return "이름을 입력하세요";
                            }else return null;
                          },
                          decoration: const InputDecoration(
                            hintText: "이름",
                          ),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_){
                            FocusScope.of(context).requestFocus(_idFocusNode);
                          },
                          onSaved: (value){
                            info["name"] = value!;
                          },
                        ),
                      ), //이름 입력
                      midSize.verticalSpace,
                      SizedBox(
                        width: 350.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 230.w,
                              height: 51.h,
                              child: TextFormField(
                                controller: controllers[1],
                                validator: (value){
                                  if(value!.isEmpty){
                                    return "아이디를 입력하세요";
                                  }else return null;
                                },
                                decoration: const InputDecoration(
                                  hintText: "ID",
                                ),
                                focusNode: _idFocusNode,
                                onFieldSubmitted: (_){
                                  FocusScope.of(context).requestFocus(_pw1FocusNode);
                                },

                              ),
                            ),
                            10.horizontalSpace,
                            SizedBox(
                              width: 106.w,
                              height: 51.h,
                              child: ElevatedButton(
                                onPressed: (){
                                  if(controllers[1].text == ''){
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text(
                                        "아이디 값을 입력하세요",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      duration: Duration(seconds: 1),
                                    ));
                                  }else{
                                    setState(() {
                                      idck = true;
                                    });
                                    //비어 있지 않을 때
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text(
                                        "검사중입니다",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      duration: Duration(seconds: 1),
                                    ));
                                  }
                                },
                                child: Text(
                                  "중복확인",
                                  style: TextStyle(
                                    fontSize: 18.spMin,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: mainColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),//아이디 입력 및 중복확인
                      SizedBox(
                        width: 342.w,
                        child: Padding(
                          padding: EdgeInsets.only(top:32.h),
                          child: TextFormField(
                            controller: controllers[2],
                            validator: (value){
                              if(value!.isEmpty){
                                return "비밀번호를 입력하세요";
                              }else return null;
                            },
                            decoration: const InputDecoration(
                              hintText: "비밀번호",
                            ),
                            focusNode: _pw1FocusNode,
                            onFieldSubmitted: (_){
                              FocusScope.of(context).requestFocus(_pw2FocusNode);
                            },
                            obscureText: true,
                            keyboardType: TextInputType.visiblePassword,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 342.w,
                        child: Padding(
                          padding: EdgeInsets.only(top:32.h),
                          child: TextFormField(
                            validator: (value){
                              if(value!.isEmpty){
                                return "비밀번호를 입력하세요";
                              }else if(value.toString() != controllers[2].text){
                                return "두 비밀번호가 다릅니다.";
                              }else return null;
                            },
                            decoration: const InputDecoration(
                              hintText: "비밀번호 확인",
                            ),
                            focusNode: _pw2FocusNode,
                            onFieldSubmitted: (_){
                              FocusScope.of(context).requestFocus(_emailFocusNode);
                            },
                            obscureText: true,
                            keyboardType: TextInputType.visiblePassword,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 342.w,
                        child: Padding(
                          padding: EdgeInsets.only(top:midSize),
                          child: TextFormField(
                            controller: controllers[3],
                            validator: (value){
                              if(value!.isEmpty){
                                return "email을 입력하세요";
                              }else if(!EmailValidator.validate(value!)){
                                return "올바른 형식의 email을 입력하세요";
                              }else return null;
                            },
                            decoration: const InputDecoration(
                              hintText: "Email",
                            ),
                            focusNode: _emailFocusNode,
                            onFieldSubmitted: (_){
                              FocusScope.of(context).requestFocus(_phoneFocusNode);
                            },
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 342.w,
                        child: Padding(
                          padding: EdgeInsets.only(top:midSize),
                          child: TextFormField(
                            controller: controllers[4],
                            validator: (value){
                              if(value!.isEmpty){
                                return "전화번호를 입력하세요";
                              }else return null;
                            },
                            decoration: const InputDecoration(
                              hintText: "전화번호",
                            ),
                            focusNode: _phoneFocusNode,
                            onFieldSubmitted: (_){
                              FocusScope.of(context).requestFocus(_birthFocusNode);
                            },
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ),
                      SizedBox( // 생년월일 입력
                        width: 342.w,
                        child: Padding(
                          padding: EdgeInsets.only(top:midSize),
                          child: TextFormField(
                            autocorrect: true,
                            controller: controllers[5],
                            readOnly: true,
                            validator: (value){
                              if(value!.isEmpty){
                                return "생년월일을 입력하세요";
                              }else return null;
                            },
                            decoration: const InputDecoration(
                              hintText: "생년월일",
                            ),
                            focusNode: _birthFocusNode,
                            onTap: () async{
                              final DateTime? dateTime = await showDatePicker(
                                context: context,
                                initialDate: initialDate,
                                firstDate: DateTime(1000),
                                lastDate: DateTime(3000),
                              );
                              if(dateTime != null) {
                                setState(() {
                                  initialDate = dateTime;
                                });
                                controllers[5].text = dateTime.toString().split(' ')[0];
                              }else{
                                controllers[5].text = "";
                              }

                            },
                            onFieldSubmitted: (_){
                              FocusScope.of(context).requestFocus(_keyFocusNode);
                            },
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 342.w,
                        child: Padding(
                          padding: EdgeInsets.only(top:midSize),
                          child: TextFormField(
                            controller: controllers[6],
                            decoration: const InputDecoration(
                              hintText: "학원초대키",
                            ),
                            focusNode: _keyFocusNode,
                            onFieldSubmitted: (_){

                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 342.w,
                        child: Padding(
                          padding: EdgeInsets.only(top:midSize),
                          child: ElevatedButton(
                            onPressed: () async{
                              // 회원가입 버튼 눌렀을 때
                              if(!idck){
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                    "아이디 중복확인을 누르세요",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  duration: Duration(seconds: 1),
                                ));
                                FocusScope.of(context).requestFocus(_idFocusNode);
                              }
                              if(_formKey.currentState!.validate()) {
                                List<String> values = [];

                                // 각 필드의 값을 string 타입으로 list에 저장.
                                for (TextEditingController v in controllers) {
                                  values.add(v.text);
                                }
                                int year = int.parse(values[5].split("-")[0]);
                                int month = int.parse(values[5].split("-")[1]);
                                int day = int.parse(values[5].split("-")[2]);

                                var response = await dio.post('/user/signup',
                                    data: {
                                      "user_id": values[1],
                                      "email": values[3],
                                      "user_name": values[0],
                                      "password": values[2],
                                      "phone_number": values[4],
                                      "birth_date": values[5] + "T00:00:00Z",
                                      "role": "STUDENT",
                                      "academy_id": ""
                                    });
                                if (response.statusCode == 201) {
                                  // 회원가입 성공
                                  // TODO: 로그인 기능 추가
                                  if(values[6].isEmpty){
                                    //이전까지 탐색한 모든 페이지 지우고 다음 페이지로 이동
                                    Navigator.pushAndRemoveUntil(context,
                                        MaterialPageRoute(
                                            builder: (context)=>AfterSignUp(
                                                name: values[0],
                                                role: 1, // 학생이면 1 학부모이면 0
                                                isKey: false
                                            )
                                        ),
                                            (route)=>false
                                    );
                                  }else{
                                    // 회원가입 후 자동으로 등록신청
                                    // TODO: 초대키 등록 api 사용.

                                    // 신청완료 후 화면 넘어감. 이전에 탐색한 모든 화면은 지움
                                    Navigator.pushAndRemoveUntil(context,
                                        MaterialPageRoute(
                                            builder: (context)=>AfterSignUp(
                                                name: values[0],
                                                role: 1, // 학생이면 1 학부모이면 0
                                                isKey: true
                                            )
                                        ),
                                            (route)=>false
                                    );
                                  }
                                }
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "회원가입",
                                style: TextStyle(
                                  fontSize: 24.sp,
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mainColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
    );
  }



  static const double midSize = 25;
}
