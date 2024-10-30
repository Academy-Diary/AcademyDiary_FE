import 'package:academy_manager/UI/AppBar_UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/API/Score_API.dart';

class ViewScore extends StatefulWidget {
  final List<Map<String, dynamic>> subjects; // 과목 리스트를 받아옴
  final String academyId; // academy_id를 받아옴

  ViewScore({required this.subjects, required this.academyId});

  @override
  State<ViewScore> createState() => _ViewScoreState();
}

class _ViewScoreState extends State<ViewScore> {
  Color mainColor = Color(0xFF565D6D);
  Color backColor = Color(0xFFD9D9D9);
  String _selectSubject = "0"; // 과목 선택된 값 (0은 전 과목)
  String _selectCategory = ""; // 시험유형 선택된 값
  bool _asc = true; // 성적 정렬
  bool _isLoading = true; // 로딩 상태 추가
  List<Map<String, dynamic>> _examTypes = []; // 시험 유형 리스트
  List<Map<String, dynamic>> _scores = []; // 성적 리스트

  final ScoreApi scoreApi = ScoreApi(); // Score API 호출을 위한 인스턴스

  @override
  void initState() {
    super.initState();
    _fetchExamTypes(); // 화면 처음 시작할 때 시험 유형을 가져옴
  }

  // 시험 유형을 API에서 가져오는 메서드
  Future<void> _fetchExamTypes() async {
    try {
      await scoreApi.initTokens();
      String academyId = await scoreApi.getAcademyId(); // 학원 ID 가져오기
      List<Map<String, dynamic>> fetchedExamTypes =
      await scoreApi.fetchExamTypes(academyId); // academy_id 전달
      setState(() {
        _examTypes = fetchedExamTypes;
        _selectCategory = _examTypes.isNotEmpty
            ? _examTypes[0]['exam_type_id'].toString()
            : "";
      });
      await _fetchScores(); // 시험 유형 가져온 후 성적 데이터 가져옴
    } catch (e) {
      print('Error fetching exam types: $e');
    }
  }

  Future<void> _fetchScores() async {
    try {
      setState(() {
        _isLoading = true; // 로딩 시작
      });

      String userId = await scoreApi.getUserId();
      List<Map<String, dynamic>> scores = await scoreApi.fetchScores(
        userId: userId,
        lectureId: int.parse(_selectSubject),
        examTypeId: _selectCategory,
        asc: _asc,
      );

      setState(() {
        _scores = scores;
        _isLoading = false; // 로딩 완료
      });
    } catch (e) {
      print('Error fetching scores: $e');
      setState(() {
        _isLoading = false; // 에러 발생 시에도 로딩 완료 처리
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    // '전과목' 옵션을 추가한 subject 리스트
    List<Map<String, dynamic>> subjectOptions = [
      {'lecture_id': '0', 'lecture_name': '전과목'},
      ...widget.subjects
    ];

    return Scaffold(
      appBar: MyAppBar().build(context),
      drawer: MenuDrawer(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 시험 유형 선택 Dropdown
                  DropdownButton(
                    value: _selectCategory,
                    items: _examTypes.map<DropdownMenuItem<String>>((examType) {
                      return DropdownMenuItem(
                        value: examType['exam_type_id'].toString(),
                        child: Text(
                          examType['exam_type_name'],
                          style: TextStyle(color: Colors.blue),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectCategory = value!;
                      });
                      _fetchScores(); // 시험 유형 변경 시 성적 다시 조회
                    },
                    underline: Container(
                      height: 1,
                      color: Colors.blue,
                    ),
                  ),
                  // 과목 선택 Dropdown (전과목 포함)
                  DropdownButton(
                    value: _selectSubject,
                    items: subjectOptions.map<DropdownMenuItem<String>>((subject) {
                      return DropdownMenuItem(
                        value: subject['lecture_id'].toString(),
                        child: Text(
                          subject['lecture_name'],
                          style: TextStyle(color: Colors.blue),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectSubject = value!;
                      });
                      _fetchScores(); // 과목 선택 후 성적 다시 조회
                    },
                    underline: Container(
                      height: 1,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // 로딩 중일 때 로딩 표시
              if (_isLoading)
                Center(child: CircularProgressIndicator()),

              // 로딩 완료 후 성적 테이블 또는 메시지 출력
              if (!_isLoading)
                _scores.isEmpty
                    ? Center(
                  child: Text(
                    "응시한 시험이 존재하지 않습니다.",
                    style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                  ),
                )
                    : DataTable(
                  columnSpacing: 25.sp,
                  columns: [
                    DataColumn(label: Expanded(child: Text("시험유형"))),
                    DataColumn(label: Expanded(child: Text("시험이름"))),
                    DataColumn(label: Expanded(child: Text("과목명"))),
                    DataColumn(label: Expanded(child: Text("점수"))),
                    DataColumn(label: Expanded(child: Text("응시일"))),
                  ],
                  rows: _scores.where((score) {
                    // 과목 필터링 로직
                    if (_selectSubject == "0") {
                      return true; // 전과목일 때 모든 점수 출력
                    } else {
                      return score['lecture_id'].toString() ==
                          _selectSubject; // 특정 과목 필터링
                    }
                  }).where((score) {
                    if (_selectCategory.isEmpty) {
                      return true; // 시험 유형이 없을 경우 모든 항목 출력
                    } else {
                      return score['exam_type_id'].toString() ==
                          _selectCategory; // 시험유형 필터링
                    }
                  }).map((score) {
                    // 과목명 가져오기
                    final lectureName = subjectOptions.firstWhere(
                          (subject) =>
                      subject['lecture_id'].toString() ==
                          score['lecture_id'].toString(),
                      orElse: () => {'lecture_name': '알 수 없음'},
                    )['lecture_name'];

                    return DataRow(cells: [
                      DataCell(Text(score['exam_type_name'])),
                      DataCell(Text(score['exam_name'])),
                      DataCell(Text(lectureName)),
                      DataCell(Text(score['score'].toString())),
                      DataCell(
                          Text(score['exam_date'].substring(0, 10))),
                    ]);
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
