import 'package:academy_manager/UI/AppBar_UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/UI/QuizDetail_UI.dart';

class QuizListPage extends StatefulWidget {
  @override
  _QuizListPageState createState() => _QuizListPageState();
}

class _QuizListPageState extends State<QuizListPage> {
  String _selectedSubject = "전과목";  // 과목 선택 값
  String _selectedCategory = "모의고사";  // 시험 유형 선택 값
  final List<String> _subjects = ["전과목", "미적분", "영어", "국어"];  // 테스트 과목 데이터
  final List<String> _categories = ["모의고사", "단원평가", "쪽지시험"];  // 테스트 시험 유형 데이터

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar().build(context),  // AppBar 재사용
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _selectedCategory,
                  items: _categories.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                  hint: Text("시험 유형을 선택하세요"),
                ),
                DropdownButton<String>(
                  value: _selectedSubject,
                  items: _subjects.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedSubject = newValue!;
                    });
                  },
                  hint: Text("과목을 선택하세요"),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: ListView.builder(
                itemCount: 5,  // 쪽지시험 수
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 10.h),
                    child: ListTile(
                      title: Text("쪽지시험 $index", style: TextStyle(fontSize: 18.sp)),
                      subtitle: Text("응시일: 2024.10.01", style: TextStyle(fontSize: 14.sp)),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16.w),
                      onTap: () {
                        // 해당 쪽지시험 문제로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizDetailPage(),
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
