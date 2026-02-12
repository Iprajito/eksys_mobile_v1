import 'package:dio/dio.dart';
import 'package:Eksys/models/master_model.dart';
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
      final response = await dio.get('$baseUrl/master/getsuppliers/$userid',
          options: _options);
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
      final response = await dio.get(
          '$baseUrl/master/getpelangganbyuserid/$userid',
          options: _options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        print(PelangganModel.fromJson(data));
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

  Future<PelangganAlamatModel?> getpelangganalamatbyuserid(
      String token, String userid) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    try {
      final response = await dio.get(
          '$baseUrl/master/getpelangganalamatbyuserid/$userid',
          options: _options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        print(PelangganAlamatModel.fromJson(data));
        return PelangganAlamatModel.fromJson(data);
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
      final response =
          await dio.get('$baseUrl/master/getproduks', options: _options);
      print(response.data);
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

  Future<MetodeBayarBankModel?> getmetodebayarbank(
      String token, String userid) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    try {
      // final response = await dio.get('$baseUrl/master/getmetodebayar/bank',options: _options);
      final response = await dio.get(
          '$baseUrl/master/getmetodebayar/virtual_account',
          options: _options);
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

  Future<MetodeBayarAgenModel?> getmetodebayaragen(
      String token, String userid) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    try {
      // final response = await dio.get('$baseUrl/master/getmetodebayar/agen',options: _options);
      final response = await dio.get(
          '$baseUrl/master/getmetodebayar/online_to_offline_account',
          options: _options);
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
      final response =
          await dio.get('$baseUrl/master/getwilayah', options: _options);
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
      final response = await dio.get('$baseUrl/master/getanggota/$userid',
          options: _options);
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
  Future<SubscribeModel?> getSubscribe(String token, String userid) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    try {
      final response =
          await dio.get('$baseUrl/master/getsubscribe', options: _options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return SubscribeModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<ProvinsiModel?> getProvinsi() async {
    late final Options options =
        Options(headers: {"Content-Type": "application/json"});
    try {
      final response =
          await dio.get('$baseUrl/master/getprovinsi', options: options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return ProvinsiModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<KabKotaModel?> getKabKota(String provinsiId) async {
    late final Options options =
        Options(headers: {"Content-Type": "application/json"});
    try {
      final response = await dio.get(
          '$baseUrl/master/getkotabyprovinsiid/$provinsiId',
          options: options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return KabKotaModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<KecamatanModel?> getKecamatan(String kotaId) async {
    late final Options options =
        Options(headers: {"Content-Type": "application/json"});
    try {
      final response = await dio.get(
          '$baseUrl/master/getkecamatanbykotaid/$kotaId',
          options: options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return KecamatanModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<KelurahanModel?> getKelurahan(String kecamatanId) async {
    late final Options options =
        Options(headers: {"Content-Type": "application/json"});
    try {
      final response = await dio.get(
          '$baseUrl/master/getkelurahanbykecamatanid/$kecamatanId',
          options: options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return KelurahanModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<KodePosModel?> getKodePos(String kelurahanId) async {
    late final Options options =
        Options(headers: {"Content-Type": "application/json"});
    try {
      final response = await dio.get(
          '$baseUrl/master/getkodeposbykelurahanid/$kelurahanId',
          options: options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return KodePosModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> checkRegister(
      String kodeReferral, String email, String telepon) async {
    late final Options options =
        Options(headers: {"Content-Type": "application/json"});
    final body = jsonEncode(
        {"kodereferral": kodeReferral, "email": email, "telepon": telepon});
    try {
      final response = await dio.post('$baseUrl/master/checkregister',
          options: options, data: body);

      // Allow the caller to handle the response logic
      if (response.statusCode == 200) {
        return response.data;
      } else {
        print("Failed to validate register: ${response.statusCode}");
        return response
            .data; // Return data even on error if API returns 200 with status:error
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response?.data;
      }
      print("Error: $e");
      return null;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}
