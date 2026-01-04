class PembelianModel {
  final List<Pembelian> data;
  // final List<PembelianProduct> product;

  PembelianModel({required this.data});

  factory PembelianModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;
    // var dataproduct = json['data']['product'] as List;

    List<Pembelian> data = datas.map((i) => Pembelian.fromJsson(i)).toList();
    // List<PembelianProduct> product = dataproduct.map((i) => PembelianProduct.fromJsson(i)).toList();
    return PembelianModel(data: data);
  }
}

class PembelianDetailModel {
  final List<PembelianDetail> data;

  PembelianDetailModel({required this.data});

  factory PembelianDetailModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<PembelianDetail> data =
        datas.map((i) => PembelianDetail.fromJsson(i)).toList();
    return PembelianDetailModel(data: data);
  }
}

class PembelianNopoModel {
  final List<PembelianNopo> data;

  PembelianNopoModel({required this.data});

  factory PembelianNopoModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<PembelianNopo> data =
        datas.map((i) => PembelianNopo.fromJsson(i)).toList();
    return PembelianNopoModel(data: data);
  }
}

class TempPembelianDetailModel {
  final List<TempPembelianDetail> data;
  final List<TempPembelianSummary> summary;

  TempPembelianDetailModel({required this.data, required this.summary});

  factory TempPembelianDetailModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;
    var summaries = json['summary'] as List;

    List<TempPembelianDetail> data = datas.map((i) => TempPembelianDetail.fromJsson(i)).toList();
    List<TempPembelianSummary> summary = summaries.map((i) => TempPembelianSummary.fromJsson(i)).toList();
    return TempPembelianDetailModel(data: data, summary: summary);
  }
}

class FormPembelianDetail {
  String userid;
  String produkid;
  String harga;
  String qty;
  String satuan;
  String jumlah;
  String fee;

  FormPembelianDetail(
      {required this.userid,
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

class PembelianVAModel {
  final List<PembelianVA> data;

  PembelianVAModel({required this.data});

  factory PembelianVAModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<PembelianVA> data =
        datas.map((i) => PembelianVA.fromJsson(i)).toList();
    return PembelianVAModel(data: data);
  }
}

class Pembelian {
  String? id;
  String? idencrypt;
  String? nopo;
  String? tglpo;
  String? supplierid;
  String? supplier;
  String? subtotal;
  String? diskon;
  String? ppn;
  String? transaksifee;
  String? grandtotal;
  String? keterangan;
  String? tipeppn;
  String? tipe_ppn;
  String? id_syaratbayar;
  String? syaratbayar;
  String? ispu;
  String? status;
  String? jumlahdp;
  String? item;
  String? qty;
  String? metode_bayar;
  String? tgl_dp;
  String? tgl_sj;
  String? tgl_pu;
  String? nomor_si;
  String? nomor_sj;
  List<PembelianProduct>? product;

  Pembelian(
      {this.id,
      this.idencrypt,
      this.nopo,
      this.tglpo,
      this.supplierid,
      this.supplier,
      this.subtotal,
      this.diskon,
      this.ppn,
      this.transaksifee,
      this.grandtotal,
      this.keterangan,
      this.tipeppn,
      this.tipe_ppn,
      this.id_syaratbayar,
      this.syaratbayar,
      this.ispu,
      this.status,
      this.jumlahdp,
      this.item,
      this.qty,
      this.metode_bayar,
      this.tgl_dp,
      this.tgl_sj,
      this.tgl_pu,
      this.nomor_si,
      this.nomor_sj,
      this.product
    });

  factory Pembelian.fromJsson(Map<String, dynamic> json) {
    return Pembelian(
        id: json['id'],
        idencrypt: json['id_encrypt'],
        nopo: json['nopo'],
        tglpo: json['tgl_po'],
        supplierid: json['supplier_id'],
        supplier: json['supplier'],
        subtotal: json['subtotal'],
        diskon: json['diskon'],
        ppn: json['ppn'],
        transaksifee: json['transaksi_fee'],
        grandtotal: json['grandtotal'],
        keterangan: json['keterangan'],
        tipeppn: json['tipeppn'],
        tipe_ppn: json['tipe_ppn'],
        id_syaratbayar: json['id_syaratbayar'],
        syaratbayar: json['syaratbayar'],
        ispu: json['is_pu'],
        status: json['status'],
        jumlahdp: json['jumlah_dp'],
        item: json['item'],
        qty: json['qty'],
        metode_bayar: json['metode_bayar'],
        tgl_dp: json['tgl_dp'],
        tgl_sj: json['tgl_sj'],
        tgl_pu: json['tgl_pu'],
        nomor_si: json['nomor_si'],
        nomor_sj: json['nomor_sj'],
        product: (json['product'] as List<dynamic>?)?.map((e) => PembelianProduct.fromJsson(e)).toList() ??[],
    );
  }
}

class PembelianDetail {
  String? id;
  String? idencrypt;
  String? nopo;
  String? pelanggan;
  String? produkid;
  String? namaproduk;
  String? qty;
  String? satuanproduk;
  String? harga;
  String? jumlah;
  String? image;

  PembelianDetail(
      {this.id,
      this.idencrypt,
      this.nopo,
      this.pelanggan,
      this.produkid,
      this.namaproduk,
      this.qty,
      this.satuanproduk,
      this.harga,
      this.jumlah,
      this.image});

  factory PembelianDetail.fromJsson(Map<String, dynamic> json) {
    return PembelianDetail(
      id: json['id'],
      idencrypt: json['id_encrypt'],
      nopo: json['nopo'],
      pelanggan: json['pelanggan'],
      produkid: json['produk_id'],
      namaproduk: json['namaproduk'],
      qty: json['qty'],
      satuanproduk: json['satuan_produk'],
      harga: json['harga'],
      jumlah: json['jumlah'],
      image: json['image'],
    );
  }
}

class PembelianNopo {
  String? nopo;

  PembelianNopo({this.nopo});

  factory PembelianNopo.fromJsson(Map<String, dynamic> json) {
    return PembelianNopo(nopo: json['nopo']);
  }
}

class TempPembelianDetail {
  String? id;
  String? produkid;
  String? namaproduk;
  String? qty;
  String? satuanproduk;
  String? harga;
  String? jumlah;
  String? fee;
  String? image;

  TempPembelianDetail(
      {this.id,
      this.produkid,
      this.namaproduk,
      this.qty,
      this.satuanproduk,
      this.harga,
      this.jumlah,
      this.fee,
      this.image
    });

  factory TempPembelianDetail.fromJsson(Map<String, dynamic> json) {
    return TempPembelianDetail(
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

class TempPembelianSummary {
  String? item;
  String? qty;
  String? subtotal;
  String? dp_prosen;
  String? nominal_dp;
  String? fee;
  String? biaya_layanan;
  String? grandtotal;
  String? grandtotal_nondp;

  TempPembelianSummary({
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

  factory TempPembelianSummary.fromJsson(Map<String, dynamic> json) {
    return TempPembelianSummary(
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

class PembelianVA {
  String? trx_id;
  String? nopo;
  String? virtual_account_no;
  String? virtual_account_name;
  String? total_amount;
  String? expired_date;
  String? bank;

  PembelianVA(
      {this.trx_id,this.nopo,
      this.virtual_account_no,
      this.virtual_account_name,
      this.total_amount,
      this.expired_date,
      this.bank
    });

  factory PembelianVA.fromJsson(Map<String, dynamic> json) {
    return PembelianVA(
      trx_id: json['trx_id'],
      nopo: json['nopo'],
      virtual_account_no: json['virtual_account_no'],
      virtual_account_name: json['virtual_account_name'],
      total_amount: json['total_amount'],
      expired_date: json['expired_date'],
      bank: json['bank']
    );
  }
}

class PembelianProduct {
  String? id;
  String? namaproduk;
  String? satuan_produk;
  String? qty;
  String? harga;
  String? image;

  PembelianProduct(
      {this.id,this.namaproduk,
      this.satuan_produk,
      this.qty,
      this.harga,
      this.image
    });

  factory PembelianProduct.fromJsson(Map<String, dynamic> json) {
    return PembelianProduct(
      id: json['id'],
      namaproduk: json['namaproduk'],
      satuan_produk: json['satuan_produk'],
      qty: json['qty'],
      harga: json['harga'],
      image: json['image']
    );
  }
}