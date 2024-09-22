import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:academy_manager/API/Signup_API.dart';
import 'package:email_validator/email_validator.dart';
import 'package:academy_manager/UI/AfterSignup_UI.dart';

enum Role { STUDENT, PARENT }

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final SignupApi signupApi = SignupApi();
  late ScrollController _scrollControl = ScrollController();
  List<TextEditingController> controllers = [];
  final _formKey = GlobalKey<FormState>();

  final _idFocusNode = FocusNode();
  final _pw1FocusNode = FocusNode();
  final _pw2FocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _birthFocusNode = FocusNode();
  final _keyFocusNode = FocusNode();

  DateTime initialDate = DateTime.now();
  static final storage = FlutterSecureStorage();
  Map<String, String> info = {};
  bool idck = false; // id 중복검사 여부 체크
  Role role = Role.STUDENT;
  String? hintText = '학원초대키';

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 7; i++) controllers.add(TextEditingController());
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

  Future<void> _checkId() async {
    if (controllers[1].text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("아이디 값을 입력하세요", textAlign: TextAlign.center),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    try {
      var response = await signupApi.checkId(controllers[1].text);
      if (response.statusCode == 200) {
        var responseData = response.data;
        if (responseData['message'] == '사용 가능한 아이디입니다.') {
          setState(() {
            idck = true;
          });
          Fluttertoast.showToast(msg: "사용 가능한 아이디입니다.");
        } else {
          Fluttertoast.showToast(msg: "중복된 아이디입니다.");
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "아이디 중복 확인 중 오류가 발생했습니다.");
    }
  }

  Future<void> _signup() async {
    if (!idck) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("아이디 중복확인을 누르세요", textAlign: TextAlign.center),
          duration: Duration(seconds: 1),
        ),
      );
      FocusScope.of(context).requestFocus(_idFocusNode);
      return;
    }

    if (_formKey.currentState!.validate()) {
      List<String> values = controllers.map((c) => c.text).toList();

      try {
        var signupData = {
          "user_id": values[1],
          "email": values[3],
          "user_name": values[0],
          "password": values[2],
          "phone_number": values[4],
          "birth_date": values[5] + "T00:00:00Z",
          "role": (role == Role.STUDENT) ? "STUDENT" : "PARENT"
        };

        var response = await signupApi.signupUser(signupData);

        if (response.statusCode == 201) {
          if (values[6].isEmpty) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => AfterSignUp(name: values[0], role: 1, isKey: false),
              ),
                  (route) => false,
            );
          } else {
            await _registerAcademy(values);
          }
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "회원가입 중 오류가 발생했습니다.");
      }
    }
  }

  Future<void> _registerAcademy(List<String> values) async {
    try {
      var loginResponse = await signupApi.loginUser(values[1], values[2]);
      String token = loginResponse.data['accessToken'];

      await storage.write(key: 'accessToken', value: token);

      // 'set-cookie' 헤더가 null이 아닌지 체크한 후 접근
      if (loginResponse.headers['set-cookie'] != null && loginResponse.headers['set-cookie']!.isNotEmpty) {
        await storage.write(key: 'refreshToken', value: loginResponse.headers['set-cookie']![0]);
      } else {
        Fluttertoast.showToast(msg: "로그인 후 쿠키 정보를 찾을 수 없습니다.");
        return;
      }

      await storage.write(key: 'id', value: values[1]);

      var registerResponse = await signupApi.registerAcademy(
        values[1],
        values[6],
        (role == Role.STUDENT) ? "STUDENT" : "PARENT",
      );

      if (registerResponse.statusCode == 201) {
        Fluttertoast.showToast(msg: "회원가입 및 학원 등록 요청이 완료되었습니다.");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => AfterSignUp(name: values[0], role: 1, isKey: true),
          ),
              (route) => false,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "학원 등록 요청 중 오류가 발생했습니다.");
    }
  }


  @override
  Widget build(BuildContext context) {
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
                      child: Text("Sign Up", style: TextStyle(fontSize: 40.sp)),
                    ),
                    _buildRoleSelection(),
                    _buildSignupForm(),
                    _buildSignupButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 160.w,
          height: 51.h,
          child: RadioListTile(
            title: const Text("학생"),
            value: Role.STUDENT,
            groupValue: role,
            onChanged: (value) {
              setState(() {
                role = Role.STUDENT;
                hintText = "학원초대키";
              });
            },
          ),
        ),
        SizedBox(
          width: 160.w,
          height: 51.h,
          child: RadioListTile(
            title: const Text("학부모"),
            value: Role.PARENT,
            groupValue: role,
            onChanged: (value) {
              setState(() {
                role = Role.PARENT;
                hintText = "학생아이디";
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSignupForm() {
    return Column(
      children: [
        SizedBox(
          width: 342.w,
          child: TextFormField(
            controller: controllers[0],
            decoration: const InputDecoration(hintText: "이름"),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_idFocusNode),
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 230.w,
              child: TextFormField(
                controller: controllers[1],
                decoration: const InputDecoration(hintText: "ID"),
                focusNode: _idFocusNode,
              ),
            ),
            SizedBox(width: 10),
            SizedBox(
              width: 106.w,
              child: ElevatedButton(
                onPressed: _checkId,
                child: Text("중복확인", style: TextStyle(fontSize: 18.spMin)),
                style: ElevatedButton.styleFrom(backgroundColor: mainColor),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        _buildPasswordFields(),
        SizedBox(height: 10),
        _buildAdditionalFields(),
      ],
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      children: [
        SizedBox(
          width: 342.w,
          child: TextFormField(
            controller: controllers[2],
            decoration: const InputDecoration(hintText: "비밀번호"),
            focusNode: _pw1FocusNode,
            obscureText: true,
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          width: 342.w,
          child: TextFormField(
            controller: controllers[2],
            decoration: const InputDecoration(hintText: "비밀번호 확인"),
            focusNode: _pw2FocusNode,
            obscureText: true,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalFields() {
    return Column(
      children: [
        // Email
        SizedBox(
          width: 342.w,
          child: TextFormField(
            controller: controllers[3],
            decoration: const InputDecoration(hintText: "Email"),
            focusNode: _emailFocusNode,
          ),
        ),
        // Phone Number
        SizedBox(
          width: 342.w,
          child: TextFormField(
            controller: controllers[4],
            decoration: const InputDecoration(hintText: "전화번호"),
            focusNode: _phoneFocusNode,
          ),
        ),
        // Birth Date
        SizedBox(
          width: 342.w,
          child: TextFormField(
            controller: controllers[5],
            readOnly: true,
            decoration: const InputDecoration(hintText: "생년월일"),
            focusNode: _birthFocusNode,
            onTap: () async {
              final DateTime? dateTime = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: DateTime(1000),
                lastDate: DateTime(3000),
              );
              if (dateTime != null) {
                controllers[5].text = dateTime.toString().split(' ')[0];
              }
            },
          ),
        ),
        // Academy Key
        SizedBox(
          width: 342.w,
          child: TextFormField(
            controller: controllers[6],
            decoration: InputDecoration(hintText: hintText),
            focusNode: _keyFocusNode,
          ),
        ),
      ],
    );
  }

  Widget _buildSignupButton() {
    return SizedBox(
      width: 342.w,
      child: ElevatedButton(
        onPressed: _signup,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("회원가입", style: TextStyle(fontSize: 24.sp)),
        ),
        style: ElevatedButton.styleFrom(backgroundColor: mainColor),
      ),
    );
  }
}
