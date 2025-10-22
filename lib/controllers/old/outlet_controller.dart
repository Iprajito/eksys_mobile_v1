import 'package:eahmindonesia/models/old/outlet_model.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
// import 'package:arumdalu/services/localstorage_service.dart';

class OutletController {
  final String baseUrl = 'https://arumdalu.andatara.id/api';
  Dio dio = Dio();
  
  Future<OutletModel?> fetchData(String token) async {

    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    
    try {
      final response = await dio.get('$baseUrl/outlets', options: _options);

      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return OutletModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<OutletModel?> getAllOutlets(String token) async {

    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    
    try {
      final response = await dio.get('$baseUrl/getalloutlets', options: _options);

      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return OutletModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}
