class Outlet {
  String? id;
  String? outlet;
  String? alamat;

  Outlet({this.id, this.outlet, this.alamat});

  // Factory method to convert JSON to object
  factory Outlet.fromJson(Map<String, dynamic> json) {
    return Outlet(
      id: json['id'], outlet: json['outlet'], alamat: json['alamat']
    );
  }
}

class OutletModel {
  final List<Outlet> posts;

  OutletModel({ required this.posts});

  factory OutletModel.fromJson(Map<String, dynamic> json) {
    var postsList = json['data'] as List;

    List<Outlet> posts = postsList.map((i) => Outlet.fromJson(i)).toList();

    return OutletModel(posts: posts);
  }
}
