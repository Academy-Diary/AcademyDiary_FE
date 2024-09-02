import 'dart:ui';

import 'package:academy_manager/AppBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ViewScore extends StatefulWidget {
  String token;
  ViewScore({super.key, required this.token});

  @override
  State<ViewScore> createState() => _ViewScoreState(token: token);
}

class _ViewScoreState extends State<ViewScore> {
  Color mainColor = Color(0xFF565D6D);
  Color backColor = Color(0xFFD9D9D9);
  String _selectSubject = ""; // 과목 선택된 값
  String _selectCategory = ""; //시험유형 선택된 값
  final _category = ["모의고사", "단원평가", "쪽지시험"]; // 테스트 데이터
  final _subjects = ["전과목", "미적분", "영어", "국어"]; //테스트 데이터

  String token;
  _ViewScoreState({required this.token});
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _selectSubject = _subjects[0];
      _selectCategory = _category[0];
    });

  }
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context); // ScreenUtil 초기화

    return Scaffold(
      appBar: MyAppBar().build(context),
      drawer: MenuDrawer(token: token, name: "현우진", email: "aaa@test.com", subjects: ["미적분", "영어", "국어"],),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownMenu(
                    width: 135.w,
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
                    width: 135.w,
                    initialSelection: _selectSubject,
                    dropdownMenuEntries: _subjects
                        .map<DropdownMenuEntry<String>>((String value){
                      return DropdownMenuEntry(value: value, label: value);
                    }).toList(),
                    label: Text("과목 선택"),
                    onSelected: (value){
                      setState(() {
                        _selectSubject = value!;
                      });
                    },
                  )
                ],
              ), //상단 선택메뉴 끝
              SizedBox(height: 20.h,),
              DataTable(
                columnSpacing: 25.sp,
                columns: [
                  DataColumn(label: Expanded(child: Text("시험유형"))),
                  DataColumn(label: Expanded(child: Text("시험이름"))),
                  DataColumn(label: Expanded(child: Text("과목명"))),
                  DataColumn(label: Expanded(child: Text("점수"))),
                  DataColumn(label: Expanded(child: Text("응시일"))),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(Text("월말평가")),
                    DataCell(Text("12월평가")),
                    DataCell(Text("미적분")),
                    DataCell(Text("40.6")),
                    DataCell(Text("12/26")),
                  ]),
                  DataRow(cells: [
                    DataCell(Text("단어평가")),
                    DataCell(Text("Day12단어")),
                    DataCell(Text("영어")),
                    DataCell(Text("90.5")),
                    DataCell(Text("10/02")),
                  ])
                ],

              )
            ],
          ),
        ),
      ),
    );
  }
}
