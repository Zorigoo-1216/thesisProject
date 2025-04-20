import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job_model.dart';
import '../constant/api.dart';

class JobService {
  static Future<List<Job>> fetchMyJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${baseUrl}postedJobs'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List jobs = data['jobs'];
      return jobs.map((json) => Job.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load jobs');
    }
  }
}
