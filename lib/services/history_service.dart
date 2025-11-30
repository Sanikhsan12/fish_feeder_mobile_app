import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/history_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HistoryService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // ! Get History data
  Future<Map<String, dynamic>> getHistoryData({
    int page = 1,
    int pageSize = 10,
    String? month,
    String? year,
  }) async {
    var url = '$baseUrl/history?page=$page&page_size=$pageSize';
    if (month != null) url += '&month=$month';
    if (year != null) url += '&year=$year';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      List<dynamic> data = jsonBody['data'];
      final pagination = jsonBody['pagination'];
      return {
        'data': data.map((item) => HistoryModel.fromJson(item)).toList(),
        'pagination': pagination,
      };
    } else {
      throw Exception('Failed to load history data');
    }
  }

  Future<List<HistoryModel>> getAllHistoryData() async {
    final response =
        await http.get(Uri.parse('$baseUrl/history?page=1&page_size=2000'));
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      List<dynamic> data = jsonBody['data'];
      return data.map((item) => HistoryModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load history data');
    }
  }
}
