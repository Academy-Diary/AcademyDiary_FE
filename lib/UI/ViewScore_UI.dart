import 'package:academy_manager/UI/AppBar_UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/API/Score_API.dart';

class ViewScore extends StatefulWidget {
  final List<Map<String, dynamic>> subjects;  // 과목 리스트를 받아옴
  final String academyId;  // academy_id를 받아옴

  ViewScore({required this.subjects, required this.academyId});

  @override
  State<ViewScore> createState() => _ViewScoreState();
}

class _ViewScoreState extends State<ViewScore> {
  Color mainColor = Color(0xFF565D6D);
  Color backColor = Color(0xFFD9D9D9);
  String _selectSubject = "0";  // 과목 선택된 값 (0은 전 과목)
  String _selectCategory = "";  // 시험유형 선택된 값
  bool _asc = true;  // 성적 정렬
  List<Map<String, dynamic>> _examTypes = [];  // 시험 유형 리스트
  List<Map<String, dynamic>> _scores = [];  // 성적 리스트

  final ScoreApi scoreApi = ScoreApi();  // Score API 호출을 위한 인스턴스

  @override
  void initState() {
    super.initState();
    _fetchExamTypes();  // 화면 처음 시작할 때 시험 유형을 가져옴
  }

  // 시험 유형을 API에서 가져오는 메서드
  Future<void> _fetchExamTypes() async {
    try {
      await scoreApi.initTokens();
      String academyId = await scoreApi.getAcademyId();  // 학원 ID 가져오기
      List<Map<String, dynamic>> fetchedExamTypes = await scoreApi.fetchExamTypes(academyId);  // academy_id 전달
      setState(() {
        _examTypes = fetchedExamTypes;
        _selectCategory = _examTypes.isNotEmpty ? _examTypes[0]['exam_type_id'].toString() : "";
      });
      await _fetchScores();  // 시험 유형 가져온 후 성적 데이터 가져옴
    } catch (e) {
      print('Error fetching exam types: $e');
    }
  }

  Future<void> _fetchScores() async {
    try {
      String userId = await scoreApi.getUserId();
      List<Map<String, dynamic>> fetchedScores = await scoreApi.fetchScores(
        userId: userId,
        lectureId: int.parse(_selectSubject),
        examTypeId: _selectCategory,
        asc: _asc,
      );

      // 전과목일 때는 lecture_id를 상위에서 가져오는 것이 아니라, 각 성적 항목의 데이터에서 직접 가져옴
      if (_selectSubject == "0") {
        // 전과목일 경우 각 성적 항목에서 lecture_id를 유지
        setState(() {
          _scores = fetchedScores;  // 가져온 성적을 화면에 반영
        });
      } else {
        // 특정 과목일 경우 lecture_id를 상위에서 추가
        for (var score in fetchedScores) {
          score['lecture_id'] = _selectSubject;
        }

        setState(() {
          _scores = fetchedScores;  // 가져온 성적을 화면에 반영
        });
      }
    } catch (e) {
      // 에러 발생 시 처리
      print('Error fetching scores: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    // '전과목' 옵션을 추가한 subject 리스트 (중복을 방지)
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
                      _fetchScores();  // 시험 유형을 변경했을 때 성적 다시 조회
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
                        _selectSubject = value!;  // 선택된 과목 업데이트
                      });
                      _fetchScores();  // 선택 후 성적 다시 조회
                    },
                    underline: Container(
                      height: 1,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

                DataTable(
                  columnSpacing: 25.sp,
                  columns: [
                    DataColumn(label: Expanded(child: Text("시험유형"))),
                    DataColumn(label: Expanded(child: Text("시험이름"))),
                    DataColumn(label: Expanded(child: Text("과목명"))),
                    DataColumn(label: Expanded(child: Text("점수"))),
                    DataColumn(label: Expanded(child: Text("응시일"))),
                  ],
                  rows: _scores.where((score) {
                    // 전과목일 때는 모든 시험을 보여주고, 특정 과목 선택 시 해당 과목의 시험만 보여줌
                    if (_selectSubject == "0") {
                      return true; // 전과목일 때는 모든 점수 출력
                    } else {
                      print('Comparing _selectSubject: $_selectSubject with score lecture_id: ${score['lecture_id']}');
                      return score['lecture_id'].toString() == _selectSubject; // 특정 과목일 때는 비교
                    }
                  }).map((score) {

                    // 과목명을 가져오기
                    final lectureName = subjectOptions.firstWhere(
                          (subject) => subject['lecture_id'].toString() == score['lecture_id'].toString(),
                      orElse: () => {'lecture_name': '알 수 없음'},
                    )['lecture_name'];

                    return DataRow(cells: [
                      DataCell(Text(_examTypes.firstWhere(
                            (examType) => examType['exam_type_id'].toString() == _selectCategory,
                        orElse: () => {'exam_type_name': '알 수 없음'},
                      )['exam_type_name'])),
                      DataCell(Text(score['exam_name'])),
                      DataCell(Text(lectureName)),
                      DataCell(Text(score['score'].toString())),  // 성적은 null 처리 안 함
                      DataCell(Text(score['exam_date'].substring(0, 10))),
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


