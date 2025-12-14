import 'dart:convert';
import 'dart:ffi';

import 'package:eahmindonesia/models/old/produkkategori_model.dart';
import 'package:eahmindonesia/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  Future<void> saveOutlet(String id, String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('outlet_id', id);
    await prefs.setString('outlet_name', name);
  }

  Future<String?> getOutletId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('outlet_id');
  }

  Future<String?> getOutletName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('outlet_name');
  }

  // Future<void> clearUid() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('uid');
  // }

  // Save user object to local storage
  Future<void> saveUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userJson = jsonEncode(user.toJson());
    await prefs.setString('user', userJson);
  }

  // Get user object from local storage
  Future<User?> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');
    if (userJson != null) {
      Map<String, dynamic> userMap = jsonDecode(userJson);
      return User.fromJson(userMap);
    }
    return null;
  }

  // Save user object to local storage
  // Future<void> saveKategoriProduk(ProdukKategori produkKategori) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String dataJson = jsonEncode(produkKategori.toJson());
  //   await prefs.setString('kategoriproduk', dataJson);
  // }

  // Future<void> saveKategoriProduk(List<ProdukKategori> products) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   String productJson = jsonEncode(products.map((product) => product.toJson()).toList());
  //   prefs.setString('products', productJson);
  // }

  // Get Kategori Produk object from local storage
  // Future<ProdukKategori?> getKategoriProduk() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? dataJson = prefs.getString('kategoriproduk');
  //   if (dataJson != null) {
  //     Map<String, dynamic> dataMap = jsonDecode(dataJson);
  //     // print(dataMap);
  //     return ProdukKategori.fromJson(dataMap);
  //   }
  //   return null;
  // }

  Future<List<ProdukKategori>> getKategoriProduk() async {
    final prefs = await SharedPreferences.getInstance();
    String? productJson = prefs.getString('products');

    if (productJson != null) {
      List jsonResponse = jsonDecode(productJson);
      return jsonResponse
          .map((product) => ProdukKategori.fromJson(product))
          .toList();
    } else {
      return [];
    }
  }

  // Clear all data from local storage (for example on logout)
  Future<void> clearLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('outlet_id');
    await prefs.remove('outlet_name');
  }

  Future<void> clearOutlet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('outlet_id');
    await prefs.remove('outlet_name');
  }
}
