import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/schedule_model.dart';

class ScheduleService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // ! Feeder Methods
  Future<List<FeederScheduleModel>> getFeederSchedules() async {
    final response = await http
        .get(Uri.parse('$baseUrl/feeder/schedules?page=1&page_size=100'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List)
          .map((e) => FeederScheduleModel.fromJson(e))
          .toList();
    }
    throw Exception('Gagal mengambil jadwal Feeder');
  }

  Future<void> createFeederSchedule(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/feeder/schedules'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode != 201)
      throw Exception('Gagal membuat jadwal Feeder');
  }

  Future<void> updateFeederSchedule(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/feeder/schedules/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode != 200)
      throw Exception('Gagal update jadwal Feeder');
  }

  Future<void> deleteFeederSchedule(int id) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/feeder/schedules/$id'));
    if (response.statusCode != 200)
      throw Exception('Gagal menghapus jadwal Feeder');
  }

  // ! UV Methods
  Future<List<UVScheduleModel>> getUVSchedules() async {
    final response =
        await http.get(Uri.parse('$baseUrl/uv/schedules?page=1&page_size=100'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List)
          .map((e) => UVScheduleModel.fromJson(e))
          .toList();
    }
    throw Exception('Gagal mengambil jadwal UV');
  }

  Future<void> createUVSchedule(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/uv/schedules'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode != 201) throw Exception('Gagal membuat jadwal UV');
  }

  Future<void> updateUVSchedule(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/uv/schedules/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode != 200) throw Exception('Gagal update jadwal UV');
  }

  Future<void> deleteUVSchedule(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/uv/schedules/$id'));
    if (response.statusCode != 200)
      throw Exception('Gagal menghapus jadwal UV');
  }
}
