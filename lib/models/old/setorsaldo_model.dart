class SetorSaldoNota {
  String? newnota;

  SetorSaldoNota({this.newnota});

  // Factory method to convert JSON to object
  factory SetorSaldoNota.fromJson(Map<String, dynamic> json) {
    return SetorSaldoNota(newnota: json['newnota']);
  }
}

class SetorSaldo {
  String? id;
  String? nota;
  String? tgl;
  String? nilai;

  SetorSaldo({this.id, this.nota, this.tgl, this.nilai});

  // Factory method to convert JSON to object
  factory SetorSaldo.fromJson(Map<String, dynamic> json) {
    return SetorSaldo(
        id: json['id'],
        nota: json['nota'],
        tgl: json['tgl'],
        nilai: json['nilai']);
  }
}

class SetorSaldoModel {
  final List<SetorSaldoNota> heads;
  final List<SetorSaldo> posts;

  SetorSaldoModel({required this.heads, required this.posts});

  factory SetorSaldoModel.fromJson(Map<String, dynamic> json) {
    var headList = json['data']['header'] as List;
    var postsList = json['data']['items'] as List;

    List<SetorSaldoNota> heads = headList.map((i) => SetorSaldoNota.fromJson(i)).toList();
    List<SetorSaldo> posts = postsList.map((i) => SetorSaldo.fromJson(i)).toList();

    return SetorSaldoModel(heads: heads, posts: posts);
  }
}
