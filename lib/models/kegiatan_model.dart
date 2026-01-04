class FormKegiatanDetail {
  String userid;
  String kegiatan_id;
  String wilayah_id;
  String anggota_id;

  FormKegiatanDetail({
    required this.userid,
    required this.kegiatan_id,
    required this.wilayah_id,
    required this.anggota_id
  });

  Map<String, dynamic> toJson() => {
    'userid': userid,
    'kegiatan_id': kegiatan_id,
    'wilayah_id': wilayah_id,
    'anggota_id': anggota_id
  };
}

class TempKegiatanDispacthModel {
  final List<TempKegiatanDispacth> data;

  TempKegiatanDispacthModel({required this.data});

  factory TempKegiatanDispacthModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<TempKegiatanDispacth> data =
        datas.map((i) => TempKegiatanDispacth.fromJsson(i)).toList();
    return TempKegiatanDispacthModel(data: data);
  }
}

class TempKegiatanDispacth {
  String? id;
  String? anggota;
  String? nama_wilayah;
  String? totanggota;

  TempKegiatanDispacth({
    this.id,
    this.anggota,
    this.nama_wilayah,
    this.totanggota,
  });

  factory TempKegiatanDispacth.fromJsson(Map<String, dynamic> json) {
    return TempKegiatanDispacth(
      id: json['id'],
      anggota: json['anggota'],
      nama_wilayah: json['nama_wilayah'],
      totanggota: json['totanggota'],
    );
  }
}

class KegiatanModel {
  final List<Kegiatan> data;

  KegiatanModel({required this.data});

  factory KegiatanModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<Kegiatan> data =
        datas.map((i) => Kegiatan.fromJsson(i)).toList();
    return KegiatanModel(data: data);
  }
}

class Kegiatan {
  String? id;
  String? creator_userid;
  String? creator;
  String? wilayah;
  String? tgl_kegiatan;
  String? jam_kegiatan;
  String? namakegiatan;
  String? aktifitas;
  String? lokasi;
  String? participant;
  String? status;
  String? is_hadir;
  String? notulensi;
  String? file_kegiatan;
  String? is_iuran;
  String? nominal_iuran;

  Kegiatan({
    this.id,
    this.creator_userid,
    this.creator,
    this.wilayah,
    this.tgl_kegiatan,
    this.jam_kegiatan,
    this.namakegiatan,
    this.aktifitas,
    this.lokasi,
    this.participant,
    this.status,
    this.is_hadir,
    this.notulensi,
    this.file_kegiatan,
    this.is_iuran,
    this.nominal_iuran,
  });

  factory Kegiatan.fromJsson(Map<String, dynamic> json) {
    return Kegiatan(
      id: json['id'],
      creator_userid: json['creator_userid'],
      creator: json['creator'],
      wilayah: json['wilayah'],
      tgl_kegiatan: json['tgl_kegiatan'],
      jam_kegiatan: json['jam_kegiatan'],
      namakegiatan: json['namakegiatan'],
      aktifitas: json['aktifitas'],
      lokasi: json['lokasi'],
      participant: json['participant'],
      status: json['status'],
      is_hadir: json['is_hadir'],
      notulensi: json['notulensi'],
      file_kegiatan: json['file_kegiatan'],
      is_iuran: json['is_iuran'],
      nominal_iuran: json['nominal_iuran'],
    );
  }
}

class KegiatanDispatchModel {
  final List<KegiatanDispacth> data;

  KegiatanDispatchModel({required this.data});

  factory KegiatanDispatchModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<KegiatanDispacth> data =
        datas.map((i) => KegiatanDispacth.fromJsson(i)).toList();
    return KegiatanDispatchModel(data: data);
  }
}

class KegiatanDispacth {
  String? id;
  String? anggota;
  String? nama_wilayah;
  String? totanggota;
  String? is_hadir;
  String? is_creator;

  KegiatanDispacth({
    this.id,
    this.anggota,
    this.nama_wilayah,
    this.totanggota,
    this.is_hadir,
    this.is_creator,
  });

  factory KegiatanDispacth.fromJsson(Map<String, dynamic> json) {
    return KegiatanDispacth(
      id: json['id'],
      anggota: json['anggota'],
      nama_wilayah: json['nama_wilayah'],
      totanggota: json['totanggota'],
      is_hadir: json['is_hadir'],
      is_creator: json['is_creator'],
    );
  }
}