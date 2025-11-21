import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/history_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HistoryService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // ! Get History data
  Future<List<HistoryModel>> getHistoryData(
      {int limit = 10, int page = 1}) async {
    final offset = (page - 1) * limit;
    final response = await http
        .get(Uri.parse('$baseUrl/history?limit=$limit&offset=$offset'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => HistoryModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load history data');
    }
  }
}
