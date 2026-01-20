import '../../../../core/services/api_service.dart';
import '../../auth/data/auth_service.dart';
import 'models/chat_model.dart';
import 'models/message_model.dart';

class ChatService {
  final ApiService _apiService = ApiService();

  Future<String?> _getToken() async {
    return await AuthService.getToken();
  }

  Future<List<ChatModel>> getChats() async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.get('/chats', token: token);
    
    if (response['success'] == true) {
      final List<dynamic> data = response['data'];
      return data.map((json) => ChatModel.fromJson(json)).toList();
    } else {
      throw Exception(response['message'] ?? 'Failed to load chats');
    }
  }

  Future<ChatModel> initiateChat(String recipientId, {String? jobId}) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final body = {'recipientId': recipientId};
    if (jobId != null) {
      body['jobId'] = jobId;
    }

    final response = await _apiService.post(
      '/chats/initiate',
      body,
      token: token,
    );

    if (response['success'] == true) {
      return ChatModel.fromJson(response['data']);
    } else {
      throw Exception(response['message'] ?? 'Failed to initiate chat');
    }
  }

  Future<MessageModel> sendMessage(String chatId, String text) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.post(
      '/chats/message',
      {'chatId': chatId, 'text': text},
      token: token,
    );

    if (response['success'] == true) {
       return MessageModel.fromJson(response['data']);
    } else {
      throw Exception(response['message'] ?? 'Failed to send message');
    }
  }

  Future<List<MessageModel>> getMessages(String chatId) async {
    final token = await _getToken();
     if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.get('/chats/$chatId/messages', token: token);

    if (response['success'] == true) {
      final List<dynamic> data = response['data'];
      return data.map((json) => MessageModel.fromJson(json)).toList();
    } else {
      throw Exception(response['message'] ?? 'Failed to load messages');
    }
  }
}
