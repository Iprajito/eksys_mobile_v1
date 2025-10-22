class Summary {
  String? totaltunai;
  String? totalqris;
  String? totalonline;
  String? totaljual;

  Summary({this.totaltunai, this.totalqris, this.totalonline, this.totaljual});

  // Factory method to convert JSON to object
  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
        totaltunai: json['totaltunai'],
        totalqris: json['totalqris'],
        totalonline: json['totalonline'],
        totaljual: json['totaljual']
    );
  }
}

class ProdukTerlaris {
  String? menuid;
  String? menu;
  String? qty;

  ProdukTerlaris({this.menuid, this.menu, this.qty});

  // Factory method to convert JSON to object
  factory ProdukTerlaris.fromJson(Map<String, dynamic> json) {
    return ProdukTerlaris(
        menuid: json['menu_id'],
        menu: json['menu'],
        qty: json['qty']
    );
  }
}

class PenjualanUnit {
  String? date;
  String? unit;

  PenjualanUnit({this.date, this.unit});

  // Factory method to convert JSON to object
  factory PenjualanUnit.fromJson(Map<String, dynamic> json) {
    return PenjualanUnit(
        date: json['date'],
        unit: json['unit']
    );
  }
}

class PenjualanRupiah {
  String? date;
  String? unit;

  PenjualanRupiah({this.date, this.unit});

  // Factory method to convert JSON to object
  factory PenjualanRupiah.fromJson(Map<String, dynamic> json) {
    return PenjualanRupiah(
        date: json['date'],
        unit: json['unit']
    );
  }
}

class ReportPenjualanModel {
  final List<Summary> summary;
  final List<ProdukTerlaris> produkterlaris;
  final List<PenjualanUnit> penjualanunit;
  final List<PenjualanRupiah> penjualanrupiah;

  ReportPenjualanModel({required this.summary, required this.produkterlaris, required this.penjualanunit, required this.penjualanrupiah});

  factory ReportPenjualanModel.fromJson(Map<String, dynamic> json) {
    var summaryList = json['summary'] as List;
    var produkterlarisList = json['produkterlaris'] as List;
    var penjualanunitList = json['penjualanunit'] as List;
    var penjualanrupiahList = json['penjualanrupiah'] as List;
    
    List<Summary> summary = summaryList.map((i) => Summary.fromJson(i)).toList();
    List<ProdukTerlaris> produkterlaris = produkterlarisList.map((i) => ProdukTerlaris.fromJson(i)).toList();
    List<PenjualanUnit> penjualanunit = penjualanunitList.map((i) => PenjualanUnit.fromJson(i)).toList();
    List<PenjualanRupiah> penjualanrupiah = penjualanrupiahList.map((i) => PenjualanRupiah.fromJson(i)).toList();
    
    return ReportPenjualanModel(summary: summary, produkterlaris: produkterlaris, penjualanunit: penjualanunit, penjualanrupiah : penjualanrupiah);
  }
}