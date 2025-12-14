class PembelianModel {
  final List<Pembelian> data;

  PembelianModel({required this.data});

  factory PembelianModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<Pembelian> data = datas.map((i) => Pembelian.fromJsson(i)).toList();
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
  String? syaratbayar;
  String? ispu;
  String? status;
  String? jumlahdp;
  String? item;
  String? qty;

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
      this.syaratbayar,
      this.ispu,
      this.status,
      this.jumlahdp,
      this.item,
      this.qty
    });

  factory Pembelian.fromJsson(Map<String, dynamic> json) {
    return Pembelian(
        id: json['id'],
        idencrypt: json['id_encrypt'],
        nopo: json['nopo'],
        tglpo: json['tgl_po'],
        supplierid: json['supplierid'],
        supplier: json['supplier'],
        subtotal: json['subtotal'],
        diskon: json['diskon'],
        ppn: json['ppn'],
        transaksifee: json['transaksi_fee'],
        grandtotal: json['grandtotal'],
        keterangan: json['keterangan'],
        tipeppn: json['tipeppn'],
        tipe_ppn: json['tipe_ppn'],
        syaratbayar: json['syaratbayar'],
        ispu: json['is_pu'],
        status: json['status'],
        jumlahdp: json['jumlah_dp'],
        item: json['item'],
        qty: json['qty']
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
      this.jumlah});

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

  TempPembelianDetail(
      {this.id,
      this.produkid,
      this.namaproduk,
      this.qty,
      this.satuanproduk,
      this.harga,
      this.jumlah,
      this.fee,
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