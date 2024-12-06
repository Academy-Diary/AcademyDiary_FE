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
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      name = await _billApi.getName();
      String? userId = await _billApi.getUserId();
      if (userId != null) {
        bills = await _billApi.fetchBills(userId);
      } else {
        throw Exception("사용자 ID를 가져올 수 없습니다.");
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar().build(context),
      drawer: MenuDrawer(),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(
          child: Text(
            "오류 발생: $errorMessage",
            style: TextStyle(color: Colors.red, fontSize: 16.sp),
          ),
        )
            : ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            Center(
              child: Text(
                '$name님 학원비 청구서',
                style: TextStyle(fontSize: 24.sp),
              ),
            ),
            18.verticalSpace,
            ...bills.map((bill) => _buildBillCard(bill)).toList(),
            100.verticalSpace,
            Center(
              child: SizedBox(
                width: 188.w,
                height: 60.h,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: 결제 기능 추가
                    print('결제하기 버튼 클릭');
                  },
                  child: Text(
                    "결제하기",
                    style: TextStyle(fontSize: 18.sp),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillCard(Map<String, dynamic> bill) {
    bool isPaid = bill['paid'] ?? false;
    return Container(
      width: 320.w,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Text(
              isPaid ? "납부 완료" : "미납부",
              style: TextStyle(
                color: isPaid ? Colors.green : Colors.red,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            "이름 : $name\n"
                "수강반: ${bill['class_name']}\n"
                "수업료: ₩${bill['amount']}\n"
                "납부 기한: ${bill['deadline']}",
            style: TextStyle(fontSize: 16.sp),
          ),
          SizedBox(height: 10.h),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Total: ₩${bill['amount']}",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
