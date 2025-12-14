import 'package:eahmindonesia/models/dashboard_model.dart';
import 'package:eahmindonesia/models/old/inventory_model.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class DashboardController {
  final String baseUrl = 'https://arumdalu.andatara.id/api';
  Dio dio = Dio();
  Future<DashboardModel?> getDashboard(String token, String outletId) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    try {
      final response = await dio.get(
          '$baseUrl/dashboard/$outletId',
          options: _options);
      if (response.statusCode == 200) {
        final data = json.decode(response.toString());
        return DashboardModel.fromJson(data);
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
