import 'package:Eksys/models/old/karyawan_model.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
// import 'package:arumdalu/services/localstorage_service.dart';

class KaryawanController {
  final String baseUrl = 'https://arumdalu.andatara.id/api';
  Dio dio = Dio();
  
  Future<KaryawanModel?> fetchData(String token, String uid) async {

    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    
    try {
      final response = await dio.get('$baseUrl/karyawan/$uid', options: _options);

      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return KaryawanModel.fromJson(data);
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
