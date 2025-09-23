import 'package:flutter/foundation.dart';
import '../services/chatbot_api_service.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart'; // مهم

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, this.isUser = true});
}

class ChatViewModel extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  // ---------------- Text Message ----------------
  Future<void> send(String text, {required String patientName}) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(text: text.trim(), isUser: true));
    notifyListeners();

    try {
      final botReply = await ChatbotApiService.sendChat(
        text.trim(),
        patientName: patientName,
      );
      _messages.add(ChatMessage(text: botReply, isUser: false));
    } catch (e) {
      _messages.add(ChatMessage(text: "⚠️ Error sending message: $e", isUser: false));
    }

    notifyListeners();
  }

  // ---------------- Audio Message ----------------
  Future<void> sendAudio(String filePath, {required String patientName}) async {
    // حفظ الصوت في temporary directory
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/voice_message.aac');

    try {
      final originalFile = File(filePath);

      // تأكد إن الملف موجود
      if (!originalFile.existsSync()) {
        debugPrint("❌ File does not exist at $filePath");
        _messages.add(ChatMessage(text: "⚠️ Audio file not found", isUser: true));
        return;
      }

      // انسخ الملف للـ temp directory
      await originalFile.copy(tempFile.path);

      _messages.add(ChatMessage(text: '[Voice message sent]', isUser: true));
      notifyListeners();

      // اقرأ البيانات من temp file
      final bytes = await tempFile.readAsBytes();
      final base64Audio = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('http://192.168.1.8:5000/chat-audio'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'audio_base64': base64Audio,
          'patient_id': patientName,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['reply'] ?? "No reply from server";
        _messages.add(ChatMessage(text: reply, isUser: false));
      } else {
        _messages.add(ChatMessage(
            text: "⚠️ Error sending audio: ${response.statusCode}", isUser: false));
      }
    } catch (e) {
      _messages.add(ChatMessage(text: "⚠️ Audio processing error: $e", isUser: false));
    }

    notifyListeners();
  }

  // ---------------- Clear Messages ----------------
  void clear() {
    _messages.clear();
    notifyListeners();
  }
}
