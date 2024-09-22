import 'package:academy_manager/UI/AppBar_UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/UI/NoticeDetail_UI.dart';

class NoticeList extends StatefulWidget {
  @override
  _NoticeListState createState() => _NoticeListState();
}

class _NoticeListState extends State<NoticeList> {
  String _selectedCategory = '학원공지';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar().build(context),
      drawer: MenuDrawer(name: '현우진', email: 'example@gmail.com', subjects: ['수학']),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: _selectedCategory,
              items: <String>['학원공지', '수업공지'].map((String value) {
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
                children: _selectedCategory == '학원공지'
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
