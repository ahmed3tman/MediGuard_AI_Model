import 'dart:convert';
import 'package:http/http.dart' as http;

class IntegratedApiService {
  // final String baseUrl = "http://10.0.2.2:5000";
  final String baseUrl = "http://192.168.1.8:5000";


  Future<Map<String, dynamic>> analyzePatient(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse("$baseUrl/integrated-analysis"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("API Error: ${res.body}");
    }
  }
}