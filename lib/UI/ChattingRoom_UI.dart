import 'package:academy_manager/UI/AppBar_UI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChattingRoomUI extends StatefulWidget {
  const ChattingRoomUI({super.key});

  @override
  State<ChattingRoomUI> createState() => _ChattingRoomUIState();
}

class _ChattingRoomUIState extends State<ChattingRoomUI> {
  final _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("이름", style: TextStyle(color: Colors.black, fontSize: 32.sp),),
        centerTitle: true,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(Icons.keyboard_arrow_left, color: Colors.black,size: 32.sp,),
        ),
      ), // 채팅방 전용 AppBar

      body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                child: Padding(
                    padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text('2024.10.01'),
                      _getSenderMessage(context, "이름", "메세지1", "08:30", false),
                      _getSenderMessage(context, "이름", "연속된 메세지입니다. ", "08:31", true),
                      _getSenderMessage(context, "이름", "연속된 메세지입니다. 근데 길이가 매우 길어진 근데 조금 더 길어지면?연속된 메세지입니다. 근데 길이가 매우 길어진 근데 조금 더 길어지면?연속된 메세지입니다. 근데 길이가 매우 길어진 근데 조금 더 길어지면?연속된 메세지입니다. 근데 길이가 매우 길어진 근데 조금 더 길어지면?연속된 메세지입니다. 근데 길이가 매우 길어진 근데 조금 더 길어지면?", "08:32", true),
                      SizedBox(height: 20.h,),
                      _getReceiverMessage(context, "내메세지", "08:33", true),
                    ],
                  ),
                )
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 310.w,
                  height: 60.h,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: TextField(
                      onTap: (){
                        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.linear);
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                        ),
                      ),
                      textAlignVertical: TextAlignVertical.center,
                    ),
                  ),
                ),
                IconButton(onPressed: (){}, icon: Icon(Icons.send, size: 40,))
              ],
            )
          ],
        ),
    );
  }

  Widget _getSenderMessage(context, String name, String msg, String time, bool isContinue){
    double defaultPadding = 10;

    if(!isContinue)
      defaultPadding = 1;
    return Padding(
      padding: EdgeInsets.only(top: defaultPadding),
      child: Row(
        children: [
          if(!isContinue)
          CircleAvatar(foregroundImage: AssetImage('img/default.png'), radius: 18.w,),
          if(isContinue)
            SizedBox(width: 36.w,),
          Padding(
            padding: EdgeInsets.only(left: 5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(!isContinue)
                  Text(name),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6), // 텍스트의 최대 너비 설정
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Text(msg),
                      ),
                    ),
                    Text(time)
                  ],
                ),
              ],
            ),
          ),
        ],
      )
    );
  }

  Widget _getReceiverMessage(context, String msg, String time, bool isRead){
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if(isRead)
                  Text("1"),
              Text(time),
            ],
          ),
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6), // 텍스트의 최대 너비 설정
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFFD9D9D9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Text(msg),
            ),
          ),
        ],
      ),
    );
  }
}
