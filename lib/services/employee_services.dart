import 'package:http/http.dart' as http;
import 'dart:convert';

class EmployeeServices {
  final String apiUrl = 'http://localhost:8000/api/employee';

  //get all employees
  Future<List<dynamic>> fetchEmployees() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => data).toList();
    } else {
      throw Exception('Failed to load employees');
    }
  }

  //get employee by id
  Future<dynamic> fetchEmployeeById(int id) async {
    var url = Uri.parse('$apiUrl/$id');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        throw Exception('Failed to load employee');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }

  //create employee
  Future<http.Response> createEmployee(Map<String, dynamic> requestData) async {
    var url = Uri.parse(apiUrl);
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

  //update employee by id
  Future<void> updateEmployee(Map<String, dynamic> requestData, int id) async {
    var url = Uri.parse('$apiUrl/$id');
    try {
      var response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update employee');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }

  //delete employee by id
  Future<void> deleteEmployee(int id) async {
    var url = Uri.parse('$apiUrl/$id');
    try {
      var response = await http.delete(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to delete employee');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }
}
