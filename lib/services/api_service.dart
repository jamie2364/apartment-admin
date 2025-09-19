import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cleaning_app/models/inventory_item.dart';
import 'package:cleaning_app/models/cleaning_details.dart';

class ApiService {
  static const String _wordpressUrl = 'https://wildatlanticapartments.com';
  static const String _username = 'info@vivantestudios.com';
  static const String _applicationPassword = 'cf6A VVaH KXqh tmMA y3hK Czhr';

  static final String _basicAuth =
      'Basic ${base64Encode(utf8.encode('$_username:$_applicationPassword'))}';

  static final Map<String, String> _authHeaders = {
    'Content-Type': 'application/json',
    'Authorization': _basicAuth,
  };

  // --- Cleaning Status Endpoints ---

  static Future<Map<String, dynamic>> fetchCleaningStatuses() async {
    final uri = Uri.parse('$_wordpressUrl/wp-json/cleaning_status/v1/statuses');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch statuses from server.');
    }
  }

  static Future<List<CleaningDetails>> fetchCleaningDetails() async {
    final uri = Uri.parse('$_wordpressUrl/wp-json/cleaning_status/v1/details');
    final response = await http.get(
      uri,
      headers: {'Authorization': _basicAuth},
    );
    if (response.statusCode == 200) {
      final List<dynamic> decodedData = json.decode(response.body);
      return decodedData.map((data) => CleaningDetails.fromJson(data)).toList();
    } else {
      throw Exception(
        'Failed to load cleaning details: ${response.reasonPhrase}',
      );
    }
  }

  static Future<http.Response> updateCleaningStatus({
    required String apartmentId,
    required String statusToSend,
    required int rating,
    int? durationMinutes,
  }) {
    final uri = Uri.parse('$_wordpressUrl/wp-json/cleaning_status/v1/update');
    final Map<String, dynamic> requestBody = {
      'status': statusToSend,
      'apartment_id': apartmentId,
      'todays_rating': rating,
    };
    if (durationMinutes != null) {
      requestBody['duration_minutes'] = durationMinutes;
    }

    return http.post(
      uri,
      headers: _authHeaders,
      body: json.encode(requestBody),
    );
  }

  // --- Inventory Endpoints ---

  static Future<List<InventoryItem>> fetchInventoryItems() async {
    final uri = Uri.parse('$_wordpressUrl/wp-json/inventory/v1/items');
    final response = await http.get(
      uri,
      headers: {'Authorization': _basicAuth},
    );
    if (response.statusCode == 200) {
      final List<dynamic> decodedData = json.decode(response.body);
      return decodedData.map((item) => InventoryItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load inventory: ${response.reasonPhrase}');
    }
  }

  static Future<http.Response> updateStock(int itemId, String action) {
    final uri = Uri.parse('$_wordpressUrl/wp-json/inventory/v1/update-stock');
    return http.post(
      uri,
      headers: _authHeaders,
      body: json.encode({'item_id': itemId, 'action': action}),
    );
  }

  static Future<http.Response> updateImageUrl(int itemId, String imageUrl) {
    final uri = Uri.parse('$_wordpressUrl/wp-json/inventory/v1/update-image');
    return http.post(
      uri,
      headers: _authHeaders,
      body: json.encode({'item_id': itemId, 'image_url': imageUrl}),
    );
  }

  static Future<InventoryItem> addItem({
    required String name,
    required String url,
    required int stock,
    required String apartmentId, // ADDED
  }) async {
    final uri = Uri.parse('$_wordpressUrl/wp-json/inventory/v1/add-item');
    final response = await http.post(
      uri,
      headers: _authHeaders,
      body: json.encode({
        'name': name,
        'url': url,
        'stock': stock,
        'apartmentId': apartmentId, // ADDED
      }),
    );
    if (response.statusCode == 201) {
      return InventoryItem.fromJson(json.decode(response.body));
    } else {
      final responseBody = json.decode(response.body);
      final errorMessage = responseBody['message'] ?? 'Failed to add item';
      throw Exception(errorMessage);
    }
  }

  static Future<http.Response> deleteItem(int itemId) {
    final uri = Uri.parse('$_wordpressUrl/wp-json/inventory/v1/delete-item');
    return http.post(
      uri,
      headers: _authHeaders,
      body: json.encode({'item_id': itemId}),
    );
  }
}
