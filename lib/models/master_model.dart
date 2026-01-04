class SupplierModel {
  final List<Supplier> data;

  SupplierModel({required this.data});

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<Supplier> data = datas.map((i) => Supplier.fromJsson(i)).toList();
    return SupplierModel(data: data);
  }
}

class PelangganModel {
  final List<Pelanggan> data;

  PelangganModel({required this.data});

  factory PelangganModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<Pelanggan> data = datas.map((i) => Pelanggan.fromJsson(i)).toList();
    return PelangganModel(data: data);
  }

  @override
  String toString() {
    return 'PelangganModel{data: ${data.map((e) => e.toString()).toList()}}';
  }
}

class ProdukModel {
  final List<Produk> data;

  ProdukModel({required this.data});

  factory ProdukModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<Produk> data = datas.map((i) => Produk.fromJsson(i)).toList();

    return ProdukModel(data: data);
  }
}

class MetodeBayarBankModel {
  final List<MetodeBayar> data;

  MetodeBayarBankModel({required this.data});

  factory MetodeBayarBankModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<MetodeBayar> data =
        datas.map((i) => MetodeBayar.fromJsson(i)).toList();

    return MetodeBayarBankModel(data: data);
  }
}

class MetodeBayarAgenModel {
  final List<MetodeBayar> data;

  MetodeBayarAgenModel({required this.data});

  factory MetodeBayarAgenModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<MetodeBayar> data =
        datas.map((i) => MetodeBayar.fromJsson(i)).toList();

    return MetodeBayarAgenModel(data: data);
  }
}

class WilayahModel {
  final List<Wilayah> data;

  WilayahModel({required this.data});

  factory WilayahModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List? ?? [];
    List<Wilayah> data = datas.map((i) => Wilayah.fromJson(i)).toList();

    return WilayahModel(data: data);
  }
}

class AnggotaModel {
  final List<Anggota> data;

  AnggotaModel({required this.data});

  factory AnggotaModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List? ?? [];
    List<Anggota> data = datas.map((i) => Anggota.fromJsson(i)).toList();

    return AnggotaModel(data: data);
  }
}

class SubscribeModel {
  final List<Subscribe> data;

  SubscribeModel({required this.data});

  factory SubscribeModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List? ?? [];
    List<Subscribe> data = datas.map((i) => Subscribe.fromJsson(i)).toList();

    return SubscribeModel(data: data);
  }
}

class Supplier {
  String? id;
  String? idencrypt;
  String? channel;
  String? supplier;
  String? telepon;
  String? alamat;
  String? tipeppn;
  String? tipe_ppn;
  String? id_syaratbayar;
  String? syaratbayar;

  Supplier(
      {this.id,
      this.idencrypt,
      this.supplier,
      this.telepon,
      this.alamat,
      this.tipeppn,
      this.tipe_ppn,
      this.id_syaratbayar,
      this.syaratbayar});

  factory Supplier.fromJsson(Map<String, dynamic> json) {
    return Supplier(
        id: json['id'],
        idencrypt: json['id_encrypt'],
        supplier: json['supplier'],
        telepon: json['telepon'],
        alamat: json['alamat'],
        tipeppn: json['tipeppn'],
        tipe_ppn: json['tipe_ppn'],
        id_syaratbayar: json['id_syaratbayar'],
        syaratbayar: json['syaratbayar']);
  }
}

class Pelanggan {
  String? id;
  String? idencrypt;
  String? tipe_pelanggan;
  String? tgl_daftar;
  String? nik;
  String? nama;
  String? nomor_kta;
  String? nama_instansi;
  String? tgl_lahir;
  String? kota_lahir;
  String? telepon;
  String? email;
  String? alamat;
  String? is_dompetku;
  String? va_dompetku;
  String? id_syaratbayar;
  String? tipeppn;
  String? start_subscribe;
  String? end_subscribe;
  String? upline_id;
  String? file_ktp;
  String? file_photo;

  Pelanggan(
      {this.id,
      this.idencrypt,
      this.tipe_pelanggan,
      this.tgl_daftar,
      this.nik,
      this.nama,
      this.nomor_kta,
      this.nama_instansi,
      this.tgl_lahir,
      this.kota_lahir,
      this.telepon,
      this.email,
      this.alamat,
      this.is_dompetku,
      this.va_dompetku,
      this.id_syaratbayar,
      this.tipeppn,
      this.start_subscribe,
      this.end_subscribe,
      this.upline_id,
      this.file_ktp,
      this.file_photo});

  factory Pelanggan.fromJsson(Map<String, dynamic> json) {
    return Pelanggan(
        id: json['id'],
        idencrypt: json['id_encrypt'],
        tipe_pelanggan: json['tipe_pelanggan'],
        tgl_daftar: json['tgl_daftar'],
        nik: json['nik'],
        nama: json['nama'],
        nomor_kta: json['nomor_kta'],
        nama_instansi: json['nama_instansi'],
        tgl_lahir: json['tgl_lahir'],
        kota_lahir: json['kota_lahir'],
        telepon: json['telepon'],
        email: json['email'],
        alamat: json['alamat'],
        is_dompetku: json['is_dompetku'],
        va_dompetku: json['va_dompetku'],
        id_syaratbayar: json['id_syaratbayar'],
        tipeppn: json['tipeppn'],
        start_subscribe: json['start_subscribe'],
        end_subscribe: json['end_subscribe'],
        upline_id: json['upline_id'],
        file_ktp: json['file_ktp'],
        file_photo: json['file_photo']);
  }

  @override
  String toString() {
    return 'Pelanggan{id: $id, idencrypt: $idencrypt, tipe_pelanggan: $tipe_pelanggan, tgl_daftar: $tgl_daftar, nik: $nik, nama: $nama, nomor_kta: $nomor_kta, nama_instansi: $nama_instansi, tgl_lahir: $tgl_lahir, kota_lahir: $kota_lahir, telepon: $telepon, email: $email, alamat: $alamat, is_dompetku: $is_dompetku, va_dompetku: $va_dompetku, id_syaratbayar: $id_syaratbayar, tipeppn: $tipeppn, start_subscribe: $start_subscribe, end_subscribe: $end_subscribe, upline_id: $upline_id, file_ktp: $file_ktp, file_photo: $file_photo}';
  }
}

class MetodeBayar {
  String? id;
  String? channel;
  String? image;
  String? institusi;
  String? tipe;

  MetodeBayar({this.id, this.channel, this.image, this.institusi, this.tipe});

  factory MetodeBayar.fromJsson(Map<String, dynamic> json) {
    return MetodeBayar(
        id: json['id'],
        channel: json['channel'],
        image: json['image'],
        institusi: json['institusi'],
        tipe: json['tipe_channel']);
  }
}

class Produk {
  String? id;
  String? namaproduk;
  String? hargabeli;
  String? satuan;
  String? transaksi_fee;
  String? hrg_distributor;
  String? hrg_agen;
  String? hrg_reseller;
  String? hrg_nonmember;
  String? image;

  Produk(
      {this.id,
      this.namaproduk,
      this.hargabeli,
      this.satuan,
      this.transaksi_fee,
      this.hrg_distributor,
      this.hrg_agen,
      this.hrg_reseller,
      this.hrg_nonmember,
      this.image,
  });

  factory Produk.fromJsson(Map<String, dynamic> json) {
    return Produk(
      id: json['id'],
      namaproduk: json['namaproduk'],
      hargabeli: json['hargabeli'],
      satuan: json['satuan'],
      transaksi_fee: json['transaksi_fee'],
      hrg_distributor: json['hrg_distributor'],
      hrg_agen: json['hrg_agen'],
      hrg_reseller: json['hrg_reseller'],
      hrg_nonmember: json['hrg_nonmember'],
      image: json['image'],
    );
  }
}

class Wilayah {
  String? id;
  String? nama;
  List<Wilayah> child;

  Wilayah({this.id, this.nama, this.child = const []});

  factory Wilayah.fromJson(Map<String, dynamic> json) {
    return Wilayah(
      id: json['id']?.toString(),
      nama: json['nama'],
      child: (json['child'] != null)
          ? (json['child'] as List).map((c) => Wilayah.fromJson(c)).toList()
          : [],
    );
  }
}

class Anggota {
  String? id;
  String? nama;
  String? wilayah;

  Anggota({this.id, this.nama, this.wilayah});

  factory Anggota.fromJsson(Map<String, dynamic> json) {
    return Anggota(
        id: json['id'], nama: json['nama'], wilayah: json['wilayah']);
  }
}

class Subscribe {
  String? id;
  String? id_encrypt;
  String? subscribe;
  String? harga;
  String? expr;
  String? unit;

  Subscribe({this.id, this.id_encrypt, this.subscribe, this.harga, this.expr, this.unit});

  factory Subscribe.fromJsson(Map<String, dynamic> json) {
    return Subscribe(
      id: json['id'], 
      id_encrypt: json['id_encrypt'],
      subscribe: json['subscribe'], 
      harga: json['harga'],
      expr: json['expr'],
      unit: json['unit']
    );
  }
}
