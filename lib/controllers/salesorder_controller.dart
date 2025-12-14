import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:eahmindonesia/models/penjualan_model.dart';

class SalesorderController {
  final String baseUrl = 'https://erp.eahm-indonesia.co.id/api';
  Dio dio = Dio();

  Future<PenjualanNosoModel?> getnoso(String token, String userid) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    // print("Fetching purchase order details for ID: $userid");
    try {
      final response = await dio.get('$baseUrl/salesorder/getnoso/$userid',
          options: _options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return PenjualanNosoModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<CustomerModel?> getcustomer(String token, String userid) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    // print("Fetching purchase order details for ID: $userid");
    try {
      final response = await dio.get('$baseUrl/salesorder/getpelanggan/$userid',
          options: _options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return CustomerModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<CustomerPOModel?> getcustomerpo(String token, String userid) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    // print("Fetching purchase order details for ID: $userid");
    try {
      final response = await dio.get('$baseUrl/salesorder/getpenjualanpocustomer/$userid',
          options: _options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return CustomerPOModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<PenjualanModel?> getpenjualan(String token, String userid) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    // print("Fetching purchase order details for ID: $userid");
    try {
      final response = await dio.get('$baseUrl/salesorder/getpenjualan/$userid',
          options: _options);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return PenjualanModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<String> savePenjualan(
      String token,
      String userid,
      String noso,
      String customer_id,
      String tanggal,
      String customer_po,
      String customer_tglpo,
      String keterangan,
      String subtotal,
      String grandtotal,
      String metode_tipe,
      String metode_channel,
      String biaya_layanan
      ) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    final body = jsonEncode({
      'userid': userid,
      'noso': noso,
      'pelanggan_id': customer_id,
      'tgl_so': tanggal,
      'pembelian_nopo': customer_po,
      'pembelian_tglpo': customer_tglpo,
      'subtotal': subtotal,
      'grandtotal': grandtotal,
      'metode_tipe': metode_tipe,
      'metode_channel': metode_channel,
      'biaya_layanan': biaya_layanan,
      
    });
    print("Body : $body");
    try {
      final response = await dio.post('$baseUrl/salesorder/penjualansave',
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

  Future<void> saveTempPenjualanDetail(
      String token, FormPenjualanDetail entry) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    final body = jsonEncode(entry.toJson());
    try {
      final response = await dio.post(
          '$baseUrl/salesorder/savetemppenjualandetail',
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

  Future<bool> saveTempCustomerPODetail(String token,String userid,String id_po) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    final body = jsonEncode({'userid': userid,'id_po': id_po});
    try {
      final response = await dio.post(
          '$baseUrl/salesorder/savepocustomerdetail',
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

  Future<TempPenjualanDetailModel?> gettemppenjualandetail(
      String token, String userid) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    print("Fetching gettemppenjualandetail details for ID: $userid");
    try {
      final response = await dio.get('$baseUrl/salesorder/gettemppenjualandetail/$userid',options: _options);
      // print("Feching : $response");
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return TempPenjualanDetailModel.fromJson(data);
      } else {
        print("Fetching : Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<bool> delTempPenjualanDetail(
      String token, String userid, String id) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    final body = jsonEncode({'userid': userid, 'id': id});
    print(body);
    try {
      final response = await dio.post(
          '$baseUrl/salesorder/deltempppenjualandetail',
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
}