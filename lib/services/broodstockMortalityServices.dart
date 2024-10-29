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

  // Fetch mortalities based on department, division, tank, and date range
  Future<Map<String, dynamic>> fetchMortalities({
    int? departmentId,
    int? divisionId,
    int? tankId,
    required String dateFrom,
    required String dateTo,
  }) async {
    var url = Uri.parse('http://127.0.0.1:8000/api/mortality-topupDetails');

    try {
      // Construct the query parameters dynamically based on provided arguments
      Map<String, String> queryParams = {
        'date_from': dateFrom,
        'date_to': dateTo,
      };

      if (departmentId != null) {
        queryParams['department_id'] = departmentId.toString();
      }
      if (divisionId != null) {
        queryParams['division_id'] = divisionId.toString();
      }
      if (tankId != null) {
        queryParams['tank_id'] = tankId.toString();
      }

      // Build the final URL with query parameters
      var uri = Uri.parse('$url').replace(queryParameters: queryParams);

      // Perform the GET request
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        return jsonData; // This will return both the data and the totals
      } else if (response.statusCode == 404) {
        // Handle the case where no data is found
        return {'message': 'No mortality records found for the given criteria'};
      } else {
        throw Exception('Failed to fetch mortalities');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }

}
