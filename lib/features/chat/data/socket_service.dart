import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../../core/config/api_config.dart';
import '../../auth/data/auth_service.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  io.Socket? _socket;

  factory SocketService() {
    return _instance;
  }

  SocketService._internal();

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {
    if (_socket != null && _socket!.connected) return;

    final token = await AuthService.getToken();
    if (token == null) {
      debugPrint('❌ Cannot connect to socket: No token');
      return;
    }

    /* 
       Note: ApiConfig.baseUrl usually includes /api, e.g., http://localhost:3000/api
       Socket.io needs the base domain, e.g., http://localhost:3000
    */
    final socketUrl = ApiConfig.baseUrl.replaceAll('/api', '');

    try {
      _socket = io.io(socketUrl, io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setQuery({'token': token})
          .build());

      _socket!.connect();

      _socket!.onConnect((_) {
        debugPrint('✅ Socket Connected');
      });

      _socket!.onDisconnect((_) {
        debugPrint('❌ Socket Disconnected');
      });

      _socket!.onError((data) {
        debugPrint('⚠️ Socket Error: $data');
      });

    } catch (e) {
      debugPrint('⚠️ Socket Connection Failed: $e');
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void joinChat(String chatId) {
    if (_socket == null) return;
    _socket!.emit('join_chat', chatId);
  }

  void leaveChat(String chatId) {
    if (_socket == null) return;
    _socket!.emit('leave_chat', chatId);
  }

  void sendMessage(String chatId, String text, String recipientId, {bool encrypted = false}) {
    if (_socket == null) return;
    _socket!.emit('send_message', {
      'chatId': chatId,
      'text': text,
      'recipientId': recipientId,
      'encrypted': encrypted
    });
  }

  void onMessageReceived(Function(dynamic) callback) {
    _socket?.on('receive_message', callback);
  }
  
  void offMessageReceived() {
    _socket?.off('receive_message');
  }
}
