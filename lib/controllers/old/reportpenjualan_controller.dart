import 'package:eahmindonesia/models/old/reportpenjualan_model.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class ReportPenjualanController {
  final String baseUrl = 'https://arumdalu.andatara.id/api';
  Dio dio = Dio();
  Future<ReportPenjualanModel?> getReportPenjualan(
      String token, String outletId, String periode) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    final body = jsonEncode({'periode': periode, 'outletId': outletId});
    print('Controller');
    try {
      final response = await dio.post('$baseUrl/reportpenjualan',
          options: _options, data: body);
      if (response.statusCode == 200) {
        final data = json.decode(response.toString());
        return ReportPenjualanModel.fromJson(data);
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
