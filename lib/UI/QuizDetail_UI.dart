import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/API/Quiz_API.dart';

class QuizDetailPage extends StatefulWidget {
  final int examId;

  QuizDetailPage({required this.examId});

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
    // 선택한 답 저장
    if (_selectedAnswerIndex != null && _markedAnswers.length < _maxQuestions) {
      _markedAnswers.add(_selectedAnswerIndex!);
    }

    // 다음 문제로 이동 또는 제출
    if (_currentQuestionIndex < _maxQuestions - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _fetchQuestion();
    } else {
      _submitQuiz(); // 마지막 문제에서는 제출
    }
  }

  void _submitQuiz() async {
    // 마지막 선택한 답 저장
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

      // 결과 표시
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
                  Navigator.of(context).pop(); // 퀴즈 목록으로 돌아가기
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
        title: Text("쪽지시험 문제"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _currentQuestion == null
          ? Center(child: Text("문제를 더 이상 불러올 수 없습니다.")) // 모든 문제를 다 푼 경우
          : Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 문제 번호 표시
            Text(
              "문제 ${_currentQuestionIndex + 1} / $_maxQuestions",
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),
            // 문제 내용
            Text(
              _currentQuestion!["question"] ?? "문제를 가져올 수 없습니다.",
              style: TextStyle(fontSize: 18.sp),
            ),
            SizedBox(height: 20.h),
            // 선택지 리스트
            Column(
              children: List.generate(
                (_currentQuestion!["options"] as List<dynamic>).length,
                    (index) {
                  return RadioListTile<int>(
                    title: Text(_currentQuestion!["options"][index]),
                    value: index,
                    groupValue: _selectedAnswerIndex,
                    onChanged: (value) {
                      _selectAnswer(value!);
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20.h),
            // 버튼 영역
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentQuestionIndex--;
                        _markedAnswers.removeLast(); // 이전 답안 제거
                      });
                      _fetchQuestion();
                    },
                    child: Text("이전 문제"),
                  ),
                ElevatedButton(
                  onPressed: _goToNextQuestion,
                  child: Text(
                    _currentQuestionIndex == _maxQuestions - 1
                        ? "제출하기"
                        : "다음 문제",
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
