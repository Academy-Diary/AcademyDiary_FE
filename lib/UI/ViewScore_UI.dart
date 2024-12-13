import 'package:academy_manager/UI/AppBar_UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/API/Score_API.dart';

class ViewScore extends StatefulWidget {
  final List<Map<String, dynamic>> subjects;
  final String academyId;

  ViewScore({required this.subjects, required this.academyId});

  @override
  State<ViewScore> createState() => _ViewScoreState();
}

class _ViewScoreState extends State<ViewScore> {
  Color mainColor = Color(0xFF565D6D);
  Color backColor = Color(0xFFD9D9D9);
  String _selectSubject = "0";
  String _selectCategory = "";
  bool _isLoading = true;
  List<Map<String, dynamic>> _examTypes = [];
  List<Map<String, dynamic>> _scores = [];

  final ScoreApi scoreApi = ScoreApi();

  @override
  void initState() {
    super.initState();
    _fetchExamTypes();
  }

  Future<void> _fetchExamTypes() async {
    try {
      await scoreApi.initTokens();
      String academyId = await scoreApi.getAcademyId();
      List<Map<String, dynamic>> fetchedExamTypes =
      await scoreApi.fetchExamTypes(academyId);

      setState(() {
        _examTypes = fetchedExamTypes;
        _selectCategory = _examTypes.isNotEmpty
            ? _examTypes[0]['exam_type_id'].toString()
            : "0";
      });

      await _fetchScores();
    } catch (e) {
      print('Error fetching exam types: $e');
    }
  }

  Future<void> _fetchScores() async {
    try {
      setState(() {
        _isLoading = true;
      });

      String userId = await scoreApi.getUserId();
      List<Map<String, dynamic>> scores = await scoreApi.fetchScores(
        userId: userId,
        lectureId: int.parse(_selectSubject),
        examTypeId: _selectCategory,
        asc: true, // ASC 값만 전달하고 UI에는 노출 안 함
      );

      setState(() {
        _scores = scores;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching scores: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildDropdown(
      String title,
      List<Map<String, dynamic>> options,
      String value,
      ValueChanged<String?> onChanged,
      ) {
    final dropdownItems = options
        .where((option) => option['lecture_id'] != null)
        .map((option) {
      return DropdownMenuItem<String>(
        value: option['lecture_id'].toString(),
        child: Text(option['lecture_name'] ?? "알 수 없음",
            style: TextStyle(fontSize: 13.sp)),
      );
    }).toList();

    final validValue = dropdownItems.any((item) => item.value == value)
        ? value
        : dropdownItems.first.value;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 13.sp,
                color: Colors.orange,
                fontWeight: FontWeight.bold),
          ),
          DropdownButton<String>(
            value: validValue,
            items: dropdownItems,
            onChanged: onChanged,
            underline: Container(height: 2, color: Colors.orange),
            isExpanded: true,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

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
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildDropdown(
                    "시험 유형",
                    _examTypes.map((e) {
                      return {
                        'lecture_id': e['exam_type_id'],
                        'lecture_name': e['exam_type_name']
                      };
                    }).toList(),
                    _selectCategory,
                        (value) {
                      setState(() {
                        _selectCategory = value!;
                        _fetchScores();
                      });
                    },
                  ),
                  SizedBox(width: 10.w),
                  _buildDropdown(
                    "과목 선택",
                    subjectOptions,
                    _selectSubject,
                        (value) {
                      setState(() {
                        _selectSubject = value!;
                        _fetchScores();
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              if (_isLoading)
                Center(child: CircularProgressIndicator()),
              if (!_isLoading)
                _scores.isEmpty
                    ? Center(
                  child: Text(
                    "응시한 시험이 존재하지 않습니다.",
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                )
                    : Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: 12.w,
                      headingTextStyle: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      dataTextStyle:
                      TextStyle(fontSize: 12.5.sp, color: Colors.black),
                      columns: [
                        DataColumn(
                            label: Center(child: Text("시험유형")),
                            numeric: false),
                        DataColumn(
                            label: Center(child: Text("시험이름")),
                            numeric: false),
                        DataColumn(
                            label: Center(child: Text("과목명")),
                            numeric: false),
                        DataColumn(
                            label: Center(child: Text("점수")),
                            numeric: true),
                        DataColumn(
                            label: Center(child: Text("응시일")),
                            numeric: false),
                      ],
                      rows: _scores.map((score) {
                        final lectureName = subjectOptions.firstWhere(
                              (subject) =>
                          subject['lecture_id'].toString() ==
                              score['lecture_id'].toString(),
                          orElse: () => {'lecture_name': '알 수 없음'},
                        )['lecture_name'];

                        return DataRow(cells: [
                          DataCell(Center(
                              child: Text(score['exam_type_name'] ?? "-"))),
                          DataCell(Center(
                              child: Text(score['exam_name'] ?? "-"))),
                          DataCell(Center(child: Text(lectureName))),
                          DataCell(Center(
                              child: Text(score['score'].toString()))),
                          DataCell(Center(
                              child: Text(score['exam_date']
                                  .substring(0, 10)))),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
