import 'package:http/http.dart' as http;
import 'dart:convert';

class LarvaeCollectionService {
  static const apiUrl = 'http://127.0.0.1:8000/api/larva-collection-tanks';

  //get all larva collection tanks
  Future<List<dynamic>> fetchLarvaeCollectionTanks() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => data).toList();
    } else {
      throw Exception('Failed to load larva collection tanks');
    }
  }

  //get larva collection tank by id
  Future<dynamic> fetchLarvaeCollectionTankById(int id) async {
    var url = Uri.parse('$apiUrl/$id');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        throw Exception('Failed to load larva collection tank');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }

  //create larva collection tank
  Future<http.Response> createLarvaeCollection(
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

  //update larva collection tank
  Future<void> updateLarvaeCollectionTank(
      Map<String, dynamic> requestData, int id) async {
    var url = Uri.parse('$apiUrl/$id');
    try {
      var response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update larva collection tank');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }

  //delete larva collection tank by id
  Future<void> deleteLarvaeCollectionTank(int id) async {
    var url = Uri.parse('$apiUrl/$id');
    try {
      var response = await http.delete(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to delete larva collection tank');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }
}
