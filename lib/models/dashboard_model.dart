class SummaryDashboard {
  String? saldo;
  String? penjualan;
  String? notapesanan;
  String? notasetor;

  SummaryDashboard({this.saldo, this.penjualan, this.notapesanan, this.notasetor});

  // Factory method to convert JSON to object
  factory SummaryDashboard.fromJson(Map<String, dynamic> json) {
    return SummaryDashboard(
        saldo: json['saldo'],
        penjualan: json['penjualan'],
        notapesanan: json['notapesanan'],
        notasetor: json['notasetor']
    );
  }
}

class PenjualanDashboard {
  String? id;
  String? nota;
  String? metode;
  String? menu;
  String? qty;
  String? harga;
  String? subtotal;
  String? jam;

  PenjualanDashboard({this.id, this.nota, this.metode, this.menu, this.qty, this.harga, this.subtotal, this.jam});

  // Factory method to convert JSON to object
  factory PenjualanDashboard.fromJson(Map<String, dynamic> json) {
    return PenjualanDashboard(
        id: json['id'],
        nota: json['nota'],
        metode: json['metode'],
        menu: json['menu'],
        qty: json['qty'],
        harga: json['harga'],
        subtotal: json['subtotal'],
        jam: json['jam']
    );
  }
}

class RequestStockDashboard {
  String? id;
  String? material;
  String? satuan;
  String? keterangan;
  String? tglRequest;

  RequestStockDashboard({this.id, this.material, this.satuan, this.keterangan, this.tglRequest});

  // Factory method to convert JSON to object
  factory RequestStockDashboard.fromJson(Map<String, dynamic> json) {
    return RequestStockDashboard(
        id: json['id'],
        material: json['material'],
        satuan: json['satuan'],
        keterangan: json['keterangan'],
        tglRequest: json['tgl_request'],
    );
  }
}

class DashboardModel {
  final List<SummaryDashboard> posts;
  final List<PenjualanDashboard> jual;
  final List<RequestStockDashboard> requeststock;

  DashboardModel({required this.posts, required this.jual, required this.requeststock});

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    var postsList = json['summary'] as List;
    var jualList = json['datapenjualan'] as List;
    var requestList = json['datarequeststock'] as List;
    
    List<SummaryDashboard> posts = postsList.map((i) => SummaryDashboard.fromJson(i)).toList();
    List<PenjualanDashboard> jual = jualList.map((i) => PenjualanDashboard.fromJson(i)).toList();
    List<RequestStockDashboard> requeststock = requestList.map((i) => RequestStockDashboard.fromJson(i)).toList();
    
    return DashboardModel(posts: posts, jual: jual, requeststock: requeststock);
  }
}
