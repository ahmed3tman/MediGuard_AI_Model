import 'package:flutter/foundation.dart';
import '../services/chatbot_api_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, this.isUser = true});
}

class ChatViewModel extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  // دلوقتي send بياخد patientName مش patientId ثابت
  Future<void> send(String text, {required String patientName}) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(text: text.trim(), isUser: true));
    notifyListeners();

    final botReply = await ChatbotApiService.sendChat(
      text.trim(),
      patientName: patientName,
    );

    _messages.add(ChatMessage(text: botReply, isUser: false));
    notifyListeners();
  }

  /// Send an audio file path as a voice message. Currently this adds a user
  /// message indicating a voice message was sent and asks the bot service
  /// to process it as a placeholder.
  Future<void> sendAudio(String filePath, {required String patientName}) async {
    if (filePath.trim().isEmpty) return;

    _messages.add(
      ChatMessage(text: '[Voice message sent] $filePath', isUser: true),
    );
    notifyListeners();

    // Placeholder: send a textual notice to the chatbot service; replace
    // this with a real file upload endpoint if available.
    final botReply = await ChatbotApiService.sendChat(
      '[Voice message received]',
      patientName: patientName,
    );

    _messages.add(ChatMessage(text: botReply, isUser: false));
    notifyListeners();
  }

  void clear() {
    _messages.clear();
    notifyListeners();
  }
}
