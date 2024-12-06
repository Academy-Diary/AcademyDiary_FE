import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket _socket;

  void connect() {
    _socket = IO.io('http://localhost:5173', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.connect();

    _socket.onConnect((_) {
      print('Connected to socket server');
    });

    _socket.onDisconnect((_) {
      print('Disconnected from socket server');
    });

    _socket.onError((data) {
      print('Socket error: $data');
    });
  }

  void joinRoom(String roomId, String userId) {
    _socket.emit('create or join room', {'roomId': roomId, 'userId': userId});
  }

  void sendMessage(String roomId, String message, String userId) {
    _socket.emit('chat message', {'roomId': roomId, 'message': message, 'userId': userId});
  }

  void fetchMessages(String roomId) {
    _socket.emit('get messages', {'roomId': roomId});
  }

  void leaveRoom(String roomId, String userId) {
    _socket.emit('leave room', {'roomId': roomId, 'userId': userId});
  }

  IO.Socket get socket => _socket;

  void dispose() {
    _socket.disconnect();
  }
}
