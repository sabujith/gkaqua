import 'dart:convert'; // Import the JSON package
import 'package:http/http.dart' as http; // Import the HTTP package
import 'package:gk_aqua/models/unit_model.dart'; // Import the UnitModel class

class UnitService {
  final String apiUrl = 'http://127.0.0.1:8000/api/unit';

  // Get all units
  Future<List<UnitModel>> fetchUnits() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => UnitModel.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load units');
    }
  }

  //create a new unit
  Future<http.Response> createUnit(Map<String, String> requestData) async {
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

  //update a unit by id
  Future<void> updateUnit(UnitModel unit) async {
    var url = Uri.parse('$apiUrl/${unit.id}');
    // Create request data from the unit object
    Map<String, String> requestData = {
      'unit_code': unit.unit_code,
      'unit_name': unit.unit_name,
      'note': unit.notes ?? '',
      'start_date': unit.start_date ?? '',
      'end_date': unit.end_date ?? '',
    };
    // Send PUT request to update the unit
    var response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestData),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update unit');
    }
  }

  //delete a unit by id
  Future<void> deleteUnit(int id) async {
    final url = Uri.parse('$apiUrl/$id');
    final response = await http.delete(url);
    if (response.statusCode != 204) {
      throw Exception('Failed to delete unit');
    }
  }
}
