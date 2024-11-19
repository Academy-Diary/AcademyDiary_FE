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
  final BillApi _billApi = BillApi();
  String? name;
  List<Map<String, dynamic>> bills = [];
  bool isLoading = true;  // 로딩 상태 추가

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  _initializeData() async {
    name = await _billApi.getName();
    String? userId = await _billApi.getUserId(); // BillApi에서 user_id 가져오기
    if (userId != null) {
      try {
        bills = await _billApi.fetchBills(userId);
      } catch (e) {
        print('Error fetching bills: $e');
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar().build(context),
      drawer: MenuDrawer(),
      body: SafeArea(
        child: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$name님 학원비 청구서',
                style: TextStyle(fontSize: 24.sp),
              ),
              18.verticalSpace, // 제목과 청구서 사이 빈 공간 설정
              ...bills.map((bill) => _buildBillCard(bill)).toList(),
              100.verticalSpace,
              SizedBox(
                width: 188.w,
                height: 60.h,
                child: ElevatedButton(
                  onPressed: () {
                    // 결제하기 버튼 클릭 시 결제 창 이동
                    // TODO: 결제시스템 연동
                  },
                  child: Text("결제하기", style: TextStyle(fontSize: 18.sp)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillCard(Map<String, dynamic> bill) {
    bool isPaid = bill['paid'] ?? false;
    return Container(
      width: 320.w,
      height: 160.h,
      margin: EdgeInsets.symmetric(vertical: 8.h),
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
                isPaid ? "납부 완료" : "미납부",
                style: TextStyle(
                  color: isPaid ? Colors.green : Colors.red,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              alignment: Alignment.topRight,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "이름 : $name\n"
                    "수강반: ${bill['classes'][0]['class_name']}\n\n"
                    "수업료: ₩${bill['amount']}\n\n"
                    "납부 기한: ${bill['deadline']}",
                style: TextStyle(fontSize: 18.sp),
                textAlign: TextAlign.start,
              ),
            ),
            Spacer(),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Total: ₩${bill['amount']}",
                style: TextStyle(fontSize: 18.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
