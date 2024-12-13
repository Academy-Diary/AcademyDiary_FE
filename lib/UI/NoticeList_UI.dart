import 'package:academy_manager/API/AppBar_API.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/UI/AppBar_UI.dart';
import 'package:academy_manager/API/NoticeList_API.dart';
import 'package:academy_manager/UI/NoticeDetail_UI.dart';

class NoticeList extends StatefulWidget {
  final bool isAcademy;

  const NoticeList({super.key, this.isAcademy = true});

  @override
  _NoticeListState createState() => _NoticeListState();
}

class _NoticeListState extends State<NoticeList> {
  final NoticeListApi _api = NoticeListApi();
  final AppbarApi _appBarApi = AppbarApi();
  List<Map<String, dynamic>> notices = [];
  List<Map<String, dynamic>> subjects = [];
  bool isLoadingNotices = true;
  bool isLoadingSubjects = true;
  String? _selectedLectureId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      if (!widget.isAcademy) {
        subjects = await _appBarApi.fetchAndStoreSubjects();
        if (subjects.isNotEmpty) {
          _selectedLectureId = subjects.first['lecture_id'].toString();
        }
        setState(() => isLoadingSubjects = false);
      }
      await _fetchNotices();
    } catch (e) {
      print("Error initializing data: $e");
    }
  }

  Future<void> _fetchNotices() async {
    try {
      setState(() => isLoadingNotices = true);
      final lectureId = widget.isAcademy ? 0 : int.parse(_selectedLectureId!);
      final response = await _api.fetchNotices(
        lectureId: lectureId,
        page: 1,
        pageSize: 10,
      );
      setState(() {
        notices = List<Map<String, dynamic>>.from(response['data']['notice_list']);
        isLoadingNotices = false;
      });
    } catch (e) {
      print("Error fetching notices: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar().build(context),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            _buildDropdown(),
            SizedBox(height: 10.h),
            Expanded(child: _buildNoticeList()),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Align(
      alignment: Alignment.centerLeft,
      child: widget.isAcademy
          ? const SizedBox.shrink()
          : isLoadingSubjects
          ? const Center(child: CircularProgressIndicator())
          : DropdownButton<String>(
        value: _selectedLectureId,
        style: TextStyle(fontSize: 14.sp, color: Colors.black),
        items: subjects.map((subject) {
          return DropdownMenuItem<String>(
            value: subject['lecture_id'].toString(),
            child: Text(subject['lecture_name']),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedLectureId = newValue!;
            _fetchNotices();
          });
        },
      ),
    );
  }

  Widget _buildNoticeList() {
    return isLoadingNotices
        ? const Center(child: CircularProgressIndicator())
        : notices.isEmpty
        ? const Center(child: Text("공지사항이 없습니다."))
        : ListView.builder(
      itemCount: notices.length,
      itemBuilder: (context, index) {
        final notice = notices[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
            child: ListTile(
              title: Text(notice['title'], style: TextStyle(fontSize: 16.sp)),
              subtitle: Text(
                '작성자: ${notice['user_id']}, ${notice['created_at'].substring(0, 10)}',
                style: TextStyle(fontSize: 14.sp),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoticeDetail(noticeId: notice['notice_id']),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
