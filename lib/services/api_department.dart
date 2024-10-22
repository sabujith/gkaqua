// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/department.dart';

class DepartmentService {
  final String apiUrl = 'http://127.0.0.1:8000/api/department';

  // Fetch departments from API
  Future<List<Department>> fetchDepartments() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Department.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load departments');
    }
  }

  //Create a new department
  Future<http.Response> createDepartment(
      Map<String, String> requestData) async {
    var url = Uri.parse('http://127.0.0.1:8000/api/department');
    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );
      return response;
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }

  //Update department by ID
  // Update department (define this method)
  Future<void> updateDepartment(Department department) async {
    var url = Uri.parse(
        '$apiUrl/${department.id}'); // Assuming department ID is used in URL

    // Create request data from the department object
    Map<String, String> requestData = {
      'department_code': department.departmentCode,
      'department_name': department.departmentName,
      'note': department.notes ?? '',
      'start_date': department.startDate ?? '',
      'end_date': department.endDate ?? '',
    };

    // Send PUT request to update the department
    var response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update department');
    }
  }

  // Delete department by ID
  Future<void> deleteDepartment(int id) async {
    final url = Uri.parse('$apiUrl/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete department');
    }
  }

  //Get department by name
  Future<Department> getDepartmentByName(String name) async {
    final url = Uri.parse('http://127.0.0.1:8000/api/departments/$name');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Department.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get department');
    }
  }
}
