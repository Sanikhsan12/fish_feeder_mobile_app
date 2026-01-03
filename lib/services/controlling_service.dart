import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ControllingService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await http.get(Uri.parse('$baseUrl/dashboard'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load dashboard');
  }

  Future<String> manualFeed(int amount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/feeder/manual'),
      body: json.encode({'amount_gram': amount}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return 'Feeding success';
    }
    return 'Feeding failed';
  }

  Future<String> manualUV(int durationSeconds) async {
    final response = await http.post(
      Uri.parse('$baseUrl/uv/manual'),
      body: json.encode({'duration_minutes': durationSeconds ~/ 60}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return 'UV started';
    }
    return 'UV failed';
  }

  Future<String> stopManualUV() async {
    final response = await http.post(Uri.parse('$baseUrl/uv/manual/stop'));
    if (response.statusCode == 200) {
      return 'Manual UV stopped';
    }
    return 'Stop UV failed';
  }

  Future<String> getLastFeed() async {
    final response = await http.get(Uri.parse('$baseUrl/feeder/last-feed'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['exists'] == true) {
        return '${data['day']} ${data['time']}';
      }
      return 'No feed info';
    }
    return 'Failed to get last feed';
  }

  Future<String> updateStock(int amount) async {
    final response = await http.put(
      Uri.parse('$baseUrl/stock'),
      body: json.encode({'amount_gram': amount}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return 'Stock berhasil diupdate';
    }
    return 'Gagal update stock';
  }
}
