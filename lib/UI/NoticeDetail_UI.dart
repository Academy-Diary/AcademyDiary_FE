import 'package:academy_manager/API/NoticeDetail_API.dart';
import 'package:academy_manager/UI/AppBar_UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NoticeDetail extends StatefulWidget {
  final String noticeId;

  const NoticeDetail({super.key, required this.noticeId});

  @override
  _NoticeDetailState createState() => _NoticeDetailState();
}

class _NoticeDetailState extends State<NoticeDetail> {
  final NoticeDetailApi _api = NoticeDetailApi();
  bool isLoading = true;
  Map<String, dynamic>? noticeDetail;

  @override
  void initState() {
    super.initState();
    _fetchNoticeDetail();
  }

  Future<void> _fetchNoticeDetail() async {
    try {
      final response = await _api.fetchNoticeDetail(widget.noticeId);
      setState(() {
        noticeDetail = response['data']['notice'];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar().build(context),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("제목: ${noticeDetail?['title'] ?? ''}",
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 10.h),
              Text(
                "작성자: ${noticeDetail?['user_id']} / "
                    "날짜: ${noticeDetail?['created_at'].substring(0, 10)} / "
                    "View: ${noticeDetail?['views']}",
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
              SizedBox(height: 10.h),
              const Divider(),
              SizedBox(height: 10.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    noticeDetail?['content'] ?? '',
                    style: TextStyle(fontSize: 16.sp),
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
