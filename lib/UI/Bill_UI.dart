import 'package:flutter/material.dart';
import 'package:academy_manager/UI/AppBar_UI.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:academy_manager/API/Bill_API.dart';

class Bill extends StatefulWidget {
  const Bill({super.key});

  @override
  State<Bill> createState() => _BillState();
}

class _BillState extends State<Bill> {
  BillApi _bill = BillApi();
  String? name;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeData();
  }

  _initializeData() async{
    name = await _bill.getName();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar().build(context),
      drawer: MenuDrawer(),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name.toString()+ "님 학원비 청구서",
                style: TextStyle(fontSize: 24.sp, ),
              ),
              18.verticalSpace, // 제목과 청구서 사이 빈 공간 설정
              Container(
                width: 320.w,
                height: 320.h,
                decoration: BoxDecoration(
                  color: Color(0xFFD9D9D9),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Align(
                        child: Text(
                          "미납부",
                          style: TextStyle(color: Colors.red, fontSize: 12.sp, fontWeight: FontWeight.bold),
                        ),
                        alignment: Alignment.topRight,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            "이름 : $name\n수강반: 수학집중반\n\n수업료: ₩300,000\n\n교재비: ₩0",
                          style: TextStyle(fontSize: 18.sp),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Spacer(),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Total: ₩300,000",
                          style: TextStyle(fontSize: 18.sp),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              100.verticalSpace,
              SizedBox(
                width: 188.w,
                height: 60.h,
                child: ElevatedButton(
                  onPressed: (){
                    // 결제하기 버튼 클릭 시 결제 창 이동
                    // TODO: 결제시스템 연동 -> 웹페이지로? 아님 native 화면으로?
                  },
                  child: Text("결제하기", style: TextStyle(fontSize: 18.sp),),
                  style: ButtonStyle(

                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
