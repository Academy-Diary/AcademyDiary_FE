import 'dart:convert'; // FlutterSecureStorage 데이터 변환용
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
  final FlutterSecureStorage storage = FlutterSecureStorage(); // SecureStorage 인스턴스

  String? _selectedSubjectId; // 선택된 과목 ID
  List<Map<String, dynamic>> _subjects = []; // 저장된 과목 리스트
  List<Map<String, dynamic>> _quizList = []; // 필터링된 퀴즈 리스트
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // 초기화 및 데이터 로드
  // _initializeData에서 subjects 저장 확인
  Future<void> _initializeData() async {
    print("Initializing data...");

    setState(() {
      _isLoading = true;
    });

    try {
      // 저장된 과목 리스트 불러오기
      final storedSubjects = await storage.read(key: 'subjects');
      if (storedSubjects != null) {
        print("Loaded stored subjects: $storedSubjects");
        _subjects = List<Map<String, dynamic>>.from(jsonDecode(storedSubjects));
      } else {
        print("No stored subjects found, fetching from API...");

        // API 호출로 subjects 데이터 가져오기
        final fetchedSubjects = await quizAPI.fetchSubjects(); // 이 함수는 API 호출 로직에 맞게 작성
        _subjects = fetchedSubjects;

        // SecureStorage에 저장
        await storage.write(key: 'subjects', value: jsonEncode(fetchedSubjects));
        print("Fetched subjects stored in SecureStorage: $fetchedSubjects");
      }

      if (_subjects.isNotEmpty) {
        _selectedSubjectId = _subjects.first['lecture_id'].toString();
        print("Selected subject ID: $_selectedSubjectId");

        // 퀴즈 리스트 로드
        await _fetchQuizList();
      } else {
        print("No subjects found.");
      }
    } catch (e) {
      print("Error initializing data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  // 퀴즈 리스트 가져오기
  Future<void> _fetchQuizList() async {
    if (_selectedSubjectId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print("Fetching quizzes for lecture_id: $_selectedSubjectId and exam_type_id: 3");

      final quizList = await quizAPI.fetchQuizList(
        lectureId: int.parse(_selectedSubjectId!), // 선택된 과목 ID
        examTypeId: 3, // 쪽지시험만 가져오기
      );

      print("Fetched quizzes: $quizList");

      setState(() {
        _quizList = quizList;
      });
    } catch (e) {
      // 에러 메시지를 표시
      if (e.toString().contains("현재 개설된 시험이 존재하지 않습니다.")) {
        setState(() {
          _quizList = []; // 퀴즈 리스트를 빈 배열로 설정
        });
        print("404 Error Message: $e");
      } else {
        print("Error fetching quiz list: $e");
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
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
            Text(
              "쪽지시험 목록",
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                // 과목 선택 드롭다운
                DropdownButton<String>(
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
                    _fetchQuizList(); // 과목 변경 시 퀴즈 리스트 다시 로드
                  },
                ),
              ],
            ),
            SizedBox(height: 20.h),
        _isLoading
            ? Center(child: CircularProgressIndicator())
            : _quizList.isEmpty
            ? Center(
          child: Text(
            "현재 개설된 시험이 존재하지 않습니다.", // 404 메시지를 사용자에게 표시
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
        )
            : Expanded(
          child: ListView.builder(
            itemCount: _quizList.length,
            itemBuilder: (context, index) {
              final quiz = _quizList[index];
              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 10.h),
                child: ListTile(
                  title: Text(quiz['exam_name'] ?? "쪽지시험 ${index + 1}"),
                  subtitle: Text("응시일: ${quiz['exam_date'] ?? '알 수 없음'}"),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16.w),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizDetailPage(
                          examId: quiz['exam_id'],
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
}
