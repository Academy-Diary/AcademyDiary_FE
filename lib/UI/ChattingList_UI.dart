import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:academy_manager/UI/ChattingRoom_UI.dart';
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

  Future<void> fetchTeacherList() async {
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
      print("Error fetching teacher list: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTeacherList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("채팅")),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchTeacherList,
        child: Icon(Icons.refresh),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : teacherList.isEmpty
          ? Center(child: Text("강사 목록이 없습니다."))
          : ListView.builder(
        itemCount: teacherList.length,
        itemBuilder: (context, index) {
          final teacher = teacherList[index];
          return ListTile(
            title: Text(teacher['user_name'] ?? '알 수 없음'),
            subtitle: Text("강사와의 대화 시작하기"),
            onTap: () {
              // 강사 클릭 시 ChattingRoomUI로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChattingRoomUI(
                    roomId: "room_${teacher['user_id'] ?? 'unknown'}",
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
