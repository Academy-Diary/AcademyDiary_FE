import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/UI/AppBar_UI.dart';
import 'package:academy_manager/UI/QuizDetail_UI.dart';
import 'package:academy_manager/API/Quiz_API.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class QuizListPage extends StatefulWidget {
  @override
  _QuizListPageState createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  final QuizAPI quizAPI = QuizAPI();
  final FlutterSecureStorage storage = FlutterSecureStorage();
  String? _selectedSubjectId;
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _quizList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    try {
      final storedSubjects = await storage.read(key: 'subjects');
      if (storedSubjects != null) {
        _subjects = List<Map<String, dynamic>>.from(jsonDecode(storedSubjects));
      } else {
        final fetchedSubjects = await quizAPI.fetchSubjects();
        _subjects = fetchedSubjects;
        await storage.write(key: 'subjects', value: jsonEncode(fetchedSubjects));
      }

      if (_subjects.isNotEmpty) {
        _selectedSubjectId = _subjects.first['lecture_id'].toString();
        await _fetchQuizList();
      }
    } catch (e) {
      print("Error initializing data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchQuizList() async {
    if (_selectedSubjectId == null) return;
    setState(() => _isLoading = true);
    try {
      final quizList = await quizAPI.fetchQuizList(
        lectureId: int.parse(_selectedSubjectId!),
        examTypeId: 3,
      );
      setState(() => _quizList = quizList);
    } catch (e) {
      setState(() => _quizList = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar().build(context),
      drawer: MenuDrawer(),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDropdown(),
                SizedBox(width: 10.w),
              ],
            ),
            SizedBox(height: 20.h),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _quizList.isEmpty
                ? Center(
              child: Text(
                "현재 개설된 시험이 존재하지 않습니다.",
                style: TextStyle(fontSize: 16.sp),
              ),
            )
                : Expanded(
              child: ListView.builder(
                itemCount: _quizList.length,
                itemBuilder: (context, index) {
                  final quiz = _quizList[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 8.h),
                      title: Text(
                        quiz['exam_name'] ?? "쪽지시험 ${index + 1}",
                        style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "응시일: ${quiz['exam_date'] ?? '알 수 없음'}",
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      trailing:
                      Icon(Icons.arrow_forward_ios, size: 16.w),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizDetailPage(
                              examName: quiz['exam_name'],
                              examId: quiz['exam_id']
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButton<String>(
      value: _selectedSubjectId,
      items: _subjects.map((subject) {
        return DropdownMenuItem(
          value: subject['lecture_id'].toString(),
          child: Text(subject['lecture_name']),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedSubjectId = newValue!;
        });
        _fetchQuizList();
      },
      underline: Container(height: 2.h, color: Colors.orange),
    );
  }
}
