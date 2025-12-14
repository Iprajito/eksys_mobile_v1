import 'package:eahmindonesia/models/old/produk_model.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class ProdukController {
  final String baseUrl = 'https://arumdalu.andatara.id/api';
  Dio dio = Dio();

  Future<ProdukModel?> fetchData(
      String token, String kategoriId, String menu) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    try {
      final response;
      if (menu == '') {
        response = await dio.get('$baseUrl/menusbykategori/$kategoriId',
            options: _options);
      } else {
        response =
            await dio.get('$baseUrl/menusbymenu/$menu', options: _options);
      }

      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return ProdukModel.fromJson(data);
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
