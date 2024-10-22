import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gk_aqua/models/waterParameter.dart';

class WaterparameterServices {
  final String apiUrl = 'http://127.0.0.1:8000/api/water-parameters';

  //Get all water parameters
  Future<List<waterParameterModel>> fetchWaterParameters() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((data) => waterParameterModel.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to load water parameters');
    }
  }

  //create new water parameter
  Future<http.Response> createWaterParameter(
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

  //update water parameter by id
  Future<void> updateWaterParameter(waterParameterModel waterParameter) async {
    var url = Uri.parse('$apiUrl/${waterParameter.id}');

    // Create request data from the waterParameter object
    Map<String, dynamic> requestData = {
      'parameter_code': waterParameter.parameter_code,
      'parameter_name': waterParameter.parameter_name,
      'unit_id': waterParameter.unit_id,
      'notes': waterParameter.notes ?? '',
      'start_date': waterParameter.start_date ?? '',
      'end_date': waterParameter.end_date ?? '',
    };

    // Send PUT request to update the waterParameter
    var response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update water parameter');
    }
  }

  //delete water parameter by id
  Future<void> deleteWaterParameter(int id) async {
    var url = Uri.parse('$apiUrl/$id');

    // Send DELETE request to delete the waterParameter
    var response = await http.delete(url);

    if (response.statusCode != 204) {
      throw Exception('Failed to delete water parameter');
    }
  }
}
