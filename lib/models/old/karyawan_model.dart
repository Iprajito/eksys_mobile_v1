class Karyawan {
  String? id;
  String? nama;
  String? alamat;
  String? alamatdomisili;
  String? telepon;
  String? kontak;
  String? tglbergabung;

  Karyawan({this.id, this.nama, this.alamat, this.alamatdomisili, this.telepon, this.kontak, this.tglbergabung});

  // Factory method to convert JSON to object
  factory Karyawan.fromJson(Map<String, dynamic> json) {
    return Karyawan(
      id: json['id'], 
      nama: json['nama'], 
      alamat: json['alamat'],
      alamatdomisili: json['alamat_domisili'],
      telepon: json['telepon'],
      kontak: json['kontak'],
      tglbergabung: json['tgl_bergabung']
    );
  }
}

class KaryawanModel {
  final List<Karyawan> posts;

  KaryawanModel({ required this.posts});

  factory KaryawanModel.fromJson(Map<String, dynamic> json) {
    var postsList = json['data'] as List;

    List<Karyawan> posts = postsList.map((i) => Karyawan.fromJson(i)).toList();

    return KaryawanModel(posts: posts);
  }
}
