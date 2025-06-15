import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:final_project_ppb/models/menu.dart';

class MenuService {
  static const String baseUrl = 'https://fp-ppb.aryagading.com/api';

  // get paginated
  Future<MenuResponse> getMenus({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/menus?page=$page'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return MenuResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load menus: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching menus: $e');
    }
  }

  // get all
  Future<List<MenuItem>> getAllMenus({String? search}) async {
    try {
      String url = '$baseUrl/menus/without-pagination';
      if (search != null && search.isNotEmpty) {
        url += '?search=${Uri.encodeComponent(search)}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData is Map && jsonData.containsKey('data')) {
          final List<dynamic> menuList = jsonData['data'];
          return menuList.map((item) => MenuItem.fromJson(item)).toList();
        } else if (jsonData is List) {
          return jsonData.map((item) => MenuItem.fromJson(item)).toList();
        } else {
          throw Exception('Unexpected API response format');
        }
      } else {
        throw Exception('Failed to load menus: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching all menus: $e');
    }
  }
}
