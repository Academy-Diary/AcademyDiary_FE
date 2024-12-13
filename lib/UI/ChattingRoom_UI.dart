import 'package:academy_manager/UI/AppBar_UI.dart';
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
  final FlutterSecureStorage storage = FlutterSecureStorage();
  late IO.Socket socket;
  List<Map<String, dynamic>> messages = [];
  TextEditingController messageController = TextEditingController();
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    try {
      final storedUserId = await storage.read(key: 'user_id');
      if (storedUserId != null) {
        setState(() {
          userId = storedUserId;
        });
        connectSocket();
      } else {
        print("User ID not found in storage");
      }
    } catch (e) {
      print("Error loading user ID: $e");
    }
  }

  void connectSocket() {
    if (userId == null) return;

    socket = IO.io(
      'http://192.168.200.139:8000',
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );

    socket.onConnect((_) {
      print("Connected to socket server");

      socket.emit('create or join room', {
        'roomId': widget.roomId,
        'userId': userId,
      });

      socket.on('chat message', (data) {
        setState(() {
          messages.add({
            'userId': data['userId'] ?? 'unknown',
            'message': data['message'] ?? '',
            'timestamp': _formatTimestamp(data['timestamp']),
          });
        });
      });

      socket.on('all messages', (data) {
        setState(() {
          messages = List<Map<String, dynamic>>.from(data.map((msg) => {
            'userId': msg['userId'] ?? 'unknown',
            'message': msg['message'] ?? '',
            'timestamp': _formatTimestamp(msg['timestamp']),
          }));
        });
      });
    });

    socket.onError((err) {
      print("Socket error: $err");
    });

    socket.connect();
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return "";
    try {
      final time = DateTime.parse(timestamp).toLocal();
      return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return "";
    }
  }

  void sendMessage() {
    if (messageController.text.isNotEmpty && userId != null) {
      final message = messageController.text;
      socket.emit('chat message', {
        'roomId': widget.roomId,
        'userId': userId,
        'message': message,
        'timestamp': DateTime.now().toUtc().toString(),
      });
      messageController.clear(); // 텍스트 필드만 초기화
    }
  }

  @override
  void dispose() {
    if (userId != null) {
      socket.emit('leave room', {'roomId': widget.roomId, 'userId': userId});
    }
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar().build(context),
      drawer: MenuDrawer(),
      body: userId == null
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message['userId'] == userId;

                return Align(
                  alignment:
                  isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.grey.shade400, width: 1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft: isMe
                            ? Radius.circular(12)
                            : Radius.zero,
                        bottomRight: isMe
                            ? Radius.zero
                            : Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['message'],
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 2),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            message['timestamp'],
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "메시지를 입력하세요...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.black),
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
