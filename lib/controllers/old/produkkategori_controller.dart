import 'package:eahmindonesia/models/old/produkkategori_model.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
// import 'package:arumdalu/services/localstorage_service.dart';

// class ProdukKategoriController {
//   final StorageService storageService;

//   ProdukKategoriController(this.storageService);

//   Future<ProdukKategori?> getProdukKategorFromStorage() async {
//     List<ProdukKategori> produkKategori = await storageService.getKategoriProduk();
//     print('Request Controller : Kategori');

//     if (produkKategori != null) {
//       List<ProdukKategori> dataMap = produkKategori.toList();
//       print(dataMap);
//       return parseProducts(jsonResponse);
//     } else {
//       return null;
//     }
//   }

//   List<ProdukKategori> parseProducts(List<dynamic> jsonList) {
//     return jsonList.map((json) => ProdukKategori.fromJson(json)).toList();
//   }
// }

class ProdukKategoriController {
  final String baseUrl = 'https://arumdalu.andatara.id/api';
  Dio dio = Dio();
  
  Future<ProdukKategoriModel?> fetchData(String token) async {
    late final Options _options =
      Options(headers: {
            "Content-Type": "application/json",
            "Authorization":
                "Bearer $token",
          });
    try {
      final response =
          await dio.get('$baseUrl/kategoris', options: _options);

      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return ProdukKategoriModel.fromJson(data);
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
