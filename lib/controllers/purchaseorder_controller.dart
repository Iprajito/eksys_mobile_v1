import 'dart:developer';

import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:eahmindonesia/models/pembelian_model.dart';
import 'package:eahmindonesia/models/penerimaan_model.dart';
import 'package:eahmindonesia/models/stokbarang_model.dart';

class PurchaseorderController {
  final String baseUrl = 'https://erp.eahm-indonesia.co.id/api';
  Dio dio = Dio();

  // Pembelian Start
  Future<PembelianModel?> getpembelian(String token, String userid) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    try {
      final response = await dio.get(
          '$baseUrl/purchaseorder/getpembelian/$userid',
          options: _options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return PembelianModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<PembelianModel?> getpembelianbyid(
      String token, String userid, String idencrypt) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    try {
      final response = await dio.get(
          '$baseUrl/purchaseorder/getpembelianbyid/$userid/$idencrypt',
          options: _options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return PembelianModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<PembelianDetailModel?> getpembeliandetailbyid(
      String token, String idencrypt) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    print("Fetching purchase order details for ID: $idencrypt");
    try {
      final response = await dio.get(
          '$baseUrl/purchaseorder/getpembeliandetailbyid/$idencrypt',
          options: _options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return PembelianDetailModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<PembelianNopoModel?> getnopo(String token, String userid) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    print("Fetching purchase order details for ID: $userid");
    try {
      final response = await dio.get('$baseUrl/purchaseorder/getnopo/$userid',
          options: _options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return PembelianNopoModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<String> savePembelian(
      String token,
      String userid,
      String nopo,
      String supplier_id,
      String tanggal,
      String keterangan,
      String subtotal,
      String transaksifee,
      String grandtotal,
      String jumlahdp,
      String metodetipe,
      String channel) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    final body = jsonEncode({
      'userid': userid,
      'nopo': nopo,
      'supplier_id': supplier_id,
      'tanggal': tanggal,
      'keterangan': keterangan,
      'subtotal': subtotal,
      'transaksifee': transaksifee,
      'grandtotal': grandtotal,
      'jumlahdp': jumlahdp,
      'metode_bayar': metodetipe,
      'channel': channel
    });
    print("Body : $body");
    try {
      final response = await dio.post('$baseUrl/purchaseorder/pembeliansave',
          options: _options, data: body);
      print(response);
      if (response.data['status'] == 'success') {
        // print(inspect(response.data['message']));
        print('Form saved successfully');
        return response.data['message'];
      } else {
        print('Failed to save form: $response');
        return '0';
      }
    } catch (error) {
      print('Error: $error');
      return '0';
    }
  }

  Future<void> saveTempPembelianDetail(
      String token, FormPembelianDetail entry) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    final body = jsonEncode(entry.toJson());
    try {
      final response = await dio.post(
          '$baseUrl/purchaseorder/savetemppembeliandetail',
          options: _options,
          data: body);

      if (response.data['status'] == 'success') {
        print('Entry saved successfully');
      } else {
        print('Failed to save entry: $response');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<bool> savePembelianBatal(String token, String userid, String id_encrypt) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    final body = jsonEncode({'userid': userid,'id_encrypt': id_encrypt});
    try {
      final response = await dio.post(
          '$baseUrl/purchaseorder/pembelianbatal',
          options: _options,
          data: body);

      if (response.data['status'] == 'success') {
        print('Entry saved successfully');
        return true;
      } else {
        print('Failed to save entry: $response');
        return false;
      }
    } catch (error) {
      print('Error: $error');
      return false;
    }
  }

  Future<TempPembelianDetailModel?> gettemppembeliandetail(
      String token, String userid) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    print("Fetching gettemppembeliandetail details for ID: $userid");
    try {
      final response = await dio.get(
          '$baseUrl/purchaseorder/gettemppembeliandetail/$userid',
          options: _options);
      // print("Feching : $response");
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return TempPembelianDetailModel.fromJson(data);
      } else {
        print("Fetching : Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<bool> delTempPembelianDetail(
      String token, String userid, String id) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    final body = jsonEncode({'userid': userid, 'id': id});
    print(body);
    try {
      final response = await dio.post(
          '$baseUrl/purchaseorder/deltemppesanandetail',
          options: _options,
          data: body);

      if (response.data['status'] == 'success') {
        print(inspect(response.data['message']));
        print('Form saved successfully');
        return true;
      } else {
        print('Failed to save form: $response');
        return true;
      }
    } catch (error) {
      print('Error: $error');
      return true;
    }
  }

  Future<bool> savePembelianVA(String token,String userid,String id_encrypt, String tipe) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    final body = jsonEncode({'userid': userid,'id_encrypt': id_encrypt, 'tipe' : tipe});
    print("Body : $body");
    try {
      final response = await dio.post('$baseUrl/virtualaccount/create',
          options: _options, data: body);
      print(response);
      if (response.data['status'] == 200) {
        // print(inspect(response.data['message']));
        print('Form saved successfully');
        return true;
      } else {
        print('Failed to save form: $response');
        return false;
      }
    } catch (error) {
      print('Error: $error');
      return true;
    }
  }

  Future<PembelianVAModel?> getvabypembelianid(
      String token, String userid, String idencrypt) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    try {
      final response = await dio.get(
          '$baseUrl/purchaseorder/getvabypembelianid/$idencrypt',
          options: _options);
      print(response);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return PembelianVAModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
  // Pembelian End

  // Penerimaan Start
  Future<PenerimaanNopuModel?> getnopu(String token, String userid) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    print("Fetching purchase order details for ID: $userid");
    try {
      final response = await dio.get('$baseUrl/purchaseorder/getnopu/$userid',
          options: _options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return PenerimaanNopuModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<PembelianPOModel?> getpenerimaanpo(String token, String userid) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    print("Fetching purchase order details for ID: $userid");
    try {
      final response = await dio.get('$baseUrl/purchaseorder/getpenerimaanpo/$userid',
          options: _options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return PembelianPOModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<PenerimaanPoDetailModel?> getpenerimaanpodetail(String token, String nopo) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    print("Fetching purchase order details for ID: $nopo");
    try {
      final response = await dio.get('$baseUrl/purchaseorder/getpenerimaanpodetail/$nopo',
          options: _options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return PenerimaanPoDetailModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
  
  Future<bool> savePenerimaan(String token, String userid, String pembelian_nopo, String pembelian_tglpo, String tanggal, String nonota, String supplier_id, String tipeppn, String id_syaratbayar, List<PenerimaanPoDetail> entries) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    // final body = jsonEncode(entry.toJson());

    final body = jsonEncode({
      'userid': userid,
      'nopo': pembelian_nopo,
      'tgl_po': pembelian_tglpo,
      'tanggal': tanggal,
      'nonota': nonota,
      'supplier_id': supplier_id,
      'tipeppn': tipeppn,
      'id_syaratbayar': id_syaratbayar,
      'details': entries.map((e) => e.toJson()).toList()
    });
    print("Body : $body");
    try {
      final response = await dio.post(
          '$baseUrl/purchaseorder/penerimaansave',
          options: _options,
          data: body);

      if (response.data['status'] == 'success') {
        print('Entry saved successfully');
        return true;
      } else {
        print('Failed to save entry: $response');
        return false;
      }
      // return true;
    } catch (error) {
      print('Error: $error');
      return false;
    }
  }
  
  Future<PenerimaanModel?> getpenerimaan(String token, String userid) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    print("Fetching purchase order details for ID: $userid");
    try {
      final response = await dio.get('$baseUrl/purchaseorder/getpenerimaan/$userid',
          options: _options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return PenerimaanModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<PenerimaanModel?> getpenerimaanbyid(String token, String userid, String id_encrypt) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    print("Fetching purchase order details for ID: $userid");
    try {
      final response = await dio.get('$baseUrl/purchaseorder/getpenerimaanbyid/$userid/$id_encrypt',
          options: _options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return PenerimaanModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<PenerimaanDetailModel?> getpenerimaandetailbyid(String token, String id_encrypt) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    try {
      final response = await dio.get('$baseUrl/purchaseorder/getpenerimaandetailbyid/$id_encrypt',
          options: _options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return PenerimaanDetailModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
  // Penerimaan End

  // Stok Barang Start
  Future<StokBarangModel?> getmutasistok(String token, String userid) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    try {
      final response = await dio.get('$baseUrl/purchaseorder/getmutasistok/$userid',
          options: _options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return StokBarangModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
  // Stok Barang End
}
