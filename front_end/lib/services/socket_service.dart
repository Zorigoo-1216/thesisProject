// socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import './notification_overlay.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  late IO.Socket socket;

  SocketService._internal();

  void connect(String token, String userId) {
    socket = IO.io('http://192.168.56.1:8081', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      print('🔌 Socket connected');
      print('📡 Registering userId to socket: $userId');
      socket.emit('register', userId); // Register user
    });

    socket.on('notification', (data) {
      print('🔔 Notification received: $data');
      _showPopup(data);
    });

    socket.onDisconnect((_) => print('🔌 Socket disconnected'));
  }

  void _showPopup(Map<String, dynamic> data) {
    print(
      "🔥 Notification context: ${NotificationOverlay.navigatorKey.currentContext}",
    );
    NotificationOverlay.show(data['title'], data['message']);
  }

  void disconnect() {
    socket.disconnect();
  }
}
