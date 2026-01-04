class PenerimaanModel {
  final List<Penerimaan> data;

  PenerimaanModel({required this.data});

  factory PenerimaanModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<Penerimaan> data = datas.map((i) => Penerimaan.fromJsson(i)).toList();
    return PenerimaanModel(data: data);
  }
}

class PenerimaanDetailModel {
  final List<PenerimaanDetail> data;

  PenerimaanDetailModel({required this.data});

  factory PenerimaanDetailModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<PenerimaanDetail> data = datas.map((i) => PenerimaanDetail.fromJsson(i)).toList();
    return PenerimaanDetailModel(data: data);
  }
}

class PembelianPOModel {
  final List<PembelianPO> data;

  PembelianPOModel({required this.data});

  factory PembelianPOModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<PembelianPO> data = datas.map((i) => PembelianPO.fromJsson(i)).toList();
    return PembelianPOModel(data: data);
  }
}

class PenerimaanNopuModel {
  final List<PenerimaanNopu> data;

  PenerimaanNopuModel({required this.data});

  factory PenerimaanNopuModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<PenerimaanNopu> data =
        datas.map((i) => PenerimaanNopu.fromJsson(i)).toList();
    return PenerimaanNopuModel(data: data);
  }
}

class PenerimaanPoDetailModel {
  final List<PenerimaanPoDetail> data;

  PenerimaanPoDetailModel({required this.data});

  factory PenerimaanPoDetailModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<PenerimaanPoDetail> data =datas.map((i) => PenerimaanPoDetail.fromJsson(i)).toList();
    return PenerimaanPoDetailModel(data: data);
  }
}

class PembelianPO {
  String? id;
  String? nopo;
  String? tgl_po;
  String? supplier_id;
  String? supplier;
  String? tipeppn;
  String? id_syaratbayar;
  String? item;
  String? qty;

  PembelianPO({
    this.id,
    this.nopo,
    this.tgl_po,
    this.supplier_id,
    this.supplier,
    this.tipeppn,
    this.id_syaratbayar,
    this.item,
    this.qty
  });

  factory PembelianPO.fromJsson(Map<String, dynamic> json) {
    return PembelianPO(
      id: json['id'],
      nopo: json['nopo'],
      tgl_po: json['tgl_po'],
      supplier_id: json['supplier_id'],
      supplier: json['supplier'],
      tipeppn: json['tipeppn'],
      id_syaratbayar: json['id_syaratbayar'],
      item: json['item'],
      qty: json['qty']
    );
  }
}

class PenerimaanNopu {
  String? nopu;

  PenerimaanNopu({this.nopu});

  factory PenerimaanNopu.fromJsson(Map<String, dynamic> json) {
    return PenerimaanNopu(nopu: json['nopu']);
  }
}

class PenerimaanPoDetail {
  String? id;
  String? nopo;
  String? pelanggan;
  String? produk_id;
  String? namaproduk;
  String? satuan_produk;
  String? harga;
  String? qtyorder;
  String? qtykirim;
  String? qtysupply;
  String? qtysisa;
  String? qtyterima;
  String? image;

  PenerimaanPoDetail({
    this.id,
    this.nopo,
    this.pelanggan,
    this.produk_id,
    this.namaproduk,
    this.satuan_produk,
    this.harga,
    this.qtyorder,
    this.qtykirim,
    this.qtysupply,
    this.qtysisa,
    this.qtyterima,
    this.image,
  });

  factory PenerimaanPoDetail.fromJsson(Map<String, dynamic> json) {
    return PenerimaanPoDetail(
      id: json['id'],
      nopo: json['nopo'],
      pelanggan: json['pelanggan'],
      produk_id: json['produk_id'],
      namaproduk: json['namaproduk'],
      satuan_produk: json['satuan_produk'],
      harga: json['harga'],
      qtyorder: json['qtyorder'],
      qtykirim: json['qtykirim'],
      qtysupply: json['qtysupply'],
      qtysisa: json['qtysisa'],
      qtyterima: '0',
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nopo': nopo,
    'pelanggan': pelanggan,
    'produk_id': produk_id,
    'namaproduk': namaproduk,
    'satuan_produk': satuan_produk,
    'harga': harga,
    'qtyorder': qtyorder,
    'qtysupply': qtysupply,
    'qtysisa': qtysisa,
    'qtyterima': qtyterima,
  };
}

class Penerimaan {
  String? id;
  String? id_encrypt;
  String? nopu;
  String? tgl_pu;
  String? tgljthtempo;
  String? nopo;
  String? tgl_po;
  String? supplier_id;
  String? supplier;
  String? subtotal;
  String? ppn;
  String? grandtotal;
  String? nonota;
  String? noinvcust;
  String? tglinvcust;

  Penerimaan({
    this.id,
    this.id_encrypt,
    this.nopu,
    this.tgl_pu,
    this.tgljthtempo,
    this.nopo,
    this.tgl_po,
    this.supplier_id,
    this.supplier,
    this.subtotal,
    this.ppn,
    this.grandtotal,
    this.nonota,
    this.noinvcust,
    this.tglinvcust,
  });

  factory Penerimaan.fromJsson(Map<String, dynamic> json) {
    return Penerimaan(
      id: json['id'],
      id_encrypt: json['id_encrypt'],
      nopu: json['nopu'],
      tgl_pu: json['tgl_pu'],
      tgljthtempo: json['tgljthtempo'],
      nopo: json['nopo'],
      tgl_po : json['tgl_po'],
      supplier_id : json['supplier_id'],
      supplier : json['supplier'],
      subtotal : json['subtotal'],
      ppn : json['ppn'],
      grandtotal : json['grandtotal'],
      nonota : json['nonota'],
      noinvcust : json['noinvcust'],
      tglinvcust : json['tglinvcust'],
    );
  }
}

class PenerimaanDetail {
  String? id;
  String? produk_id;
  String? namaproduk;
  String? satuan_produk;
  String? harga;
  String? qty;
  String? jumlah;

  PenerimaanDetail({
    this.id,
    this.produk_id,
    this.namaproduk,
    this.satuan_produk,
    this.harga,
    this.qty,
    this.jumlah
  });

  factory PenerimaanDetail.fromJsson(Map<String, dynamic> json) {
    return PenerimaanDetail(
      id: json['id'],
      produk_id: json['produk_id'],
      namaproduk: json['namaproduk'],
      satuan_produk: json['satuan_produk'],
      harga: json['harga'],
      qty: json['qty'],
      jumlah : json['jumlah']
    );
  }
}