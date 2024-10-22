import 'package:http/http.dart' as http;
import 'dart:convert';

class BroodstockMortalityService {
  final String apiUrl = 'http://127.0.0.1:8000/api/mortality';

  // Get all mortality
  Future<List<dynamic>> getAllMortality() async {
    var url = Uri.parse(apiUrl);
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        return jsonData;
      } else {
        throw Exception('Failed to load mortality');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }

  // Get mortality by id
  Future<dynamic> getMortalityById(int id) async {
    var url = Uri.parse('$apiUrl/$id');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        return jsonData;
      } else {
        throw Exception('Failed to load mortality');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }

  //create mortality
  Future<http.Response> createMortality(
      Map<String, dynamic> requestData) async {
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

  //update mortality
  Future<void> updateMortality(Map<String, dynamic> requestData, int id) async {
    var url = Uri.parse('$apiUrl/$id');
    try {
      var response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update mortality');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }

  //delete mortality
  Future<void> deleteMortality(int id) async {
    var url = Uri.parse('$apiUrl/$id');
    try {
      var response = await http.delete(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to delete mortality');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }
}
