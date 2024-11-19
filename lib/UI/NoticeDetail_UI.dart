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
      print('API 응답: $response'); // 디버깅용 로그
      setState(() {
        // 공지 데이터를 noticeDetail에 저장
        noticeDetail = response['data']['notice'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching notice detail: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar().build(context),
      drawer: MenuDrawer(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : noticeDetail == null
            ? Center(child: Text('공지사항 데이터를 불러오지 못했습니다.'))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '공지사항 상세보기',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(16.w),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "제목: ${noticeDetail?['title'] ?? 'N/A'}",
                    style: TextStyle(fontSize: 18.sp),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    "작성자: ${noticeDetail?['user_id']} / "
                        "날짜: ${noticeDetail?['created_at'].substring(0, 10)} / "
                        "View: ${noticeDetail?['views']}",
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "본문: ${noticeDetail?['content'] ?? 'N/A'}",
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
