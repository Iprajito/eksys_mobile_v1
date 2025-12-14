class ProdukKategori {
  String? id;
  String? kategori;
  String? items;

  ProdukKategori({this.id, this.kategori, this.items});

  // Factory method to convert JSON to object
  factory ProdukKategori.fromJson(Map<String, dynamic> json) {
    return ProdukKategori(
      id: json['id'], kategori: json['kategori'], items: json['items']
    );
  }
}

class ProdukKategoriModel {
  final List<ProdukKategori> posts;

  ProdukKategoriModel({ required this.posts});

  factory ProdukKategoriModel.fromJson(Map<String, dynamic> json) {
    var postsList = json['data'] as List;

    List<ProdukKategori> posts = postsList.map((i) => ProdukKategori.fromJson(i)).toList();

    return ProdukKategoriModel(posts: posts);
  }
}
