import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:Eksys/models/kegiatan_model.dart';

class KegiatanController {
  final String baseUrl = 'https://erp.eahm-indonesia.co.id/api';
  Dio dio = Dio();

  Future<void> saveTempKegiatanDispatch(
      String token, FormKegiatanDetail entry) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    final body = jsonEncode(entry.toJson());
    print(body);
    try {
      final response = await dio.post('$baseUrl/kegiatan/savetempkegiatandispatch', options: _options, data: body);
      print(response);
      if (response.data['status'] == 'success') {
        print('Entry saved successfully');
      } else {
        print('Failed to save entry: $response');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<TempKegiatanDispacthModel?> gettempkegiatandispatch(
      String token, String userid) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    try {
      final response =
          await dio.get('$baseUrl/kegiatan/gettempkegiatandispatch/$userid', options: _options);

      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return TempKegiatanDispacthModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<bool> deltempkegiatandispatch(
      String token, String userid, String id) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    final body = jsonEncode({'userid': userid, 'id': id});
    print(body);
    try {
      final response = await dio.post(
          '$baseUrl/kegiatan/deltempkegiatandispatch',
          options: _options,
          data: body);

      if (response.data['status'] == 'success') {
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

  Future<bool> saveKegiatan(
      String token, String userid, String tanggal, String jam, String namakegiatan, String aktifitas, String lokasi, String is_iuran, String nominal) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    final body = jsonEncode({
      'userid': userid,
      'tanggal': tanggal,
      'jam': jam,
      'namakegiatan': namakegiatan,
      'aktifitas': aktifitas,
      'lokasi': lokasi,
      'is_iuran': is_iuran,
      'nominal': nominal
    });
    print(body);
    try {
      // final response = await dio.post('$baseUrl/postpesanan.php',options: _options, data: body);
      final response =
          await dio.post('$baseUrl/kegiatan/savekegiatan', options: _options, data: body);

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

  Future<void> saveKegiatanDispatch(
      String token, String id, FormKegiatanDetail entry) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    final body = jsonEncode(entry.toJson());
    print(body);
    try {
      final response = await dio.post('$baseUrl/kegiatan/savekegiatandispatch', options: _options, data: body);
      print(response);
      if (response.data['status'] == 'success') {
        print('Entry saved successfully');
      } else {
        print('Failed to save entry: $response');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<bool> saveKegiatanSelesai(String token, String id, String notulen, List<File> files) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    // final body = jsonEncode(entry.toJson());
    // print(body);
    FormData formData = FormData();
    // Tambahkan field biasa
    formData.fields.addAll([
      MapEntry("kegiatan_id", id),
      MapEntry("notulensi", notulen),
    ]);

    print(inspect(formData));

    // Tambahkan file
    for (var i = 0; i < files.length; i++) {
      formData.files.add(MapEntry(
        "files[]", // 👈 sesuaikan dengan API kamu
        await MultipartFile.fromFile(
          files[i].path,
          filename: files[i].path.split('/').last,
        ),
      ));
    }

    try {
      final response = await dio.post('$baseUrl/kegiatan/savekegiatanselesai', options: _options, data: formData);
      print(response);
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

  Future<KegiatanModel?> getkegiatan(
      String token, String userid, String status) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    try {
      final response =
          await dio.get('$baseUrl/kegiatan/getkegiatan/$userid/$status', options: _options);

      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return KegiatanModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<KegiatanModel?> getkegiatanbyid(
      String token, String userid, String id) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    try {
      final response =
          await dio.get('$baseUrl/kegiatan/getkegiatanbyid/$userid/$id', options: _options);

      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return KegiatanModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<KegiatanDispatchModel?> getkegiatandispatchbyid(
      String token, String id) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    try {
      final response =
          await dio.get('$baseUrl/kegiatan/getkegiatandispatchbyid/$id', options: _options);

      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return KegiatanDispatchModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}