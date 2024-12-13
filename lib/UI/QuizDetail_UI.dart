import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/API/Quiz_API.dart';

class QuizDetailPage extends StatefulWidget {
  final int examId;
  final String examName; // 퀴즈 이름 추가

  QuizDetailPage({required this.examId, required this.examName});

  @override
  _QuizDetailPageState createState() => _QuizDetailPageState();
}

class _QuizDetailPageState extends State<QuizDetailPage> {
  final QuizAPI quizAPI = QuizAPI();
  int _currentQuestionIndex = 0; // 현재 문제 번호
  Map<String, dynamic>? _currentQuestion; // 현재 문제 데이터
  List<int> _markedAnswers = []; // 사용자가 선택한 답
  int? _selectedAnswerIndex; // 현재 선택된 답
  bool _isLoading = false; // 로딩 상태
  final int _maxQuestions = 5; // 문제 개수 고정

  @override
  void initState() {
    super.initState();
    _fetchQuestion();
  }

  // 문제 가져오기
  Future<void> _fetchQuestion() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (_currentQuestionIndex < _maxQuestions) {
        final question = await quizAPI.fetchQuestion(
          widget.examId,
          _currentQuestionIndex,
        );
        setState(() {
          _currentQuestion = question;
          _selectedAnswerIndex = null; // 선택 초기화
        });
      } else {
        setState(() {
          _currentQuestion = null; // 모든 문제를 다 푼 경우
        });
      }
    } catch (e) {
      print("Error fetching question: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 답 선택 처리
  void _selectAnswer(int answerIndex) {
    setState(() {
      _selectedAnswerIndex = answerIndex;
    });
  }

  // 다음 문제로 이동
  void _goToNextQuestion() {
    if (_selectedAnswerIndex != null && _markedAnswers.length < _maxQuestions) {
      _markedAnswers.add(_selectedAnswerIndex!);
    }

    if (_currentQuestionIndex < _maxQuestions - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _fetchQuestion();
    } else {
      _submitQuiz(); // 마지막 문제에서 제출
    }
  }

  // 퀴즈 제출
  void _submitQuiz() async {
    if (_selectedAnswerIndex != null && _markedAnswers.length < _maxQuestions) {
      _markedAnswers.add(_selectedAnswerIndex!);
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await quizAPI.submitQuiz(
        examId: widget.examId,
        markedAnswers: _markedAnswers,
      );

      int correctCount = 0;
      int incorrectCount = 0;

      result['marked'].forEach((key, value) {
        if (value['corrected'] == true) {
          correctCount++;
        } else {
          incorrectCount++;
        }
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("시험 결과"),
            content: Text(
              "총 점수: ${result['score']}\n"
                  "정답: $correctCount 개\n"
                  "오답: $incorrectCount 개",
              style: TextStyle(fontSize: 16.sp),
            ),
            actions: [
              TextButton(
                child: Text("확인"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Error submitting quiz: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF4F1DE),
        title: Text(
          widget.examName, // examName 추가
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _currentQuestion == null
          ? Center(child: Text("문제를 더 이상 불러올 수 없습니다."))
          : Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "문제 ${_currentQuestionIndex + 1} / $_maxQuestions",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 15.h),
            Text(
              _currentQuestion!["question"] ?? "문제를 가져올 수 없습니다.",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20.h),
            ...List.generate(
              (_currentQuestion!["options"] as List<dynamic>).length,
                  (index) => RadioListTile<int>(
                title: Text(
                  _currentQuestion!["options"][index],
                  style: TextStyle(fontSize: 16.sp),
                ),
                value: index,
                groupValue: _selectedAnswerIndex,
                activeColor: Colors.green,
                onChanged: (value) => _selectAnswer(value!),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentQuestionIndex > 0
                      ? () {
                    setState(() {
                      _currentQuestionIndex--;
                      _markedAnswers.removeLast();
                    });
                    _fetchQuestion();
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    padding: EdgeInsets.symmetric(
                        vertical: 12.h, horizontal: 20.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    "이전 문제",
                    style: TextStyle(fontSize: 16.sp, color: Colors.black87),
                  ),
                ),
                ElevatedButton(
                  onPressed: _goToNextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentQuestionIndex ==
                        _maxQuestions - 1
                        ? Colors.orange
                        : Colors.grey.shade300,
                    padding: EdgeInsets.symmetric(
                        vertical: 12.h, horizontal: 20.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    _currentQuestionIndex == _maxQuestions - 1
                        ? "제출하기"
                        : "다음 문제",
                    style: TextStyle(
                        fontSize: 16.sp,
                        color: _currentQuestionIndex == _maxQuestions - 1
                            ? Colors.white
                            : Colors.black87),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
