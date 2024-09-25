import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/UI/AppBar_UI.dart';
import 'package:fl_chart/fl_chart.dart';


class ScoreGraph extends StatefulWidget {
  String subjectName = "";
  ScoreGraph({super.key, required this.subjectName});

  @override
  State<ScoreGraph> createState() => _ScoreGraphState(this.subjectName);
}

class _ScoreGraphState extends State<ScoreGraph> {
  String subjectName = "";
  _ScoreGraphState(this.subjectName);

  //테스트 데이터
  final _category = ["모의고사", "단원평가", "쪽지시험"];
  final _graph = ["성적 추이 그래프", "전체 학생 점수 분포도"];
  String _selectCategory = "";
  String _selectGraph = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _selectCategory = _category[0];
      _selectGraph = _graph[0];
    });
  }
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Scaffold(
      appBar: MyAppBar().build(context),
      drawer: MenuDrawer(name: "현우진", email: "aaa@test.com", subjects: ["미적분", "영어", "국어"],),
      body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Text(
                  subjectName+" "+_selectGraph, //과목명 + 현재 선택된 그래프
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(0, 24.sp, 0, 20.sp),
                    child: _LineChart()
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownMenu(
                      width: 120.w,
                      initialSelection: _selectCategory,
                      dropdownMenuEntries: _category
                          .map<DropdownMenuEntry<String>>((String value){
                        return DropdownMenuEntry(value: value, label: value);
                      }).toList(),
                      label: Text("시험 분류"),
                      onSelected: (value){
                        setState(() {
                          _selectCategory = value!;
                        });
                      },
                    ),
                    DropdownMenu(
                      width: 160.w,
                      initialSelection: _selectGraph,
                      dropdownMenuEntries: _graph
                          .map<DropdownMenuEntry<String>>((String value){
                        return DropdownMenuEntry(value: value, label: value);
                      }).toList(),
                      label: Text("그래프 선택"),
                      onSelected: (value){
                        setState(() {
                          _selectGraph = value!;
                        });
                      },
                    )
                  ],
                )
              ],
            ),
          )
      ),
    );
  }
}



class _LineChart extends StatelessWidget {
  const _LineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400.w,
      height: 400.h,
      child: LineChart(
        LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: [
                  FlSpot(1, 40.3),
                  FlSpot(2, 80.2),
                ],// 각 데이터들의 더미 데이터
                color: Colors.redAccent,
              ),
              LineChartBarData(
                spots: [
                  FlSpot(0, 50),
                  FlSpot(3, 100),
                ],// 각 데이터들의 더미 데이터
                color: Colors.cyan,
              )
            ], // LineChartBarData들의 list형식, 한개의 LineChartBarData는 1개의 선 그래프
            titlesData: FlTitlesData(
              // 좌우상하 텍스트 설정
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      reservedSize: 40.w,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: EdgeInsets.only(right: 5.w),
                          child: Text(
                            value.toInt().toString()+"점",
                            textAlign: TextAlign.end,
                          ),
                        );
                      },
                      showTitles: true,
                      interval: 20, // 20점 간격으로 띄우기
                    )
                ),
                rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    )
                ),
                topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    )
                )
            ),
            // x축 y축의 최대 최소 값 설정
            minX: 0,
            maxX: 12,
            minY: 0,
            maxY: 100,

            backgroundColor: Colors.white,
            gridData: FlGridData(
                show: false
            ) // 선 그래프의 격자선 없애기
        ),
      ),
    );
  }
}
