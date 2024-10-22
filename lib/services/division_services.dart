import 'package:gk_aqua/models/division.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DivisionServices {
  final String apiUrl = "http://127.0.0.1:8000/api/division";

  //get all divisions
  Future<List<DivisionModel>> fetchDivisions() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => DivisionModel.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load divisions');
    }
  }

  //get an division by id
  Future<dynamic> fetchDivisionById(int id) async {
    var url = Uri.parse('$apiUrl/$id');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        throw Exception('Failed to load division');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }

  //create a new division
  Future<http.Response> createDivision(Map<String, dynamic> requestData) async {
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

  //update an existing division
  Future<void> updateDivision(Map<String, dynamic> requestData, int id) async {
    var url = Uri.parse('$apiUrl/$id');
    try {
      var response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update division');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }

  //delete an existing division
  Future<void> deleteDivision(int id) async {
    var url = Uri.parse('$apiUrl/$id');
    try {
      var response = await http.delete(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to delete division');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }

  //find all divisions by department id
  Future<List<DivisionModel>> fetchDivisionsByDepartmentId(
      {required int id}) async {
    final response = await http
        .get(Uri.parse('http://127.0.0.1:8000/api/divisions/department/$id'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => DivisionModel.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load divisions');
    }
  }
}
