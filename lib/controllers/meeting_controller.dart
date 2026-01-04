import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:Eksys/models/meeting_model.dart';

class MeetingController {
  final String baseUrl = 'https://erp.eahm-indonesia.co.id/api';
  Dio dio = Dio();

  Future<void> saveTempMeetingDispatch(
      String token, FormMeetingDetail entry) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    final body = jsonEncode(entry.toJson());
    print(body);
    try {
      final response = await dio.post('$baseUrl/meeting/savetempmeetingdispatch', options: _options, data: body);
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

  Future<TempMeetingDispacthModel?> gettempmeetingdispatch(
      String token, String userid) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    try {
      final response =
          await dio.get('$baseUrl/meeting/gettempmeetingdispatch/$userid', options: _options);

      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return TempMeetingDispacthModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<bool> deltempmeetingdispatch(
      String token, String userid, String id) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    final body = jsonEncode({'userid': userid, 'id': id});
    print(body);
    try {
      final response = await dio.post(
          '$baseUrl/meeting/deltempmeetingdispatch',
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

  Future<bool> saveMeeting(
      String token, String userid, String tanggal, String jam, String topik, String lokasi, String is_iuran, String nominal) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    final body = jsonEncode({
      'userid': userid,
      'tanggal': tanggal,
      'jam': jam,
      'topik': topik,
      'lokasi': lokasi,
      'is_iuran': is_iuran,
      'nominal': nominal
    });
    print(body);
    try {
      // final response = await dio.post('$baseUrl/postpesanan.php',options: _options, data: body);
      final response =
          await dio.post('$baseUrl/meeting/savemeeting', options: _options, data: body);

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

  Future<void> saveMeetingDispatch(
      String token, String id, FormMeetingDetail entry) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    final body = jsonEncode(entry.toJson());
    print(body);
    try {
      final response = await dio.post('$baseUrl/meeting/savemeetingdispatch', options: _options, data: body);
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

  Future<bool> saveMeetingSelesai(String token, String id, String notulen, List<File> files) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });
    // final body = jsonEncode(entry.toJson());
    // print(body);
    FormData formData = FormData();
    // Tambahkan field biasa
    formData.fields.addAll([
      MapEntry("meeting_id", id),
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
      final response = await dio.post('$baseUrl/meeting/savemeetingselesai', options: _options, data: formData);
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
  
  Future<MeetingModel?> getmeeting(
      String token, String userid, String status) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    try {
      final response =
          await dio.get('$baseUrl/meeting/getmeeting/$userid/$status', options: _options);

      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return MeetingModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<MeetingModel?> getmeetingbyid(
      String token, String userid, String id) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    try {
      final response =
          await dio.get('$baseUrl/meeting/getmeetingbyid/$userid/$id', options: _options);

      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return MeetingModel.fromJson(data);
      } else {
        print("Failed to load data");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<MeetingDispatchModel?> getmeetingdispatchbyid(
      String token, String id) async {
    late final Options _options = Options(headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    try {
      final response =
          await dio.get('$baseUrl/meeting/getmeetingdispatchbyid/$id', options: _options);

      if (response.data['status'] == 'success') {
        final data = json.decode(response.toString());
        return MeetingDispatchModel.fromJson(data);
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