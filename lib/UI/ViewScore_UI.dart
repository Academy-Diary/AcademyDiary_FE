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
      print('Fetching exam types...');
      List<Map<String, dynamic>> fetchedExamTypes = await scoreApi.fetchExamTypes(academyId);  // academy_id 전달
      print('Exam types fetched: $fetchedExamTypes');
      setState(() {
        _examTypes = fetchedExamTypes;
        _selectCategory = _examTypes.isNotEmpty ? _examTypes[0]['exam_type_id'].toString() : "";
      });
      _fetchScores();
    } catch (e) {
      print('Error fetching exam types: $e');
    }
  }

  // 성적을 API에서 가져오는 메서드
  Future<void> _fetchScores() async {
    try {
      String userId = await scoreApi.getUserId();  // 사용자 ID 가져오기
      List<Map<String, dynamic>> fetchedScores = await scoreApi.fetchScores(
        userId: userId,
        lectureId: int.parse(_selectSubject),
        examType: _selectCategory,
        asc: _asc,
      );
      setState(() {
        _scores = fetchedScores;  // 가져온 성적을 화면에 반영
      });
    } catch (e) {
      // 에러 발생 시 처리
      print('Error fetching scores: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

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
                        child: Text(examType['exam_type_name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectCategory = value!;
                      });
                      _fetchScores();  // 시험 유형을 변경했을 때 성적 다시 조회
                    },
                  ),
                  // 정렬 선택 Switch
                  Switch(
                    value: _asc,
                    onChanged: (value) {
                      setState(() {
                        _asc = value;
                      });
                      _fetchScores();  // 정렬 옵션을 바꿨을 때 성적 다시 조회
                    },
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              // 성적 데이터 테이블
              DataTable(
                columnSpacing: 25.sp,
                columns: [
                  DataColumn(label: Expanded(child: Text("시험유형"))),
                  DataColumn(label: Expanded(child: Text("시험이름"))),
                  DataColumn(label: Expanded(child: Text("과목명"))),
                  DataColumn(label: Expanded(child: Text("점수"))),
                  DataColumn(label: Expanded(child: Text("응시일"))),
                ],
                rows: _scores.map((score) {
                  // 시험 유형 찾기
                  // 기존에 firstWhere로 비교하던 로직 대신 바로 exam_type_name 출력
                  final examTypeName = _examTypes.isNotEmpty ? _examTypes[0]['exam_type_name'] : '알 수 없음';


                  // 점수가 null일 경우 빈 값으로 처리
                  final scoreValue = score['score'] != null ? score['score'].toString() : '';

                  // 과목명을 가져오기
                  final lectureName = widget.subjects.firstWhere(
                        (subject) => subject['lecture_id'] == score['lecture_id'],
                    orElse: () => {'lecture_name': '알 수 없음'},
                  )['lecture_name'];

                  return DataRow(cells: [
                    DataCell(Text(examTypeName)),
                    DataCell(Text(score['exam_name'])),
                    DataCell(Text(lectureName)),
                    DataCell(Text(scoreValue)),
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
