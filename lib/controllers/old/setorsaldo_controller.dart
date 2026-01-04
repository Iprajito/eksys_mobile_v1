import 'package:Eksys/models/old/setorsaldo_model.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class SetorSaldoController {
  final String baseUrl = 'https://arumdalu.andatara.id/api';
  Dio dio = Dio();

  Future<SetorSaldoModel?> getSetorSaldo(String token, String outletId, String month, String year) async {
    
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    final body = jsonEncode({'outletId': outletId, 'month': month, 'year': year});

    try {
      final response = await dio.post('$baseUrl/setorsaldo', options: _options, data: body);

      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return SetorSaldoModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<bool> saveSetorSaldo(String token, String id, String outletId, String nota, String tanggal, String nominal) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    final body = jsonEncode({'id': id, 'outletId': outletId, 'nota' : nota, 'tanggal' : tanggal, 'nominal' : nominal});

    try {
      final response = await dio.post('$baseUrl/savesetorsaldo', options: _options, data: body);

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

  Future<bool> delSetorSaldo(String token, String id) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    final body = jsonEncode({'id': id});

    try {
      final response = await dio.post('$baseUrl/deletesetorsaldo',
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
