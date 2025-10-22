class Material {
  String? id;
  String? material;
  String? satuan;
  String? keterangan;
  String? stok;

  Material({this.id, this.material, this.satuan, this.keterangan, this.stok});

  // Factory method to convert JSON to object
  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
        id: json['id'],
        material: json['material'],
        satuan: json['satuan'],
        keterangan: json['keterangan'],
        stok: json['stok']);
  }
}

class MaterialModel {
  final List<Material> posts;

  MaterialModel({required this.posts});

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    var postsList = json['data'] as List;
    List<Material> posts = postsList.map((i) => Material.fromJson(i)).toList();
    return MaterialModel(posts: posts);
  }
}

class Inventory {
  String? id;
  String? materialId;
  String? material;
  String? satuan;
  String? keterangan;
  String? tglRequest;
  String? qtySisa;
  String? tglSupply;
  String? qtySupply;
  String? tglHabis;
  String? status;

  Inventory(
      {this.id,
      this.materialId,
      this.material,
      this.satuan,
      this.keterangan,
      this.tglRequest,
      this.qtySisa,
      this.tglSupply,
      this.qtySupply,
      this.tglHabis,
      this.status});

  // Factory method to convert JSON to object
  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
        id: json['id'],
        materialId: json['material_id'],
        material: json['material'],
        satuan: json['satuan'],
        keterangan: json['keterangan'],
        tglRequest: json['tgl_request'],
        qtySisa: json['qty_sisa'],
        tglSupply: json['tgl_supply'],
        qtySupply: json['qty_supply'],
        tglHabis: json['tgl_habis'],
        status: json['status']);
  }
}

class InventoryModel {
  final List<Inventory> posts;

  InventoryModel({required this.posts});

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    var postsList = json['data'] as List;
    List<Inventory> posts =
        postsList.map((i) => Inventory.fromJson(i)).toList();
    return InventoryModel(posts: posts);
  }
}

class RequestInventory {
  String? id;
  String? materialId;
  String? material;
  String? satuan;
  String? keterangan;
  String? tglRequest;
  String? qtySisa;

  RequestInventory(
      {this.id,
      this.materialId,
      this.material,
      this.satuan,
      this.keterangan,
      this.tglRequest,
      this.qtySisa});

  // Factory method to convert JSON to object
  factory RequestInventory.fromJson(Map<String, dynamic> json) {
    return RequestInventory(
        id: json['id'],
        materialId: json['material_id'],
        material: json['material'],
        satuan: json['satuan'],
        keterangan: json['keterangan'],
        tglRequest: json['tgl_request'],
        qtySisa: json['qty_sisa']);
  }
}

class RequestInventoryModel {
  final List<RequestInventory> posts;

  RequestInventoryModel({required this.posts});

  factory RequestInventoryModel.fromJson(Map<String, dynamic> json) {
    var postsList = json['data'] as List;
    List<RequestInventory> posts =
        postsList.map((i) => RequestInventory.fromJson(i)).toList();
    return RequestInventoryModel(posts: posts);
  }
}

class PembelianInventory {
  String? id;
  String? tgl;
  String? materialId;
  String? material;
  String? qty;
  String? harga;
  String? subtotal;

  PembelianInventory(
      {this.id,
      this.tgl,
      this.materialId,
      this.material,
      this.qty,
      this.harga,
      this.subtotal});

  // Factory method to convert JSON to object
  factory PembelianInventory.fromJson(Map<String, dynamic> json) {
    return PembelianInventory(
        id: json['id'],
        tgl: json['tgl'],
        materialId: json['material_id'],
        material: json['material'],
        qty: json['qty'],
        harga: json['harga'],
        subtotal: json['subtotal']);
  }
}

class PembelianInventoryModel {
  final List<PembelianInventory> posts;

  PembelianInventoryModel({required this.posts});

  factory PembelianInventoryModel.fromJson(Map<String, dynamic> json) {
    var postsList = json['data'] as List;
    List<PembelianInventory> posts =
        postsList.map((i) => PembelianInventory.fromJson(i)).toList();
    return PembelianInventoryModel(posts: posts);
  }
}
