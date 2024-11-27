import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gk_aqua/models/waterQuality.dart';

class WaterqualityServices {
  final String apiUrl = 'http://127.0.0.1:8000/api/water-quality-checks';

  //Get all water quality checks
  Future<List> fetchWaterQualityChecks() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => data).toList();
    } else {
      throw Exception('Failed to load water quality checks');
    }
  }

  //Get single water quality check by id
  Future<waterQualityModel> fetchWaterQualityCheck(int id) async {
    final response = await http.get(Uri.parse('$apiUrl/$id'));
    if (response.statusCode == 200) {
      return waterQualityModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load water quality check');
    }
  }

  //Create new water quality check
  Future<http.Response> createWaterQualityCheck(
      Map<String, dynamic> data) async {
    var url = Uri.parse(apiUrl);
    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to connect to API: $e');
    }
  }

  //delete water quality check
  Future<void> deleteWaterQualityCheck(int id) async {
    var url = Uri.parse('$apiUrl/$id');
    try {
      var response = await http.delete(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to delete water quality check');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }
}
