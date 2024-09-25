import 'package:academy_manager/API/NoticeList_API.dart';
import 'package:academy_manager/UI/AppBar_UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/UI/NoticeDetail_UI.dart';

class NoticeList extends StatefulWidget {
  bool? isAcademy; //학원 공지 여부 true: 학원공지, false: 수업공지
  NoticeList({super.key, this.isAcademy=true}); // isAcademy의 기본값은 true,
  @override
  _NoticeListState createState() => _NoticeListState(this.isAcademy);
}

class _NoticeListState extends State<NoticeList> {
  bool? isAcademy;
  String name="" , email = "";
  _NoticeListState(this.isAcademy);
  String _selectedCategory = '수업1'; // 기본 선택값
  final NoticelistApi _ntl = NoticelistApi();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initData();
  }

  _initData()async{
    String? id = await _ntl.getId();
    String? accessToken = await _ntl.getAccessToken();
    var info = await _ntl.fetchUserInfo(id!, accessToken!);
    setState(() {
      name = info['user_name'];
      email = info['email'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar().build(context),
      drawer: MenuDrawer(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(!isAcademy!)
              DropdownButton<String>(
                value: _selectedCategory,
                items: <String>['수업1', '수업2'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(fontSize: 18.sp)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
            Expanded(
              child: ListView(
                children: isAcademy==true
                    ? _buildAcademyNotices()
                    : _buildClassNotices(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAcademyNotices() {
    return [
      ListTile(
        title: Text("공지 1", style: TextStyle(fontSize: 16.sp)),
        subtitle: Text("작성자: 김OO, 2024.07.01", style: TextStyle(fontSize: 14.sp)),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NoticeDetail()),
          );
        },
      ),
      ListTile(
        title: Text("공지 2", style: TextStyle(fontSize: 16.sp)),
        subtitle: Text("작성자: 김OO, 2024.06.05", style: TextStyle(fontSize: 14.sp)),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NoticeDetail()),
          );
        },
      ),
    ];
  }

  List<Widget> _buildClassNotices() {
    return [
      ListTile(
        title: Text("수업 공지 1", style: TextStyle(fontSize: 16.sp)),
        subtitle: Text("작성자: 박OO, 2024.08.01", style: TextStyle(fontSize: 14.sp)),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NoticeDetail()),
          );
        },
      ),
      ListTile(
        title: Text("수업 공지 2", style: TextStyle(fontSize: 16.sp)),
        subtitle: Text("작성자: 박OO, 2024.08.15", style: TextStyle(fontSize: 14.sp)),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NoticeDetail()),
          );
        },
      ),
    ];
  }
}
