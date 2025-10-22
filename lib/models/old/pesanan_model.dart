class FormPesananDetail {
  String outletId;
  String menuId;
  String harga;
  String qty;
  String subtotal;

  FormPesananDetail(
      {required this.outletId,
      required this.menuId,
      required this.harga,
      required this.qty,
      required this.subtotal});

  Map<String, dynamic> toJson() => {
        'outletId': outletId,
        'menuId': menuId,
        'harga': harga,
        'qty': qty,
        'subtotal': subtotal,
      };
}

class PesananSummary {
  String? id;
  String? nota;
  String? status;
  String? metodeId;
  String? metode;
  String? image;
  String? tunai;
  String? qris;
  String? online;
  String? total;
  String? tunairp;
  String? qrisrp;
  String? onlinerp;

  PesananSummary(
      {this.id,
      this.nota,
      this.status,
      this.metodeId,
      this.metode,
      this.image,
      this.tunai,
      this.qris,
      this.online,
      this.total,
      this.tunairp,
      this.qrisrp,
      this.onlinerp});

  factory PesananSummary.fromJsson(Map<String, dynamic> json) {
    return PesananSummary(
      id: json['id'],
      nota: json['nota'],
      status: json['status'],
      metodeId: json['metodeId'],
      metode: json['metode'],
      image: json['image'],
      tunai: json['tunai'],
      qris: json['qris'],
      online: json['online'],
      total: json['total'],
      tunairp: json['tunairp'],
      qrisrp: json['qrisrp'],
      onlinerp: json['onlinerp'],
    );
  }
}

class Pesanan {
  String? id;
  String? nota;
  String? metodeId;
  String? items;
  String? qty;
  String? total;
  String? tglentry;

  Pesanan(
      {this.id, this.nota, this.metodeId, this.items, this.qty, this.total, this.tglentry});

  factory Pesanan.fromJsson(Map<String, dynamic> json) {
    return Pesanan(
        id: json['id'],
        nota: json['nota'],
        metodeId: json['metodeid'],
        items: json['items'],
        qty: json['qty'],
        total: json['total'],
        tglentry: json['tglentry']
    );
  }
}

class PesananModel {
  final List<PesananSummary> summary;
  final List<Pesanan> details;

  PesananModel({required this.summary, required this.details});

  factory PesananModel.fromJson(Map<String, dynamic> json) {
    var summaryList = json['data']['summary'] as List;
    var detailList = json['data']['detail'] as List;

    List<PesananSummary> summary =
        summaryList.map((i) => PesananSummary.fromJsson(i)).toList();
    List<Pesanan> details =
        detailList.map((i) => Pesanan.fromJsson(i)).toList();
    return PesananModel(summary: summary, details: details);
  }
}

class PesananDetail {
  String? id;
  String? menu;
  String? harga;
  String? qty;
  String? subtotal;

  PesananDetail({this.id, this.menu, this.harga, this.qty, this.subtotal});

  // Factory method to convert JSON to object
  factory PesananDetail.fromJson(Map<String, dynamic> json) {
    return PesananDetail(
        id: json['id'],
        menu: json['menu'],
        harga: json['harga'],
        qty: json['qty'],
        subtotal: json['subtotal']);
  }
}

class PesananDetailModel {
  final List<PesananDetail> posts;
  final List<PesananDetail> summary;

  PesananDetailModel({required this.summary, required this.posts});

  factory PesananDetailModel.fromJson(Map<String, dynamic> json) {
    var summaryList = json['data']['summary'] as List;
    var postsList = json['data']['item'] as List;
    List<PesananDetail> summary =
        summaryList.map((i) => PesananDetail.fromJson(i)).toList();
    List<PesananDetail> posts =
        postsList.map((i) => PesananDetail.fromJson(i)).toList();

    return PesananDetailModel(summary: summary, posts: posts);
  }
}
