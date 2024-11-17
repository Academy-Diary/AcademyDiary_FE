import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/API/ChattingList_API.dart';

class ChattingListUI extends StatefulWidget {
  const ChattingListUI({super.key});

  @override
  State<ChattingListUI> createState() => _ChattingListUIState();
}

class _ChattingListUIState extends State<ChattingListUI> {
  final TeacherApi teacherApi = TeacherApi();
  List<Map<String, dynamic>> teacherList = [];
  bool isLoading = false;

  void fetchTeacherList() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? academyId = await TeacherApi.storage.read(key: 'academy_id');
      if (academyId != null) {
        teacherList = await teacherApi.fetchTeachers(academyId);
      } else {
        print("학원 ID를 가져올 수 없습니다.");
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("채팅")),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchTeacherList,
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("채팅 목록", style: TextStyle(fontSize: 24.0)),
          ),
          isLoading
              ? CircularProgressIndicator()
              : Expanded(
            child: ListView.builder(
              itemCount: teacherList.length,
              itemBuilder: (context, index) {
                final teacher = teacherList[index];
                return ListTile(
                  title: Text(teacher['user_name'] ?? '알 수 없음'),
                  subtitle: Text("강사와의 대화 시작하기"),
                  onTap: () {
                    // 채팅방으로 이동하는 로직 추가
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
