class PenjualanNosoModel {
  final List<PenjualanNoso> data;

  PenjualanNosoModel({required this.data});

  factory PenjualanNosoModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<PenjualanNoso> data =
        datas.map((i) => PenjualanNoso.fromJsson(i)).toList();
    return PenjualanNosoModel(data: data);
  }
}

class CustomerModel {
  final List<Customer> data;

  CustomerModel({required this.data});

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<Customer> data =
        datas.map((i) => Customer.fromJsson(i)).toList();
    return CustomerModel(data: data);
  }
}

class CustomerPOModel {
  final List<CustomerPO> data;

  CustomerPOModel({required this.data});

  factory CustomerPOModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<CustomerPO> data =
        datas.map((i) => CustomerPO.fromJsson(i)).toList();
    return CustomerPOModel(data: data);
  }
}

class PenjualanModel {
  final List<Penjualan> data;

  PenjualanModel({required this.data});

  factory PenjualanModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<Penjualan> data =
        datas.map((i) => Penjualan.fromJsson(i)).toList();
    return PenjualanModel(data: data);
  }
}

class PenjualanDetailModel {
  final List<PenjualanDetail> data;

  PenjualanDetailModel({required this.data});

  factory PenjualanDetailModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<PenjualanDetail> data =
        datas.map((i) => PenjualanDetail.fromJsson(i)).toList();
    return PenjualanDetailModel(data: data);
  }
}
// =============== //
class PenjualanNoso {
  String? noso;

  PenjualanNoso({this.noso});

  factory PenjualanNoso.fromJsson(Map<String, dynamic> json) {
    return PenjualanNoso(noso: json['noso']);
  }
}

class Customer {
  String? id;
  String? id_encrypt;
  String? tgl_daftar;
  String? nik;
  String? nama;
  String? telepon;
  String? email;
  String? alamat;
  String? tipeppn;
  String? tipe_pelanggan;
  String? tipe_ppn;
  String? id_syaratbayar;
  String? syaratbayar;

  Customer({
    this.id,
    this.id_encrypt,
    this.tgl_daftar,
    this.nik,
    this.nama,
    this.telepon,
    this.email,
    this.alamat,
    this.tipeppn,
    this.tipe_pelanggan,
    this.tipe_ppn,
    this.id_syaratbayar,
    this.syaratbayar,
  });

  factory Customer.fromJsson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      id_encrypt: json['id_encrypt'],
      tgl_daftar: json['tgl_daftar'],
      nik: json['nik'],
      nama: json['nama'],
      telepon: json['telepon'],
      email: json['email'],
      alamat: json['alamat'],
      tipeppn: json['tipeppn'],
      tipe_pelanggan: json['tipe_pelanggan'],
      tipe_ppn: json['tipe_ppn'],
      syaratbayar: json['id_syaratbayar'],
      id_syaratbayar: json['syaratbayar'],
    );
  }
}

class CustomerPO {
  String? id;
  String? nopo;
  String? tgl_po;
  String? pelanggan_id;
  String? pelanggan;
  String? telepon;
  String? email;
  String? alamat;
  String? tipeppn;
  String? tipe_pelanggan;
  String? tipe_ppn;
  String? id_syaratbayar;
  String? syaratbayar;

  CustomerPO({
    this.id,
    this.nopo,
    this.tgl_po,
    this.pelanggan_id,
    this.pelanggan,
    this.telepon,
    this.email,
    this.alamat,
    this.tipeppn,
    this.tipe_pelanggan,
    this.tipe_ppn,
    this.id_syaratbayar,
    this.syaratbayar,
  });

  factory CustomerPO.fromJsson(Map<String, dynamic> json) {
    return CustomerPO(
      id: json['id'],
      nopo: json['nopo'],
      tgl_po: json['tgl_po'],
      pelanggan_id: json['pelanggan_id'],
      pelanggan: json['pelanggan'],
      telepon: json['telepon'],
      email: json['email'],
      alamat: json['alamat'],
      tipeppn: json['tipeppn'],
      tipe_pelanggan: json['tipe_pelanggan'],
      tipe_ppn: json['tipe_ppn'],
      syaratbayar: json['id_syaratbayar'],
      id_syaratbayar: json['syaratbayar'],
    );
  }
}

class Penjualan {
  String? id;
  String? id_encrypt;
  String? nomor_so;
  String? tgl_so;
  String? pembelian_nopo;
  String? pembelian_tglpo;
  String? pelanggan_id;
  String? pelanggan;
  String? jumlah_dp;
  String? subtotal;
  String? ppn;
  String? grandtotal;
  String? keterangan;
  String? status;
  String? transaksi_fee;
  String? item;
  String? qty;

  Penjualan({
    this.id,
    this.id_encrypt,
    this.nomor_so,
    this.tgl_so,
    this.pembelian_nopo,
    this.pembelian_tglpo,
    this.pelanggan_id,
    this.pelanggan,
    this.jumlah_dp,
    this.subtotal,
    this.ppn,
    this.grandtotal,
    this.keterangan,
    this.status,
    this.transaksi_fee,
    this.item,
    this.qty,
  });

  factory Penjualan.fromJsson(Map<String, dynamic> json) {
    return Penjualan(
      id: json['id'],
      id_encrypt: json['id_encrypt'],
      nomor_so: json['nomor_so'],
      tgl_so: json['tgl_so'],
      pembelian_nopo: json['pembelian_nopo'],
      pembelian_tglpo: json['pembelian_tglpo'],
      pelanggan_id: json['pelanggan_id'],
      pelanggan: json['pelanggan'],
      jumlah_dp: json['jumlah_dp'],
      subtotal: json['subtotal'],
      ppn: json['ppn'],
      grandtotal: json['grandtotal'],
      keterangan: json['keterangan'],
      status: json['status'],
      transaksi_fee: json['transaksi_fee'],
      item: json['item'],
      qty: json['qty'],
    );
  }
}

class PenjualanDetail {
  String? id;
  String? namaproduk;
  String? qty;
  String? satuanproduk;
  String? hrgjualSatuan;
  String? jumlah;

  PenjualanDetail(
      {this.id,
      this.namaproduk,
      this.qty,
      this.satuanproduk,
      this.hrgjualSatuan,
      this.jumlah});

  factory PenjualanDetail.fromJsson(Map<String, dynamic> json) {
    return PenjualanDetail(
      id: json['id'],
      namaproduk: json['namaproduk'],
      qty: json['qty'],
      satuanproduk: json['satuan_produk'],
      hrgjualSatuan: json['hrgjualSatuan'],
      jumlah: json['jumlah'],
    );
  }
}

class FormPenjualanDetail {
  String userid;
  String produkid;
  String harga;
  String qty;
  String satuan;
  String jumlah;
  String fee;

  FormPenjualanDetail({
    required this.userid,
    required this.produkid,
    required this.harga,
    required this.qty,
    required this.satuan,
    required this.jumlah,
    required this.fee
  });

  Map<String, dynamic> toJson() => {
    'userid': userid,
    'produkid': produkid,
    'harga': harga,
    'qty': qty,
    'satuan': satuan,
    'jumlah': jumlah,
    'fee': fee,
  };
}

class TempPenjualanDetailModel {
  final List<TempPenjualanDetail> data;
  final List<TempPenjualanSummary> summary;

  TempPenjualanDetailModel({required this.data, required this.summary});

  factory TempPenjualanDetailModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;
    var summaries = json['summary'] as List;

    List<TempPenjualanDetail> data = datas.map((i) => TempPenjualanDetail.fromJsson(i)).toList();
    List<TempPenjualanSummary> summary = summaries.map((i) => TempPenjualanSummary.fromJsson(i)).toList();
    return TempPenjualanDetailModel(data: data, summary: summary);
  }
}

class TempPenjualanDetail {
  String? id;
  String? produkid;
  String? namaproduk;
  String? qty;
  String? satuanproduk;
  String? harga;
  String? jumlah;
  String? fee;
  String? image;

  TempPenjualanDetail(
      {this.id,
      this.produkid,
      this.namaproduk,
      this.qty,
      this.satuanproduk,
      this.harga,
      this.jumlah,
      this.fee,
      this.image,
    });

  factory TempPenjualanDetail.fromJsson(Map<String, dynamic> json) {
    return TempPenjualanDetail(
      id: json['id'],
      produkid: json['produk_id'],
      namaproduk: json['namaproduk'],
      qty: json['qty'],
      satuanproduk: json['satuan_produk'],
      harga: json['harga'],
      jumlah: json['jumlah'],
      fee: json['fee'],
      image: json['image'],
    );
  }
}

class TempPenjualanSummary {
  String? item;
  String? qty;
  String? subtotal;
  String? dp_prosen;
  String? nominal_dp;
  String? fee;
  String? biaya_layanan;
  String? grandtotal;
  String? grandtotal_nondp;

  TempPenjualanSummary({
    this.item,
    this.qty,
    this.subtotal,
    this.dp_prosen,
    this.nominal_dp,
    this.fee,
    this.biaya_layanan,
    this.grandtotal,
    this.grandtotal_nondp
  });

  factory TempPenjualanSummary.fromJsson(Map<String, dynamic> json) {
    return TempPenjualanSummary(
      item: json['item'],
      qty: json['qty'],
      subtotal: json['subtotal'],
      dp_prosen: json['dp_prosen'],
      nominal_dp: json['nominal_dp'],
      fee: json['fee'],
      biaya_layanan: json['biaya_layanan'],
      grandtotal: json['grandtotal'],
      grandtotal_nondp: json['grandtotal_nondp'],
    );
  }
}
