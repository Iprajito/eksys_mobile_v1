import 'package:eahmindonesia/views/page/main.dart';
import 'package:eahmindonesia/views/page/profil.dart';
import 'package:flutter/material.dart';
import 'package:eahmindonesia/models/text_globals.dart' as globals;

class SplashNotif extends StatefulWidget {
  const SplashNotif({Key? key}) : super(key: key);

  @override
  State<SplashNotif> createState() => _SplashNotifState();
}

class _SplashNotifState extends State<SplashNotif> {
  
  @override
  void initState() {
    super.initState();
    if(globals.notifroute == "inv"){
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return const MainPage(currIndex: 1,);
        }));
      });
    }else{
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return const ProfilPage();
        }));
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}