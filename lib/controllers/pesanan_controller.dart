import 'dart:developer';

import 'package:Eksys/models/old/pesanan_model.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class PesananController {
  final String baseUrl = 'https://arumdalu.andatara.id/api';
  Dio dio = Dio();

  Future<bool> savePesanan(
      String token, String id, String metodeId, String outletId) async {
    // late final Options _options =  Options(headers: {'Content-Type': 'application/json'});

    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    final body =
        jsonEncode({'id': id, 'metodeId': metodeId, 'outletId': outletId});

    try {
      // final response = await dio.post('$baseUrl/postpesanan.php',options: _options, data: body);
      final response =
          await dio.post('$baseUrl/savepesanan', options: _options, data: body);

      if (response.data['status'] == 'success') {
        // print(inspect(response.data['message']));
        print('Form saved successfully');
        return true;
      } else {
        print('Failed to save form: $response');
        return false;
      }
    } catch (error) {
      print('Error: $error');
      return false;
    }
  }

  Future<bool> deletePesanan(String token, String id, String outletId) async {
    // late final Options _options =  Options(headers: {'Content-Type': 'application/json'});

    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    final body = jsonEncode({'id': id, 'outletId': outletId});

    try {
      // final response = await dio.post('$baseUrl/postpesanan.php',options: _options, data: body);
      final response = await dio.post('$baseUrl/deletepesanan',
          options: _options, data: body);

      if (response.data['status'] == 'success') {
        // print(inspect(response.data['message']));
        print('Form saved successfully');
        return true;
      } else {
        print('Failed to save form: $response');
        return false;
      }
    } catch (error) {
      print('Error: $error');
      return false;
    }
  }

  Future<void> savePesananDetail(String token, FormPesananDetail entry) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    final body = jsonEncode(entry.toJson());
    try {
      final response = await dio.post('$baseUrl/savepesanandetail',
          options: _options, data: body);

      if (response.data['status'] == 'success') {
        print('Entry saved successfully');
      } else {
        print('Failed to save entry: $response');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<bool> delTempPesanan(String token, String outletId, String id) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    final body = jsonEncode({'outlet_id': outletId, 'id': id});
    // print(body);
    try {
      final response = await dio.post('$baseUrl/deltemppesanan',
          options: _options, data: body);

      if (response.data['status'] == 'success') {
        // print(inspect(response.data['message']));
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

  Future<PesananModel?> getDataPesanan(
      String token, String outletId, String status, String tanggal) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    final body = jsonEncode(
        {'outlet_id': outletId, 'status': status, 'tanggal': tanggal});
    try {
      // final response = await dio.get(
      //     '$baseUrl/getpesanan.php?outlet_id=$outletId&status=$status&tgl=$tanggal',
      //     options: _options);

      final response =
          await dio.post('$baseUrl/getpesanan', options: _options, data: body);

      // print('Controller');
      // print(response);
      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return PesananModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<PesananModel?> getDataPesananById(String token, String id) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    try {
      final response =
          await dio.get('$baseUrl/getpesananbyid/$id', options: _options);

      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return PesananModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<PesananDetailModel?> getDataPesananDetail(
      String token, String outletId) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    try {
      final response =
          await dio.get('$baseUrl/gettemppesanan/$outletId', options: _options);

      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return PesananDetailModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<dynamic> uploadImage(String token, FormData image) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    // final body = jsonEncode({'id': id, 'metodeId': metodeId, 'image': image});

    try {
      final response = await dio.post('$baseUrl/uploadpenjualan',
          options: _options, data: image);

      if (response.statusCode == 200) {
        // print(inspect(response.data));
        print('Form saved successfully');
        return response.data['path'];
      } else {
        print('Failed to save form: $response');
        return 'error';
      }
    } catch (error) {
      print('Error: $error');
      return 'error';
    }
  }
  
  Future<bool> deleteImageUpload(String token, String id) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    final body = jsonEncode({'id': id});
    // print(body);
    try {
      final response = await dio.post('$baseUrl/deleteimageupload',
          options: _options, data: body);

      if (response.data['status'] == 'success') {
        // print(inspect(response.data['message']));
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
