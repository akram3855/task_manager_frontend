import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:taskmanage_frontend/models/task.dart';

class ApiService {
  final String _baseUrl = dotenv.env['API_BASE_URL']!;
  final String _apiKey = dotenv.env['API_KEY']!;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Api-Key $_apiKey', 
  };

  Future<List<Task>> fetchTasks({
    int page = 1,
    String? status,
    String? priority,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page.toString(),
      'status': status,
      'priority': priority,
      'search': search,
      'ordering': sortOrder == 'desc' ? '-$sortBy' : sortBy,
    };
    queryParams.removeWhere((key, value) => value == null);

    final uri = Uri.parse('${_baseUrl}/tasks/').replace(queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())));
    
  
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      print('ERROR: Status Code: ${response.statusCode}');
      print('ERROR: Response Body: ${response.body}');
      throw Exception('Failed to load tasks');
    }
  }

  Future<Task> createTask(Task task) async {
    final response = await http.post(
      Uri.parse('${_baseUrl}/tasks/'),
      headers: _headers,
      body: json.encode(task.toJson()),
    );
    if (response.statusCode == 201) {
      return Task.fromJson(json.decode(response.body));
    } else {
      print('ERROR: Status Code: ${response.statusCode}');
      print('ERROR: Response Body: ${response.body}');
      throw Exception('Failed to create task');
    }
  }

  Future<Task> updateTask(Task task) async {
    final response = await http.put(
      Uri.parse('${_baseUrl}/tasks/${task.id}/'),
      headers: _headers,
      body: json.encode(task.toJson()),
    );
    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      print('ERROR: Status Code: ${response.statusCode}');
      print('ERROR: Response Body: ${response.body}');
      throw Exception('Failed to update task');
    }
  }

  Future<void> deleteTask(int id) async {
    final response = await http.delete(
      Uri.parse('${_baseUrl}/tasks/$id/'),
      headers: _headers,
    );
    if (response.statusCode != 204) {
      print('ERROR: Status Code: ${response.statusCode}');
      print('ERROR: Response Body: ${response.body}');
      throw Exception('Failed to delete task');
    }
  }
}
