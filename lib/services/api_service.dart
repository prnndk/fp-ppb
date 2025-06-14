import 'dart:convert';

import 'package:final_project_ppb/models/preferensi.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl =
      'http://10.21.85.121:8000'; // Replace with your API URL

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
        print(response.body);
        throw Exception('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to post preferensi: $e');
    }
  }
}
