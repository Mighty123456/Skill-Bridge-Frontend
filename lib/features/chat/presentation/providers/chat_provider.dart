import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/chat_service.dart';
import '../../data/socket_service.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/message_model.dart';

// Services Providers
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService();
});

// 1️⃣ CHAT LIST PROVIDER
class ChatListNotifier extends AsyncNotifier<List<ChatModel>> {
  late final ChatService _chatService;

  @override
  Future<List<ChatModel>> build() async {
    _chatService = ref.read(chatServiceProvider);
    return _fetchChats();
  }

  Future<List<ChatModel>> _fetchChats() async {
    return await _chatService.getChats();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchChats());
  }

  void addChat(ChatModel chat) {
    state.whenData((currentState) {
      state = AsyncValue.data([chat, ...currentState]);
    });
  }
}

final chatListProvider = AsyncNotifierProvider<ChatListNotifier, List<ChatModel>>(() {
  return ChatListNotifier();
});

// 2️⃣ ACTIVE CHAT ID PROVIDER (For Scoping)
// This will be overridden in the UI via ProviderScope
final currentChatIdProvider = Provider<String>((ref) {
  throw UnimplementedError('currentChatIdProvider must be overridden');
});

// 3️⃣ ACTIVE CHAT MESSAGES PROVIDER
class ActiveChatState {
  final List<MessageModel> messages;
  final bool isLoading;
  final String? error;

  ActiveChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ActiveChatState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ActiveChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Standard AsyncNotifier relying on scoped/watched ID
class ActiveChatNotifier extends AsyncNotifier<ActiveChatState> {
  late final ChatService _chatService;
  late final SocketService _socketService;
  late final String _chatId;

  @override
  Future<ActiveChatState> build() async {
    // This allows the notifier to be rebuilt if the ID changes
    _chatId = ref.watch(currentChatIdProvider); 
    
    _chatService = ref.read(chatServiceProvider);
    _socketService = ref.read(socketServiceProvider);

    // Setup Socket Listeners
    _setupSocketListeners();
    
    // Cleanup on dispose
    ref.onDispose(() {
      _socketService.leaveChat(_chatId);
      _socketService.offMessageReceived();
    });

    return _loadMessages();
  }
// ... (rest of class methods are same, implied if not replacing whole block)
// I will replace the class declaration line and provider definition line only if efficient. 
// But replace_file_content needs contiguous block. 
// I'll replace the class declaration line.
// And the provider definition line.


  Future<ActiveChatState> _loadMessages() async {
    try {
      final messages = await _chatService.getMessages(_chatId);
      
      // Connect & Join Room (Side effect)
      await _socketService.connect();
      _socketService.joinChat(_chatId);
      
      return ActiveChatState(messages: messages);
    } catch (e) {
      // Return state with error info
      return ActiveChatState(error: e.toString()); 
    }
  }

  void _setupSocketListeners() {
    _socketService.onMessageReceived((data) {
       if (data['chatId'] == _chatId) {
         final newMessage = MessageModel.fromJson(data);
         addMessage(newMessage); 
       }
    });
  }

  void addMessage(MessageModel message) {
    if (state.hasValue) {
       final currentState = state.value!;
       if (!currentState.messages.any((m) => m.id == message.id)) {
          final newState = currentState.copyWith(
             messages: [...currentState.messages, message]
          );
          state = AsyncData(newState);
       }
    }
  }

  Future<void> sendMessage(String text, String recipientId) async {
    try {
      final sentMessage = await _chatService.sendMessage(_chatId, text);
      addMessage(sentMessage);
      _socketService.sendMessage(_chatId, text, recipientId);
    } catch (e) {
       if (state.hasValue) {
          state = AsyncData(state.value!.copyWith(error: "Failed to send: $e"));
       }
    }
  }
}

// The global provider (must be scoped)
final activeChatProvider = AsyncNotifierProvider<ActiveChatNotifier, ActiveChatState>(() {
  return ActiveChatNotifier();
});
