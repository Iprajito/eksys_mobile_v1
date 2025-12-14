class Produk {
  String? id;
  String? kategoriId;
  String? kategori;
  String? menu;
  String? harga;

  Produk({this.id, this.kategoriId, this.kategori, this.menu, this.harga});

  // Factory method to convert JSON to object
  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      id: json['id'], kategoriId: json['kategori_id'], kategori: json['kategori'], menu: json['menu'], harga: json['harga']
    );
  }
}

class ProdukModel {
  final List<Produk> posts;

  ProdukModel({ required this.posts});

  factory ProdukModel.fromJson(Map<String, dynamic> json) {
    var postsList = json['data'] as List;

    List<Produk> posts = postsList.map((i) => Produk.fromJson(i)).toList();

    return ProdukModel(posts: posts);
  }
}
