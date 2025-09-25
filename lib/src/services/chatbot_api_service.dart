import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';

class ChatbotApiService {
  static final String baseUrl = ApiConfig.baseUrl;

  static Future<String> sendChat(String message, {String patientName = "unknown"}) async {
    final url = Uri.parse("$baseUrl/chat");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": message,
          "patient_id": patientName,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["reply"] ?? "⚠️ No reply from bot";
      } else {
        return "⚠️ Server error: ${response.statusCode}";
      }
    } catch (e) {
      return "⚠️ Error: $e";
    }
  }
}
