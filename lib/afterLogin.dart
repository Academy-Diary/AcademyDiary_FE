import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF565D6D), // 앱 바 색상을 진한 회색으로 설정
        title: Text(
          'AcademyPro',
          style: TextStyle(color: Colors.white), // 제목 텍스트 색상을 흰색으로 설정
        ),
        centerTitle: true, // 제목을 가운데 정렬
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white), // 햄버거 메뉴 아이콘 색상 흰색으로 설정
          onPressed: () {
            Scaffold.of(context).openDrawer(); // Drawer 열기
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white), // 알림 아이콘 색상 흰색으로 설정
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.white), // 검색 아이콘 색상 흰색으로 설정
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(), // 햄버거 메뉴를 위한 Drawer
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
