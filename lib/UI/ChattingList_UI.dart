import 'package:academy_manager/UI/AppBar_UI.dart';
import 'package:academy_manager/UI/ChattingRoom_UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChattingListUI extends StatefulWidget {
  const ChattingListUI({super.key});

  @override
  State<ChattingListUI> createState() => _ChattingListUIState();
}

class _ChattingListUIState extends State<ChattingListUI> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar().build(context),
      drawer: MenuDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "채팅",
              style: TextStyle(
                fontSize: 24.0,
              ),
            ),
          ),
          for(int i = 0; i<4; i++)
            showChattingRomList(context, "사용자 이름", "마지막 채팅 내용", "날짜 or 시간", i*1)
        ],
      ),
    );
  }

  Widget showChattingRomList(BuildContext context, String name, String content, String time, int unread){
    String s_unread = (unread>999)? "999+" : unread.toString(); // unread가 999보다 크다면 999+로 저장.
    return ListTile(
      // leading: , //TODO: 사용자 프로필 이미지 가져오기.
      leading: Image.asset('img/default.png'), //테스트 이미지
      title: Text(name),
      subtitle: Text(content),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if(unread > 0)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.redAccent,
            ),
            child: Padding(
              padding: EdgeInsets.all(8.r),
              child: Text(
                s_unread,
                textAlign:TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
          Text(time),
        ],
      ),
      shape:  Border(bottom: BorderSide(color: Color(0xFFD9D9D9))),
      onTap: (){
        // TODO: 채팅방 연결.
        Navigator.push(context, MaterialPageRoute(builder: (builder)=>ChattingRoomUI()));
      },
    );
  }
}
