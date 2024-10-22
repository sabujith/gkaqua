import 'package:http/http.dart' as http;
import 'dart:convert';

class HatcheryMortalityService {
  final String apiUrl = 'http://127.0.0.1:8000/api/hatchery-mortalities';

  //Get all Hatchery Mortality
  Future<List<dynamic>> getAllMortality() async {
    var url = Uri.parse(apiUrl);
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        return jsonData;
      } else {
        throw Exception('Failed to load Hatchery Mortality');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }

  //Get Hatchery Mortality by ID
  Future<dynamic> getMortalityById(int id) async {
    var url = Uri.parse('$apiUrl/$id');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        return jsonData;
      } else {
        throw Exception('Failed to load Hatchery Mortality');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }

  //Create Hatchery Mortality
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

  //Update Hatchery Mortality
  Future<void> updateMortality(Map<String, dynamic> requestData, int id) async {
    var url = Uri.parse('$apiUrl/$id');
    try {
      var response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update Hatchery Mortality');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }

  //Delete Hatchery Mortality
  Future<void> deleteMortality(int id) async {
    var url = Uri.parse('$apiUrl/$id');
    try {
      var response = await http.delete(url);
      if (response.statusCode != 204) {
        throw Exception('Failed to delete Hatchery Mortality');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }
}
