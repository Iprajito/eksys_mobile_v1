import 'package:eahmindonesia/controllers/user_controller.dart';
import 'package:eahmindonesia/services/api_service.dart';
import 'package:eahmindonesia/services/localstorage_service.dart';

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
