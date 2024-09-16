import 'package:academy_manager/AfterSignup.dart';
import 'package:academy_manager/MyDio.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart'; // 이메일 형식 확인
import 'package:flutter_screenutil/flutter_screenutil.dart'; // 화면 사이즈 유틸
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum Role {STUDENT, PARENT}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late ScrollController _scrollControl = ScrollController(); // Scroll위젯을 컨트롤

  // 각 필드에서 값을 가져오기 위한 컨트롤러 화면에 나타나있는 순서대로 리스트 저장
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
  static final storage = FlutterSecureStorage();

  Map<String, String> info = Map();
  bool idck = false; // id 중복검사 여부 체크

  // http 통신을 위한 dio
  var dio;

  // 학생/학부모 구분
  Role role = Role.STUDENT;

  // 학원 초대키 hint text
  String? hintText = '학원초대키';

  @override
  void initState() {
    super.initState();
    // 7개의 컨트롤러를 controllers 리스트에 저장
    for (int i = 0; i < 7; i++) controllers.add(TextEditingController());

    dio = new MyDio();

  }


  @override
  void dispose() {
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
    dio.addErrorInterceptor(context);
    return Scaffold(
      backgroundColor: backColor,
      body: SafeArea(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 130.w,
                          height: 51.h,
                          child: RadioListTile(
                            title: const Text("학생"),
                              value: Role.STUDENT,
                              groupValue: role,
                              onChanged: (value){
                                setState(() {
                                  role = Role.STUDENT;
                                  hintText = "학원초대키";
                                });
                              }),
                        ),
                        SizedBox(
                          width: 140.w,
                          height: 51.h,
                          child: RadioListTile(
                              title: const Text("학부모"),
                              value: Role.PARENT,
                              groupValue: role,
                              onChanged: (value){
                                setState(() {
                                  role = Role.PARENT;
                                  hintText = "학생아이디";
                                });
                              }),
                        )
                      ],
                    ),
                    SizedBox(
                      width: 342.w,
                      height: 51.h,
                      child: TextFormField(
                        autofocus: true,
                        controller: controllers[0],
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "이름을 입력하세요";
                          } else {
                            return null;
                          }
                        },
                        decoration: const InputDecoration(
                          hintText: "이름",
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_idFocusNode);
                        },
                        onSaved: (value) {
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
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "아이디를 입력하세요";
                                } else {
                                  return null;
                                }
                              },
                              decoration: const InputDecoration(
                                hintText: "ID",
                              ),
                              focusNode: _idFocusNode,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(_pw1FocusNode);
                              },
                            ),
                          ),
                          10.horizontalSpace,
                          SizedBox(
                            width: 106.w,
                            height: 51.h,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (controllers[1].text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "아이디 값을 입력하세요",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                } else {
                                  try {
                                    // ID 중복 체크 API 호출
                                    var response = await dio.get('/user/check-id/${controllers[1].text}');

                                    if (response.statusCode == 200) {
                                      // 응답 데이터 확인
                                      var responseData = response.data;
                                      print("Response Data: $responseData"); // 응답 데이터 로그 출력

                                      // ID 중복 여부 확인
                                      if (responseData['message'] == '사용 가능한 아이디입니다.') {
                                        setState(() {
                                          idck = true;
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "사용 가능한 아이디입니다.",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      } else {
                                        // 중복된 아이디인 경우
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "중복된 아이디입니다.",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      }
                                    } else {
                                      // 상태 코드가 200이 아닐 경우
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "아이디 중복 확인 중 오류가 발생했습니다.",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    // API 호출 시 발생하는 예외 처리
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "중복된 아이디입니다.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  }
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
                        padding: EdgeInsets.only(top: 32.h),
                        child: TextFormField(
                          controller: controllers[2],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "비밀번호를 입력하세요";
                            } else {
                              return null;
                            }
                          },
                          decoration: const InputDecoration(
                            hintText: "비밀번호",
                          ),
                          focusNode: _pw1FocusNode,
                          onFieldSubmitted: (_) {
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
                        padding: EdgeInsets.only(top: 32.h),
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "비밀번호를 입력하세요";
                            } else if (value.toString() != controllers[2].text) {
                              return "두 비밀번호가 다릅니다.";
                            } else {
                              return null;
                            }
                          },
                          decoration: const InputDecoration(
                            hintText: "비밀번호 확인",
                          ),
                          focusNode: _pw2FocusNode,
                          onFieldSubmitted: (_) {
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
                        padding: EdgeInsets.only(top: midSize),
                        child: TextFormField(
                          controller: controllers[3],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "email을 입력하세요";
                            } else if (!EmailValidator.validate(value!)) {
                              return "올바른 형식의 email을 입력하세요";
                            } else {
                              return null;
                            }
                          },
                          decoration: const InputDecoration(
                            hintText: "Email",
                          ),
                          focusNode: _emailFocusNode,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_phoneFocusNode);
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 342.w,
                      child: Padding(
                        padding: EdgeInsets.only(top: midSize),
                        child: TextFormField(
                          controller: controllers[4],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "전화번호를 입력하세요";
                            }else if(!RegExp(r'^010-?([0-9]{4})-?([0-9]{4})$').hasMatch(value.toString())){
                              // 전화번호 형식이 알맞게 입력됐는지 확인
                              return "올바른 형식의 휴대폰번호를 입력하세요";
                            }else return null;;
                          },
                          decoration: const InputDecoration(
                            hintText: "전화번호",
                          ),
                          focusNode: _phoneFocusNode,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_birthFocusNode);
                          },
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ),
                    SizedBox( // 생년월일 입력
                      width: 342.w,
                      child: Padding(
                        padding: EdgeInsets.only(top: midSize),
                        child: TextFormField(
                          autocorrect: true,
                          controller: controllers[5],
                          readOnly: true,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "생년월일을 입력하세요";
                            } else {
                              return null;
                            }
                          },
                          decoration: const InputDecoration(
                            hintText: "생년월일",
                          ),
                          focusNode: _birthFocusNode,
                          onTap: () async {
                            final DateTime? dateTime = await showDatePicker(
                              context: context,
                              initialDate: initialDate,
                              firstDate: DateTime(1000),
                              lastDate: DateTime(3000),
                            );
                            if (dateTime != null) {
                              setState(() {
                                initialDate = dateTime;
                              });
                              controllers[5].text = dateTime.toString().split(' ')[0];
                            } else {
                              controllers[5].text = "";
                            }
                          },
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_keyFocusNode);
                          },
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 342.w,
                      child: Padding(
                        padding: EdgeInsets.only(top: midSize),
                        child: TextFormField(
                          validator: (value){
                            if(role == Role.PARENT && value!.isEmpty){
                              return "학생 아이디를 입력하세요";
                            }else{
                              return null;
                            }
                          },
                          controller: controllers[6],
                          decoration: InputDecoration(
                            hintText: hintText,
                          ),
                          focusNode: _keyFocusNode,
                          onFieldSubmitted: (_) {},
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 342.w,
                      child: Padding(
                        padding: EdgeInsets.only(top: midSize),
                        child: ElevatedButton(
                          onPressed: () async {
                            // 회원가입 버튼 눌렀을 때
                            if (!idck) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "아이디 중복확인을 누르세요",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              FocusScope.of(context).requestFocus(_idFocusNode);
                            }
                            if (_formKey.currentState!.validate()) {
                              List<String> values = [];

                              // 각 필드의 값을 string 타입으로 list에 저장.
                              for (TextEditingController v in controllers) {
                                values.add(v.text);
                              }

                              var response = await dio.post('/user/signup',
                                  data: {
                                    "user_id": values[1],
                                    "email": values[3],
                                    "user_name": values[0],
                                    "password": values[2],
                                    "phone_number": values[4],
                                    "birth_date": values[5] + "T00:00:00Z",
                                    "role" : (role == Role.STUDENT)? "STUDENT" : "PARENT"
                                  });
                              if (response.statusCode == 201) {
                                // 회원가입 성공
                                if (values[6].isEmpty) {
                                  // 이전까지 탐색한 모든 페이지 지우고 다음 페이지로 이동
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AfterSignUp(
                                        name: values[0],
                                        role: 1, // 학생이면 1 학부모이면 0
                                        isKey: false,
                                      ),
                                    ),
                                        (route) => false,
                                  );
                                } else {
                                  // 회원가입 후 자동으로 등록신청
                                  // 회원가입 시 받은 아이디, 비밀번호로 로그인 후 토큰 값을 받아 진행.
                                  // 로그인
                                  var response = await dio.post('/user/login', data:{
                                    "user_id": values[1],
                                    "password": values[2]
                                  });
                                  String token = response.data['accessToken'];
                                  storage.delete(key: 'accessToken');
                                  storage.write(key: 'accessToken', value: response.data['accessToken']);
                                  storage.delete(key: 'refreshToken');
                                  storage.write(key: "refreshToken", value: response.headers['set-cookie'][0]);
                                  storage.delete(key: 'id');
                                  storage.write(key: 'id', value: values[1]);
                                  // 초대키 등록 api 사용.
                                  dio.addResponseInterceptor('Authorization', 'Bear '+token);
                                  response = await dio.post('/registeration/request/user', data: {
                                    "user_id" : values[1],
                                    "academy_key" : values[6],
                                    "role" : (role == Role.STUDENT)? "STUDENT" : "PARENT"
                                  });
                                  if(response.statusCode == 201){
                                    Fluttertoast.showToast(
                                        msg: "회원가입 및 학원 등록 요청이 \n완료되었습니다.",
                                      backgroundColor: Colors.grey,
                                      fontSize: 18.sp
                                    );
                                    // 신청완료 후 화면 넘어감. 이전에 탐색한 모든 화면은 지움
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AfterSignUp(
                                          name: values[0],
                                          role: 1, // 학생이면 1 학부모이면 0
                                          isKey: true,
                                        ),
                                      ),
                                          (route) => false,
                                    );
                                  }
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
      ),
    );
  }

  static const double midSize = 25;
}
