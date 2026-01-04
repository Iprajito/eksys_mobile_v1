class StokBarangModel {
  final List<StokBarang> data;

  StokBarangModel({required this.data});

  factory StokBarangModel.fromJson(Map<String, dynamic> json) {
    var datas = json['data'] as List;

    List<StokBarang> data = datas.map((i) => StokBarang.fromJsson(i)).toList();
    return StokBarangModel(data: data);
  }
}

class StokBarang {
  String? id;
  String? namaproduk;
  String? stok;
  String? image;

  StokBarang({
    this.id,
    this.namaproduk,
    this.stok,
    this.image,
  });

  factory StokBarang.fromJsson(Map<String, dynamic> json) {
    return StokBarang(
      id: json['id'],
      namaproduk: json['namaproduk'],
      stok: json['stok'],
      image: json['image'],
    );
  }
}