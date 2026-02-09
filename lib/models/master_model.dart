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

class PelangganAlamatModel {
  final List<PelangganAlamat> data;

  PelangganAlamatModel({required this.data});

  factory PelangganAlamatModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<PelangganAlamat> data = datas.map((i) => PelangganAlamat.fromJsson(i)).toList();
    return PelangganAlamatModel(data: data);
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
  String? kode_pelanggan;
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
  String? saldo;
  String? nama_penerima;
  String? telepon_penerima;
  String? alamat_kirim1;
  String? alamat_kirim2;
  String? anggota;

  Pelanggan(
      {this.id,
      this.idencrypt,
      this.kode_pelanggan,
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
      this.file_photo,
      this.saldo,
      this.nama_penerima,
      this.telepon_penerima,
      this.alamat_kirim1,
      this.alamat_kirim2,
      this.anggota
  });

  factory Pelanggan.fromJsson(Map<String, dynamic> json) {
    return Pelanggan(
        id: json['id'],
        idencrypt: json['id_encrypt'],
        kode_pelanggan: json['kode_pelanggan'],
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
        file_photo: json['file_photo'],
        saldo: json['saldo'],
        nama_penerima: json['nama_penerima'],
        telepon_penerima: json['telepon_penerima'],
        alamat_kirim1: json['alamat_kirim1'],
        alamat_kirim2: json['alamat_kirim2'],
        anggota: json['anggota']
    );
  }

  @override
  String toString() {
    return 'Pelanggan{id: $id, idencrypt: $idencrypt, kode_pelanggan: $kode_pelanggan, tipe_pelanggan: $tipe_pelanggan, tgl_daftar: $tgl_daftar, nik: $nik, nama: $nama, nomor_kta: $nomor_kta, nama_instansi: $nama_instansi, tgl_lahir: $tgl_lahir, kota_lahir: $kota_lahir, telepon: $telepon, email: $email, alamat: $alamat, is_dompetku: $is_dompetku, va_dompetku: $va_dompetku, id_syaratbayar: $id_syaratbayar, tipeppn: $tipeppn, start_subscribe: $start_subscribe, end_subscribe: $end_subscribe, upline_id: $upline_id, file_ktp: $file_ktp, file_photo: $file_photo,saldo:$saldo, nama_penerima:$nama_penerima, telepon_penerima:$telepon_penerima, alamat_kirim1:$alamat_kirim1, alamat_kirim2:$alamat_kirim2, anggota:$anggota}';
  }
}

class PelangganAlamat {
  String? id;
  String? nama_penerima;
  String? telepon_penerima;
  String? alamat_kirim1;
  String? alamat_kirim2;
  String? prim_address;

  PelangganAlamat({this.id, this.nama_penerima, this.telepon_penerima, this.alamat_kirim1, this.alamat_kirim2, this.prim_address});

  factory PelangganAlamat.fromJsson(Map<String, dynamic> json) {
    return PelangganAlamat(
        id: json['id'], nama_penerima: json['nama_penerima'], telepon_penerima: json['telepon_penerima'], alamat_kirim1: json['alamat_kirim1'], alamat_kirim2: json['alamat_kirim2'], prim_address: json['prim_address']);
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

class ProvinsiModel {
  final List<Provinsi> data;

  ProvinsiModel({required this.data});

  factory ProvinsiModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<Provinsi> data = datas.map((i) => Provinsi.fromJson(i)).toList();
    return ProvinsiModel(data: data);
  }
}

class Provinsi {
  String? id;
  String? provinsi;

  Provinsi({this.id, this.provinsi});

  factory Provinsi.fromJson(Map<String, dynamic> json) {
    return Provinsi(
      id: json['id'],
      provinsi: json['provinsi'],
    );
  }
}
class KabKotaModel {
  final List<KabKota> data;

  KabKotaModel({required this.data});

  factory KabKotaModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<KabKota> data = datas.map((i) => KabKota.fromJson(i)).toList();
    return KabKotaModel(data: data);
  }
}

class KabKota {
  String? id;
  String? provinsiId;
  String? kabkota;

  KabKota({this.id, this.provinsiId, this.kabkota});

  factory KabKota.fromJson(Map<String, dynamic> json) {
    return KabKota(
      id: json['id'],
      provinsiId: json['provinsi_id'],
      kabkota: json['kota'],
    );
  }
}
class KecamatanModel {
  final List<Kecamatan> data;

  KecamatanModel({required this.data});

  factory KecamatanModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<Kecamatan> data = datas.map((i) => Kecamatan.fromJson(i)).toList();
    return KecamatanModel(data: data);
  }
}

class Kecamatan {
  String? id;
  String? kotaId;
  String? kecamatan;

  Kecamatan({this.id, this.kotaId, this.kecamatan});

  factory Kecamatan.fromJson(Map<String, dynamic> json) {
    return Kecamatan(
      id: json['id'],
      kotaId: json['kota_id'],
      kecamatan: json['kecamatan'],
    );
  }
}
class KelurahanModel {
  final List<Kelurahan> data;

  KelurahanModel({required this.data});

  factory KelurahanModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<Kelurahan> data = datas.map((i) => Kelurahan.fromJson(i)).toList();
    return KelurahanModel(data: data);
  }
}

class Kelurahan {
  String? id;
  String? kecamatanId;
  String? kelurahan;

  Kelurahan({this.id, this.kecamatanId, this.kelurahan});

  factory Kelurahan.fromJson(Map<String, dynamic> json) {
    return Kelurahan(
      id: json['id'],
      kecamatanId: json['kecamatan_id'],
      kelurahan: json['kelurahan'],
    );
  }
}
class KodePosModel {
  final List<KodePos> data;

  KodePosModel({required this.data});

  factory KodePosModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<KodePos> data = datas.map((i) => KodePos.fromJson(i)).toList();
    return KodePosModel(data: data);
  }
}

class KodePos {
  String? kodePos;

  KodePos({this.kodePos});

  factory KodePos.fromJson(Map<String, dynamic> json) {
    return KodePos(
      kodePos: json['kodepos'],
    );
  }
}
