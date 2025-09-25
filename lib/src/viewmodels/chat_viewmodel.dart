import 'package:flutter/foundation.dart';
import '../services/chatbot_api_service.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../services//api_config.dart';
import 'package:audioplayers/audioplayers.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String? audioPath;
  final bool hasAudio;

  ChatMessage({
    required this.text,
    this.isUser = true,
    this.audioPath,
    this.hasAudio = false,
  });
}

class ChatViewModel extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  String? _currentPath;

  bool get isPlaying => _isPlaying;
  String? get currentPath => _currentPath;

  // ---------------- Text Message ----------------
  Future<void> send(String text, {required String patientName}) async {
    if (text.trim().isEmpty) return;
    _messages.add(ChatMessage(text: text.trim(), isUser: true));
    notifyListeners();

    try {
      final botReply = await ChatbotApiService.sendChat(text.trim(),
          patientName: patientName);
      _messages.add(ChatMessage(text: botReply, isUser: false));
    } catch (e) {
      _messages.add(ChatMessage(
          text: "⚠️ Error sending message: $e", isUser: false));
    }
    notifyListeners();
  }

  // ---------------- Audio Message ----------------
  Future<void> sendAudio(String filePath, {required String patientName}) async {
    final originalFile = File(filePath);
    if (!originalFile.existsSync()) {
      _messages.add(ChatMessage(text: "⚠️ Audio file not found", isUser: true));
      notifyListeners();
      return;
    }

    _messages.add(ChatMessage(text: "🎤 Voice message", isUser: true));
    notifyListeners();

    try {
      final bytes = await originalFile.readAsBytes();
      final base64Audio = base64Encode(bytes);

      // ⏳ أضف مؤقت "Bot typing"
      final typingMsg = ChatMessage(text: "Bot is typing…", isUser: false);
      _messages.add(typingMsg);
      notifyListeners();

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/chat-audio"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'audio_base64': base64Audio,
          'patient_id': patientName,
          'file_ext': 'wav',
        }),
      );

      _messages.remove(typingMsg);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // transcript → ممكن تأخر عرضه سنة صغيرة
        if (data['transcript'] != null) {
          _messages.add(ChatMessage(text: data['transcript'], isUser: true));
          await Future.delayed(const Duration(milliseconds: 400));
        }

        // reply + reply audio في Bubble واحدة
        if (data['reply'] != null) {
          String? botAudioPath;
          if (data['reply_audio'] != null) {
            final audioBytes = base64Decode(data['reply_audio']);
            final tempFile = File(
                '${Directory.systemTemp.path}/bot_reply_${DateTime.now().millisecondsSinceEpoch}.mp3');
            await tempFile.writeAsBytes(audioBytes);
            botAudioPath = tempFile.path;
          }

          _messages.add(ChatMessage(
            text: data['reply'],
            isUser: false,
            audioPath: botAudioPath,
            hasAudio: botAudioPath != null,
          ));
        }
      } else {
        _messages.add(ChatMessage(text: "⚠️ Error: ${response.statusCode}", isUser: false));
      }
    } catch (e) {
      _messages.add(ChatMessage(text: "⚠️ Audio processing error: $e", isUser: false));
    }
    notifyListeners();
  }
  
  // ---------------- Audio Controls ----------------
  Future<void> playAudio(String path) async {
    try {
      await _player.stop();
      await _player.play(DeviceFileSource(path));
      _isPlaying = true;
      _currentPath = path;
      notifyListeners();

      _player.onPlayerComplete.listen((_) {
        _isPlaying = false;
        _currentPath = null;
        notifyListeners();
      });
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  Future<void> stopAudio() async {
    await _player.stop();
    _isPlaying = false;
    _currentPath = null;
    notifyListeners();
  }

  // ---------------- Clear Messages ----------------
  void clear() {
    _messages.clear();
    notifyListeners();
  }
}