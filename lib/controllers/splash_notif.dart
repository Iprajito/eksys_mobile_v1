import 'package:Eksys/views/page/main.dart';
import 'package:Eksys/views/page/profil/profil.dart';
import 'package:Eksys/views/page/purchaseorder/pembelian/detail.dart';
import 'package:Eksys/views/page/purchaseorder/pembelian/pembelian.dart';
import 'package:flutter/material.dart';
import 'package:Eksys/models/text_globals.dart' as globals;

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
          return const PembelianPage();
        }));
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}