import 'package:Eksys/models/user_model.dart';
import 'package:Eksys/services/localstorage_service.dart';

class UserController {
  // final ApiServive apiServive;
  final StorageService storageService;

  // UserController(this.apiServive, this.storageService);
  UserController(this.storageService);

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
}
