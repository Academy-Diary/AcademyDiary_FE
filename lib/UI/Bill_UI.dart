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
                '$name님 청구서',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 18.h),
            ...bills.map((bill) => _buildBillCard(bill)).toList(),
            SizedBox(height: 30.h),
            _buildTotalSection(),
            SizedBox(height: 20.h),
            _buildPayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBillCard(Map<String, dynamic> bill) {
    bool isPaid = bill['paid'] ?? false;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Text(
              isPaid ? "납부 완료" : "미납",
              style: TextStyle(
                color: isPaid ? Colors.green : Colors.red,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bill['class_name']?.toString() ?? '알 수 없음',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              Text(
                "${bill['amount']?.toString()} ₩",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            "납부 기한: ${bill['deadline']?.toString()}",
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  // 하단 총 금액 및 결제 버튼
  Widget _buildTotalSection() {
    int totalAmount = bills.fold(
        0, (sum, bill) => sum + (int.tryParse(bill['amount'].toString()) ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Divider(thickness: 1, color: Colors.grey),
        SizedBox(height: 10.h),
        Text(
          "🧾 이번 달 총 납부 금액",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Text(
          "${totalAmount.toString()} ₩",
          style: TextStyle(
              fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildPayButton() {
    return Center(
      child: SizedBox(
        width: 200.w,
        height: 50.h,
        child: ElevatedButton(
          onPressed: () {
            // 결제 기능 구현
            print("결제하기 버튼 클릭");
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF024F51),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.r),
            ),
          ),
          child: Text(
            "결제하기",
            style: TextStyle(fontSize: 18.sp, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
