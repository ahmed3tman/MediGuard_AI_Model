import 'package:flutter/foundation.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, this.isUser = true});
}

class ChatViewModel extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  void send(String text) {
    if (text.trim().isEmpty) return;
    _messages.add(ChatMessage(text: text.trim(), isUser: true));
    // Echo reply for demo
    _messages.add(ChatMessage(text: 'Echo: ${text.trim()}', isUser: false));
    notifyListeners();
  }

  void clear() {
    _messages.clear();
    notifyListeners();
  }
}
