import 'dart:convert';

import 'package:final_project_ppb/models/chat.dart';
import 'package:final_project_ppb/models/preferensi.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl =
      'https://fp-ppb.aryagading.com'; // Replace with your API URL

  static Future<PreferensiResponse?> postPreferensi(
    PreferensiRequest preferensiRequest,
  ) async {
    try {
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      print(preferensiRequest.toJson());

      final response = await http.post(
        Uri.parse('$_baseUrl/api/preferences'),
        headers: headers,
        body: jsonEncode(preferensiRequest.toJson()),
      );

      if (response.statusCode == 200) {
        return PreferensiResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to post preferensi: $e');
    }
  }

  static Future<String> askQuestion(ChatRequest request) async {
    try {
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/api/ask'),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final answerText =
            responseData['response']['candidates'][0]['content']['parts'][0]['text'];
        return answerText;
      } else {
        throw Exception('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to ask question: $e');
    }
  }

  static Future<String> deletePreferensi(String userId) async {
    try {
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final response = await http.delete(
        Uri.parse('$_baseUrl/api/preference/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return 'Preferensi deleted successfully';
      } else {
        throw Exception('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete preferensi: $e');
    }
  }
}
