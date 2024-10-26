import 'package:http/http.dart' as http;
import 'dart:convert';

class TopupService {
  final String baseUrl = 'http://127.0.0.1:8000/api/topups';

  //get all topups
  Future<List<dynamic>> getAllTopups() async {
    var url = Uri.parse(baseUrl);
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        return jsonData;
      } else {
        throw Exception('Failed to load topups');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }

  //get topup by id
  Future<dynamic> getTopupById(int id) async {
    var url = Uri.parse('$baseUrl/$id');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        return jsonData;
      } else {
        throw Exception('Failed to load topup');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }

  //create topup
  Future<dynamic> createTopup(Map<String, dynamic> requestData) async {
    var url = Uri.parse(baseUrl);
    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );
      // Map<String, String> stringData = requestData.map((key, value) => MapEntry(
      //       key,
      //       value?.toString() ?? '', // Convert null values to empty strings
      //     ));
      //var response = await http.post(url, body: stringData);
      return response;
    } catch (error) {
      // print(error);
      throw Exception('Failed to connect to API: $error');
    }
  }

  //update topup
  Future<dynamic> updateTopup(int id, Map<String, dynamic> requestData) async {
    var url = Uri.parse('$baseUrl/$id');
    try {
      var response = await http.put(url, body: requestData);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        return jsonData;
      } else {
        throw Exception('Failed to update topup');
      }
    } catch (error) {
      print('Error in Services : $error');
      throw Exception('Failed to connect to API: $error');
    }
  }

  //delete topup
  Future<dynamic> deleteTopup(int id) async {
    var url = Uri.parse('$baseUrl/$id');
    try {
      var response = await http.delete(url);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        return jsonData;
      } else {
        throw Exception('Failed to delete topup');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }
}
