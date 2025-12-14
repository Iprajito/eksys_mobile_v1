import 'package:dio/dio.dart';
import 'package:eahmindonesia/models/master_model.dart';
import 'dart:convert';

class MasterController {
  final String baseUrl = 'https://erp.eahm-indonesia.co.id/api';
  Dio dio = Dio();

  // Master Supplier Start
  Future<SupplierModel?> getsuppliers(String token, String userid) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    try {
      final response = await dio.get('$baseUrl/master/getsuppliers/$userid', options: _options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return SupplierModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  // Master Pelanggan Start
  Future<PelangganModel?> getpelangganbyid(String token, String userid) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    try {
      final response = await dio.get('$baseUrl/master/getpelangganbyuserid/$userid', options: _options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return PelangganModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<ProdukModel?> getproduks(String token, String userid) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    try {
      final response = await dio.get('$baseUrl/master/getproduks', options: _options);
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

  Future<MetodeBayarBankModel?> getmetodebayarbank(String token, String userid) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    try {
      final response = await dio.get('$baseUrl/master/getmetodebayar/bank', options: _options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return MetodeBayarBankModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<MetodeBayarAgenModel?> getmetodebayaragen(String token, String userid) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    try {
      final response = await dio.get('$baseUrl/master/getmetodebayar/agen', options: _options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return MetodeBayarAgenModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<WilayahModel?> getwilayah(String token, String userid) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    try {
      final response = await dio.get('$baseUrl/master/getwilayah', options: _options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return WilayahModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<AnggotaModel?> getanggota(String token, String userid) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    try {
      final response = await dio.get('$baseUrl/master/getanggota/$userid', options: _options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return AnggotaModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
  // Master Supplier End
}