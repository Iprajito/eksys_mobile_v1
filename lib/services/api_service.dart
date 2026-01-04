import 'dart:convert';
import 'dart:developer';

import 'package:Eksys/models/user_model.dart';
import 'package:dio/dio.dart';

class ApiServive {
  final String baseUrl = 'https://erp.eahm-indonesia.co.id/api';
  Dio dio = Dio();
  // late final Options _options = Options(headers: {'accept': 'application/json'});

  late final Options _options =
      Options(headers: {'Content-Type': 'application/json'});

  Future<User> login(String email, String password) async {
    final body = jsonEncode({'email': email, 'password': password});
    try {
      final response = await dio.post('$baseUrl/auth/login', options: _options, data: body);
      if (response.data['status'] == 'success') {
        final Map<String, dynamic> data = response.data['data'];
        return User.fromJson(data);
      } else {
        return User(uid: null);
      }
    } on DioException catch (e) {
      return User(uid: null);
    }
  }

  Future<String> validateToken({required String token}) async {
    late final Options options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    final response = await dio.get('$baseUrl/validatetoken', options: options);
    return response.data['status'];
  }
}
