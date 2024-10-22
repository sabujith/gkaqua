import 'package:gk_aqua/models/tank.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TankService {
  static const apiUrl = 'http://127.0.0.1:8000/api/tank';

  //get all tanks
  Future<List<TankModel>> fetchTanks() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => TankModel.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load tanks');
    }
  }

  //get tank by id
  Future<dynamic> fetchTankById(int id) async {
    var url = Uri.parse('$apiUrl/$id');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        throw Exception('Failed to load tank');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }

  //create tank
  Future<http.Response> createTank(Map<String, dynamic> requestData) async {
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

  //update tank
  Future<void> updateTank(Map<String, dynamic> requestData, int id) async {
    var url = Uri.parse('$apiUrl/$id');
    try {
      var response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update tank');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }

  //delete tank
  Future<void> deleteTank(int id) async {
    var url = Uri.parse('$apiUrl/$id');
    try {
      var response = await http.delete(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to delete tank');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }

  //get all tanks by division id
  Future<List<TankModel>> fetchTanksByDivisionId({required int id}) async {
    var url = Uri.parse('http://127.0.0.1:8000/api/tanks/division/$id');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        return jsonData
            .map<TankModel>((json) => TankModel.fromJson(json))
            .toList();
      } else {
        throw 'No Tanks found under this Division';
      }
    } catch (error) {
      throw error;
    }
  }
}
