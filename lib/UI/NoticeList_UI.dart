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
  bool isLoading = true;
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
        subjects = await _appBarApi.getStoredSubjects();
        _selectedLectureId = subjects.first['lecture_id'].toString();
      }
      await _fetchNotices();
      setState(() {
        isLoadingSubjects = false;
      });
    } catch (e) {
      print("Error initializing data: $e");
    }
  }

  Future<void> _fetchNotices() async {
    try {
      setState(() {
        isLoading = true;
      });
      final lectureId = widget.isAcademy ? 0 : int.parse(_selectedLectureId!);
      final response = await _api.fetchNotices(
        lectureId: lectureId,
        page: 1,
        pageSize: 10,
      );
      setState(() {
        notices = List<Map<String, dynamic>>.from(response['data']['notice_list']);
        isLoading = false;
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
            if (!widget.isAcademy)
              isLoadingSubjects
                  ? CircularProgressIndicator()
                  : DropdownButton<String>(
                value: _selectedLectureId,
                items: subjects.map((subject) {
                  return DropdownMenuItem<String>(
                    value: subject['lecture_id'].toString(),
                    child: Text(subject['lecture_name'], style: TextStyle(fontSize: 18.sp)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedLectureId = newValue!;
                    _fetchNotices();
                  });
                },
              ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: notices.length,
                itemBuilder: (context, index) {
                  final notice = notices[index];
                  return ListTile(
                    title: Text(notice['title'], style: TextStyle(fontSize: 16.sp)),
                    subtitle: Text(
                      '작성자: ${notice['user_id']}, ${notice['created_at'].substring(0, 10)}',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoticeDetail(noticeId: notice['notice_id']),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
