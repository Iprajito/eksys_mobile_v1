import 'dart:convert';

import 'package:Eksys/controllers/user_controller.dart';
import 'package:Eksys/services/api_service.dart';
import 'package:Eksys/services/localstorage_service.dart';

import 'dart:developer';

import 'package:dio/dio.dart';

class AuthController {
  final ApiServive apiService;
  final StorageService storageService;
  final userController = UserController(StorageService());

  AuthController(this.apiService, this.storageService);

  final String baseUrl = 'https://erp.eahm-indonesia.co.id/api';
  Dio dio = Dio();

  Future<bool> login({required String email, required String password}) async {
    try {
      final login = await apiService.login(email, password);
      // print('Controller Auth');
      if (login.uid != null) {
        await storageService.saveUser(login);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> saveTokenApps(String token, String user_id, String tokenApps) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    final body = jsonEncode({'user_id': user_id, 'token_apps': tokenApps});

    try {
      final response = await dio.post('$baseUrl/savetokenapps', options: _options, data: body);

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

  Future<String> validateToken() async {
    final user = await userController.getUserFromStorage();
    try {
      final check =
          await apiService.validateToken(token: user!.token.toString());
      // print('Controller Auth');
      return check;
    } catch (e) {
      return 'error';
    }
  }

  Future<void> logout() async {
    await storageService.clearLocalStorage();
  }

  Future<void> logoutOutlet() async {
    await storageService.clearOutlet();
  }
}
