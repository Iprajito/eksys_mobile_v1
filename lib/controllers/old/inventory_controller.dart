import 'package:Eksys/models/old/inventory_model.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class InventoryController {
  final String baseUrl = 'https://arumdalu.andatara.id/api';
  Dio dio = Dio();
  
  Future<MaterialModel?> getMaterial(String token, String outletId, String material) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    
    final body = jsonEncode({'outletId': outletId, 'material': material});

    try {
      final response = await dio.post('$baseUrl/getmaterial', options: _options, data: body);

      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return MaterialModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<InventoryModel?> getInventory(String token, String outletId, String id) async {
    
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    final body = jsonEncode({'outletId': outletId, 'id': id});
    try {
      final response = await dio.post('$baseUrl/getmaterialdetail', options: _options, data: body);
      if (response.statusCode == 200) {
        final data = json.decode(response.toString());
        return InventoryModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<RequestInventoryModel?> getRequestInventory(String token, String outletId) async {
    
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    final body = jsonEncode({'outletId': outletId});
    try {
      final response = await dio.post('$baseUrl/getmaterialrequest', options: _options, data: body);
      if (response.statusCode == 200) {
        final data = json.decode(response.toString());
        return RequestInventoryModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<bool> saveInventory(String token, String outletId, String materialId, String qty) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    final body = jsonEncode({
      'outletId': outletId,
      'materialId': materialId,
      'qty': qty
    });

    try {
      final response = await dio.post('$baseUrl/saveinventory',
          options: _options, data: body);

      if (response.statusCode == 200) {
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

  Future<bool> updateInventory(String token, String id, String tanggal, String status, String qty_supply) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    final body = jsonEncode({
      'id': id,
      'tanggal': tanggal,
      'status': status,
      'qty_supply': qty_supply
    });

    try {
      final response = await dio.post('$baseUrl/updateinventory',
          options: _options, data: body);

      if (response.statusCode == 200) {
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

  Future<bool> delInventory(String token, String id) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    final body = jsonEncode({'id': id});

    try {
      final response = await dio.post('$baseUrl/delinventory',
          options: _options, data: body);

      if (response.statusCode == 200) {
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

  Future<PembelianInventoryModel?> getPembelianInventory(String token, String outletId) async {
    
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    final body = jsonEncode({'outletId': outletId});
    try {
      final response = await dio.post('$baseUrl/getpembelian', options: _options, data: body);
      if (response.statusCode == 200) {
        final data = json.decode(response.toString());
        return PembelianInventoryModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<bool> savePembelian(String token, String outletId, String tanggal, String materialId, String harga, String qty, String total) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    final body = jsonEncode({
      'outletId': outletId,
      'tanggal': tanggal,
      'materialId' : materialId,
      'harga' : harga,
      'qty' : qty,
      'total' : total
    });

    try {
      final response = await dio.post('$baseUrl/savepembelian',
          options: _options, data: body);

      if (response.statusCode == 200) {
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

  Future<bool> uploadImage(String token, FormData image) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    try {
      final response = await dio.post('$baseUrl/uploadpembelian',
          options: _options, data: image);

      if (response.statusCode == 200) {
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
}
