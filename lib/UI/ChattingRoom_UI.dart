import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChattingRoomUI extends StatefulWidget {
  final String roomId;

  const ChattingRoomUI({required this.roomId, Key? key}) : super(key: key);

  @override
  State<ChattingRoomUI> createState() => _ChattingRoomUIState();
}

class _ChattingRoomUIState extends State<ChattingRoomUI> {
  final FlutterSecureStorage storage = FlutterSecureStorage(); // SecureStorage 인스턴스
  late IO.Socket socket;
  List<Map<String, dynamic>> messages = [];
  TextEditingController messageController = TextEditingController();
  String? userId; // 저장된 ID를 담을 변수

  @override
  void initState() {
    super.initState();
    _loadUserId(); // ID를 불러옴
  }

  // ID 불러오기
  Future<void> _loadUserId() async {
    try {
      final storedUserId = await storage.read(key: 'user_id'); // 저장된 ID 가져오기
      if (storedUserId != null) {
        setState(() {
          userId = storedUserId; // 저장된 ID를 state에 저장
        });
        connectSocket(); // ID를 가져온 후 소켓 연결
      } else {
        print("User ID not found in storage");
      }
    } catch (e) {
      print("Error loading user ID: $e");
    }
  }

  void connectSocket() {
    if (userId == null) return; // userId가 없으면 연결하지 않음

    socket = IO.io(
      'http://192.168.200.139:8000', // 서버 주소
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.onConnect((_) {
      print("Connected to socket server");

      socket.emit('create or join room', {
        'roomId': widget.roomId,
        'userId': userId, // 불러온 userId 사용
      });

      socket.on('chat message', (data) {
        setState(() {
          messages.add({
            'userId': data['userId'] ?? 'unknown',
            'message': data['message'] ?? '',
            'timestamp': data['timestamp'] ?? '',
          });
        });
      });

      socket.on('all messages', (data) {
        setState(() {
          messages = List<Map<String, dynamic>>.from(data.map((msg) => {
            'userId': msg['userId'] ?? 'unknown',
            'message': msg['message'] ?? '',
            'timestamp': msg['timestamp'] ?? '',
          }));
        });
      });
    });

    socket.onError((err) {
      print("Socket error: $err");
    });

    socket.connect();
  }

  void sendMessage() {
    if (messageController.text.isNotEmpty && userId != null) {
      final message = messageController.text;
      socket.emit('chat message', {
        'roomId': widget.roomId,
        'userId': userId, // 저장된 ID를 사용
        'message': message,
      });
      setState(() {
        messages.add({
          'userId': userId, // 저장된 ID를 로컬에서도 사용
          'message': message,
          'timestamp': DateTime.now().toString(),
        });
        messageController.clear();
      });
    }
  }

  @override
  void dispose() {
    if (userId != null) {
      socket.emit('leave room', {'roomId': widget.roomId, 'userId': userId});
    }
    socket.off('chat message');
    socket.off('all messages');
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("채팅방")),
      body: userId == null
          ? Center(child: CircularProgressIndicator()) // ID를 로드할 때 로딩 표시
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final senderId = message['userId'] ?? 'unknown';
                final msg = message['message'] ?? '';
                final timestamp = message['timestamp'] != null
                    ? DateTime.parse(message['timestamp'])
                    .toLocal()
                    .toString()
                    .substring(0, 16)
                    : '';

                return ListTile(
                  title: Text(senderId),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(msg),
                      SizedBox(height: 5),
                      Text(timestamp,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "메시지를 입력하세요",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
