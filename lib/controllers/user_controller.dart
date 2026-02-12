import 'package:Eksys/models/user_model.dart';
import 'dart:convert';
import 'package:Eksys/services/localstorage_service.dart';
import 'package:dio/dio.dart';

class UserController {
  // final ApiServive apiServive;
  final StorageService storageService;

  // UserController(this.apiServive, this.storageService);
  UserController(this.storageService);

  final String baseUrl = 'https://erp.eahm-indonesia.co.id/api';
  Dio dio = Dio();

  Future<User?> getUserFromStorage() async {
    // String? uid = await storageService.getUid();
    // print('Request Controller');
    // if (uid != null) {
    //   return await apiServive.getUserByUid(uid);
    // }
    // return null;

    User? user = await storageService.getUser();
    // print('Request Controller : User');
    if (user != null) {
      // print(user.toJson());
      // print("User UID: ${user.uid}");
      // print("User Name: ${user.name}");
      // print("User Email: ${user.email}");
      Map<String, dynamic> userMap = user.toJson();
      return User.fromJson(userMap);
    } else {
      return null;
    }
  }

  Future<bool> saveAlamatPelanggan(Map<String, dynamic> data) async {
    late final Options options =
        Options(headers: {"Content-Type": "application/json"});
    try {
      final response = await dio.post('$baseUrl/master/savealamatpelanggan',
          options: options, data: jsonEncode(data));
      if (response.data['status'] == 'success') {
        return true;
      }
      return false;
    } catch (e) {
      print("Error saving alamat: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> registerUser(Map<String, dynamic> data) async {
    late final Options options =
        Options(headers: {"Content-Type": "application/json"});
    try {
      final response = await dio.post('$baseUrl/master/register',
          options: options, data: jsonEncode(data));
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response?.data;
      }
      return null;
    } catch (e) {
      print("Error registering user: $e");
      return null;
    }
  }
}
