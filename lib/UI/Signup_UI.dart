import 'package:academy_manager/UI/AfterSignup_UI.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:academy_manager/API/Signup_API.dart'; // API 관련 파일을 가져옴

enum Role { STUDENT, PARENT }

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
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
  Map<String, String> info = Map();

  // 아이디 중복 확인 여부를 나타내는 상태
  bool idck = false;

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
                      child: Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 40.sp),
                      ),
                    ),
                    _buildRoleRadioButtons(),
                    _buildNameField(),
                    _buildIDField(context),
                    _buildPasswordFields(),
                    _buildEmailField(),
                    _buildPhoneField(),
                    _buildBirthField(),
                    _buildInviteKeyField(),
                    _buildSignupButton(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleRadioButtons() {
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

  Widget _buildNameField() {
    return SizedBox(
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
    );
  }

  Widget _buildIDField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20.h),  // 명시적으로 간격을 추가
      child: SizedBox(
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
                  await SignupPageAPI.checkDuplicateID(
                      context, controllers[1].text, (bool isValidID) {
                    setState(() {
                      idck = isValidID; // idck 상태를 업데이트
                    });
                  });
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
      ),
    );
  }


  Widget _buildPasswordFields() {
    return Column(
      children: [
        SizedBox(
          width: 342.w,
          child: Padding(
            padding: EdgeInsets.only(top: 25.h),
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
      ],
    );
  }

  // 나머지 코드는 동일합니다.


  Widget _buildEmailField() {
    return SizedBox(
      width: 342.w,
      child: Padding(
        padding: EdgeInsets.only(top: 25.h),
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
    );
  }

  Widget _buildPhoneField() {
    return SizedBox(
        width: 342.w,
        child: Padding(
        padding: EdgeInsets.only(top: 25.h),
    child: TextFormField(
    controller: controllers[4],
    validator: (value) {
    if (value!.isEmpty) {
    return "전화번호를 입력하세요";
    } else if (!RegExp(r'^010-?([0-9]{4})-?([0-9]{4})$')
        .hasMatch(value.toString())) {
    return "올바른 형식의 휴대폰번호를 입력하세요";
    } else
    return null;
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
    );
  }

  Widget _buildBirthField() {
    return SizedBox(
      width: 342.w,
      child: Padding(
        padding: EdgeInsets.only(top: 25.h),
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
    );
  }

  Widget _buildInviteKeyField() {
    return SizedBox(
      width: 342.w,
      child: Padding(
        padding: EdgeInsets.only(top: 25.h),
        child: TextFormField(
          validator: (value) {
            if (role == Role.PARENT && value!.isEmpty) {
              return "학생 아이디를 입력하세요";
            } else {
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
    );
  }

  Widget _buildSignupButton(BuildContext context) {
    return SizedBox(
      width: 342.w,
      child: Padding(
        padding: EdgeInsets.only(top: 25.h),
        child: ElevatedButton(
          onPressed: () async {
            await SignupPageAPI.signup(
              context,
              controllers,
              role,
              _formKey,
              idck,
              storage,
              setState,
            );
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
    );
  }
}

