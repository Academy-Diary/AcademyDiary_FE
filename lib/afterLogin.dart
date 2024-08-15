import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),//AppBar내 아이콘 컬러 데이터 지정 // 모든 아이콘에 동일하게 적용
        backgroundColor: Color(0xFF565D6D), // 앱 바 색상을 진한 회색으로 설정
        title: Text(
          'AcademyPro',
          style: TextStyle(color: Colors.white), // 제목 텍스트 색상을 흰색으로 설정
        ),
        centerTitle: true, // 제목을 가운데 정렬
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, ), // 알림 아이콘 지정.
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.search, ), // 검색 아이콘 지정
            onPressed: () {},
          ),
        ],
      ),
      drawer: MenuDrawer(name: "현우진", email: "test@abc.com", subjects: ["미적분", "영어", "국어"]),// 햄버거 메뉴를 위한 Drawer
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '현우진(학생)님 환영합니다',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // 폰트 굵게 설정
              ),
            ),
            SizedBox(height: 20), // 상단 여백 조정
            Center(
              child: SizedBox(
                width: double.infinity, // 버튼을 가로로 전체 화면에 맞게 설정
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF565D6D), // 버튼 색상 변경
                    padding: EdgeInsets.symmetric(vertical: 16.0), // 버튼의 세로 크기 조정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0), // 모서리를 둥글게 설정
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    '출석인증하기',
                    style: TextStyle(fontSize: 22, color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20), // 버튼과 다음 섹션 사이의 간격
            Text(
              "오늘의 수업",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // 폰트 굵게 설정
            ),
            SizedBox(height: 10), // 제목과 내용 사이의 간격
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2.0), // 테두리 색상과 두께 설정
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('영어', style: TextStyle(fontWeight: FontWeight.bold)), // 폰트 굵게 설정
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('16:00~18:00', style: TextStyle(fontWeight: FontWeight.bold)), // 폰트 굵게 설정
                  ),
                ],
              ),
            ),
            SizedBox(height: 20), // 오늘의 수업과 다음 섹션 사이의 간격
            Text(
              "학원 전체공지",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // 폰트 굵게 설정
            ),
            SizedBox(height: 10), // 제목과 내용 사이의 간격
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2.0), // 테두리 색상과 두께 설정
                ),
                child: ListView(
                  children: [
                    NoticeTile(
                      title: '공지 1',
                      author: '길영',
                      date: '2024.07.01',
                    ),
                    NoticeTile(
                      title: '공지 2',
                      author: '길영',
                      date: '2024.07.05',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20), // 학원 전체공지와 다음 섹션 사이의 간격
            Text(
              "오늘의 날씨",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // 폰트 굵게 설정
            ),
            SizedBox(height: 10), // 제목과 내용 사이의 간격
            SizedBox(
              width: double.infinity, // 날씨 박스가 가로로 전체 화면에 맞게 설정
              child: Container(
                color: Color(0xFF565D6D),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "서울특별시(학원 주소지 지역) 28도",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "최고: 33도 최저: 25도",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "소나기",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuDrawer extends StatefulWidget {
  final String name;
  final String email;
  final List<String> subjects;
  const MenuDrawer({super.key, required this.name, required this.email, required this.subjects});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState(name: name, email:email, subjects: subjects);
}

class _MenuDrawerState extends State<MenuDrawer> {
  final String name;
  final String email;
  final List<String> subjects;
  bool isNoticeClicked = false; // 공지사항 클릭 여부
  bool isGradeClicked = false; // 성적관리 클릭 여부
  bool isExpenseClicked = false; // 학원비 클릭 여부
  bool isSubjectClicked = false; // 강의목록 클릭 여부
  _MenuDrawerState({required this.name, required this.email, required this.subjects});


  @override
  Widget build(BuildContext context) {
    List<Widget> menu_subject = [];
    subjects.forEach((subject){
      menu_subject.add(
        ListTile(
          title: Text(subject, style: TextStyle(fontSize: 14),),
          onTap: (){
            // subject 별 이동 이벤트
          },
        )
      );
    });
    return Drawer(
      child: Column(
        //padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 140,
            child: const UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF565D6D),
              ),
              accountName: Text("현우진"),
              accountEmail: Text("test@abc.com"),
            ),
          ),
          ListTile(
            shape: Border(bottom: BorderSide(color: Color(0xFFD9D9D9))),
            title: Text("공지사항",style: TextStyle(fontSize: 16)),
            onTap: (){
              setState(() {
                isNoticeClicked = !isNoticeClicked;
              });
            },
            trailing: (!isNoticeClicked)? Icon(Icons.arrow_drop_down):Icon(Icons.arrow_drop_up),
          ),
          if(isNoticeClicked)
            Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Column(
                children: [
                  ListTile(
                    title: Text("학원공지" ,style: TextStyle(fontSize: 15)),
                    onTap: (){
                      // 학원 공지 화면으로 이동
                    },
                  ),
                  ListTile(
                    title: Text("수업공지",style: TextStyle(fontSize: 15)),
                    onTap: (){
                      //수업 공지 화면으로 이동
                    },
                  ),
                ],
              ),
            ), //서브메뉴 끝
          ListTile(
            shape: Border(bottom: BorderSide(color: Color(0xFFD9D9D9))),
            title: Text("성적관리"),
            onTap: (){
              setState(() {
                isGradeClicked = !isGradeClicked;
                if(!isGradeClicked) isSubjectClicked=false; // 성적관리가 접히면 안의 수강과목도 자동으로 접힘
              });
            },
            trailing: (!isGradeClicked)? Icon(Icons.arrow_drop_down):Icon(Icons.arrow_drop_up),
        ),
          if(isGradeClicked)
            Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Column(
                children: [
                  ListTile(
                    title: Text("성적조회" ,style: TextStyle(fontSize: 15)),
                    onTap: (){
                      // 성적조회 화면으로 이동
                    },
                  ),
                  ListTile(
                    shape: Border(bottom: BorderSide(color: Color(0xFFD9D9D9))),
                    title: Text("강의목록",style: TextStyle(fontSize: 15)),
                    onTap: (){
                      // 강의목록 추가 서브메뉴 열기
                      setState(() {
                        isSubjectClicked = !isSubjectClicked;
                      });
                    },
                    trailing: (!isSubjectClicked)? Icon(Icons.arrow_drop_down):Icon(Icons.arrow_drop_up),
                  ),
                  if(isSubjectClicked)
                    Padding(
                      padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                      child: Column(
                        children: menu_subject,
                      ),
                    )//2차 서브메뉴 끝
                ],
              ),
            ), // 서브메뉴 끝
          ListTile(
            shape: Border(bottom: BorderSide(color: Color(0xFFD9D9D9))),
            title: Text("학원비"),
            onTap: (){
              setState(() {
                isExpenseClicked = !isExpenseClicked;
              });
            },
            trailing: (!isExpenseClicked)? Icon(Icons.arrow_drop_down):Icon(Icons.arrow_drop_up),
        ),
          if(isExpenseClicked)
            Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Column(
                children: [
                  ListTile(
                    title: Text("청구서 확인" ,style: TextStyle(fontSize: 15)),
                    onTap: (){
                      // 청구서 확인 화면으로 이동
                    },
                  ),
                  ListTile(
                    title: Text("납부 현황",style: TextStyle(fontSize: 15)),
                    onTap: (){
                      // 납부 현황 화면 으로 이동
                    },
                  ),
                ],
              ),
            ),//서브메뉴 끝
          Spacer(),
          SizedBox(
            width: 150,
            height: 51,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton(
                onPressed: (){
                  //로그아웃 기능 구현
                },
                child: Text("로그아웃", style: TextStyle(color:Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF87888B)
                ),
              ),
            ),
          )
        ]
      ),
    );
  }
}


class NoticeTile extends StatelessWidget {
  final String title;
  final String author;
  final String date;

  NoticeTile({required this.title, required this.author, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black), // 테두리 색상을 검정으로 설정
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)), // 폰트 굵게 설정
        subtitle: Text('작성자: $author, $date'),
        trailing: Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
