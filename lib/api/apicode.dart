// user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:curdapi/model/model.dart';

class UserService {
  final String baseUrl = 'https://crudnew-2wb5.onrender.com/api/user';

  // Fetch all users
  Future<List<curd>> fetchUsers() async {
    final url = Uri.parse('$baseUrl/getAllUsers');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as List;
      return body.map((json) => curd.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  // Create a new user
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    final url = Uri.parse('$baseUrl/create');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create user');
    }
  }

  // Update an existing user
  Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> updatedData) async {
    final url = Uri.parse('$baseUrl/update/$userId');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedData),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Succesfully complite');
    }
  }

  // Delete a user by ID
  Future<void> deleteUser(String userId) async {
    final url = Uri.parse('$baseUrl/delete/$userId');
    final response = await http.delete(url);
    if (response.statusCode != 200) {
      throw Exception('Succesfully complite');
    }
  }
}
