import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuizDetailPage extends StatefulWidget {
  @override
  _QuizDetailPageState createState() => _QuizDetailPageState();
}

class _QuizDetailPageState extends State<QuizDetailPage> {
  int _currentQuestionIndex = 0;
  List<int?> _selectedAnswers = [];

  final List<Map<String, dynamic>> _questions = [
    {
      "question": "1. 다음 중 수학의 미적분 개념에 해당하는 것은?",
      "answers": ["극한", "적분", "미분", "통계"],
      "correctAnswerIndex": 2,
    },
    {
      "question": "2. 영어 단어 'apple'의 뜻은?",
      "answers": ["바나나", "사과", "포도", "배"],
      "correctAnswerIndex": 1,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedAnswers = List.filled(_questions.length, null);
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = answerIndex;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _submitQuiz() {
    int correctCount = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i]["correctAnswerIndex"]) {
        correctCount++;
      }
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("시험 결과"),
          content: Text("총 ${_questions.length}문제 중 ${correctCount}문제를 맞췄습니다."),
          actions: [
            TextButton(
              child: Text("확인"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("쪽지시험 문제", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF565D6D),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "문제 ${_currentQuestionIndex + 1}/${_questions.length}",
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),
            Text(
              _questions[_currentQuestionIndex]["question"],
              style: TextStyle(fontSize: 18.sp),
            ),
            SizedBox(height: 20.h),
            Column(
              children: List.generate(_questions[_currentQuestionIndex]["answers"].length, (index) {
                return RadioListTile<int>(
                  title: Text(_questions[_currentQuestionIndex]["answers"][index]),
                  value: index,
                  groupValue: _selectedAnswers[_currentQuestionIndex],
                  onChanged: (value) {
                    _selectAnswer(value!);
                  },
                );
              }),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestionIndex > 0) ...[
                  ElevatedButton(
                    onPressed: _previousQuestion,
                    child: Text("이전 문제"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  ),
                ],
                if (_currentQuestionIndex < _questions.length - 1) ...[
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    child: Text("다음 문제"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: _submitQuiz,
                    child: Text("제출하기"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
