import 'package:academy_manager/UI/AppBar_UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PushList extends StatefulWidget {
  const PushList({super.key});

  @override
  State<PushList> createState() => _PushListState();
}

class _PushListState extends State<PushList> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar().build(context),
      drawer: MenuDrawer(name: "Minsoo Kim", email: "minsoomark@naver.com", subjects:["미적분", "영어", "국어"]),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(1.w, 11.h, 1.w, 11.h),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categoryButton(),
                ),
              ),
            ),
            SizedBox(
              height: 35.h,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Text(
                    '오늘',
                    style: TextStyle(fontSize: 22.r),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: _pushItem("전체"),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  List<Widget> _categoryButton(){
    return [
      SizedBox(
        width: 74.w,
        height: 30.h,
        child: Padding(
          padding: EdgeInsets.only(right: 6.w),
          child: ElevatedButton(
            onPressed: (){

            },
            child: Text(
              "전체",
              style: TextStyle(fontSize: 14.sp),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF565D6D),
              disabledBackgroundColor: Color(0x0C000000),
              shape: StadiumBorder(),
            ),
          ),
        ),
      ),
      SizedBox(
        width: 74.w,
        height: 30.h,
        child: Padding(
          padding: EdgeInsets.only(right: 6.w),
          child: ElevatedButton(
            onPressed: (){

            },
            child: Text(
              "공지",
              style: TextStyle(fontSize: 14.sp, color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[400],
              shape: StadiumBorder(),
            ),
          ),
        ),
      ),
      SizedBox(
        width: 74.w,
        height: 30.h,
        child: Padding(
          padding: EdgeInsets.only(right: 6.w),
          child: ElevatedButton(
            onPressed: (){

            },
            child: Text(
              "출결",
              style: TextStyle(fontSize: 14.sp, color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[400],
              shape: StadiumBorder(),
            ),
          ),
        ),
      ),
      SizedBox(
        width: 87.w,
        height: 30.h,
        child: Padding(
          padding: EdgeInsets.only(right: 6.w),
          child: ElevatedButton(
            onPressed: (){

            },
            child: Text(
              "학원비",
              style: TextStyle(fontSize: 14.sp, color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[400],
              shape: StadiumBorder(),
            ),
          ),
        ),
      ),
      SizedBox(
        width: 74.w,
        height: 30.h,
        child: Padding(
          padding: EdgeInsets.only(right: 6.w),
          child: ElevatedButton(
            onPressed: (){

            },
            child: Text(
              "채팅",
              style: TextStyle(fontSize: 14.sp, color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[400],
              shape: StadiumBorder(),
            ),
          ),
        ),
      )
    ];
  }

  List<Widget> _pushItem(String category){
    List<Map<String, String>> noti_pushs = [
      {'category': '수업명', 'title': '[채팅]강사명', 'content': '마지막 받은 채팅 내용', 'time': '09/22 22:00'},
      {'category': '학원공지', 'title': '[학원비] 청구서 이름', 'content': 'Total: ₩300,000', 'time': '09/22 10:00'},
    ]; //[{category: '학원공지', title: '[채팅]강사명', content: '마지막 받은 채팅 내용', time: '09/22 22:00'}, ]

    List<Widget> items = [];
    noti_pushs.forEach((noti){
      if(noti['category'] == category || category == "전체") // category가 전체이거나 인자로 받은 카테고리의 알림만 리스트로 띄우기
      items.add(
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border(bottom: BorderSide(color:Colors.grey)),
            ),
            child: ListTile(
              title:Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                    Align(alignment:Alignment.centerLeft, child: Text(noti['category'].toString(), textAlign: TextAlign.left,style: TextStyle(fontSize: 12.sp),)),
                    Align(alignment:Alignment.centerLeft, child: Text(noti['title'].toString())),
                  ],
                ),
              ),
              subtitle: Text(noti['content'].toString()),
              trailing: Text(noti['time'].toString()),
              onTap: (){
                // 클릭했을 때 이벤트
              },
            ),
          ),
      );
    });

    return items;
  }
}
