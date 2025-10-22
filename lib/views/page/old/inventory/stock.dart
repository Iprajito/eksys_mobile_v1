import 'package:eahmindonesia/controllers/old/inventory_controller.dart';
import 'package:eahmindonesia/models/old/inventory_model.dart';
import 'package:eahmindonesia/views/page/old/inventory/detail.dart';
import 'package:eahmindonesia/widgets/global_widget.dart';
import 'package:flutter/material.dart';

class StockPage extends StatefulWidget {
  final String? token;
  final String? outletId;
  const StockPage({super.key, this.token, this.outletId});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  late InventoryController materialController;
  MaterialModel? _materialModel;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    materialController = InventoryController();
    _dataMaterial(widget.token.toString(), widget.outletId.toString(), '');
  }

  @override
  void dispose() {
    // Dispose resources
    super.dispose();
  }

  Future<void> _dataMaterial(token, outletId, material) async {
    MaterialModel? data =
        await materialController.getMaterial(token, outletId, material);
    if (mounted) {
      setState(() {
        _materialModel = data;
      });
    }
  }

  Future<void> toInventoryDetailPage(String id) async {
    // Use await so that we can run code after the child page is closed
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              InventoryDetailPage(token: widget.token.toString(), outletId: widget.outletId.toString(), id: id)),
    );

    // Run this code after the child page is closed
    if (result == 'refresh') {
      setState(() {
        materialController = InventoryController();
        _dataMaterial(widget.token.toString(), widget.outletId.toString(), '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                hintText: 'Search',
                hintStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                _dataMaterial(widget.token.toString(), widget.outletId.toString(), value);
              },
            ),
          ),
          Expanded(
              child: RefreshIndicator(
            color: Colors.grey[800],
            onRefresh: () => _dataMaterial(widget.token.toString(), widget.outletId.toString(), ''),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: _materialModel == null
                  ? const ListMenuShimmer(total: 5)
                  : _materialModel!.posts.length == 0
                      ? const Center(child: Text('Belum ada data'))
                      : ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: _materialModel!.posts.length,
                          itemBuilder: (context, index) {
                            var id = _materialModel!.posts[index].id.toString();
                            var material = _materialModel!.posts[index].material
                                .toString();
                            var satuan =
                                _materialModel!.posts[index].satuan.toString();
                            var keterangan = _materialModel!
                                .posts[index].keterangan
                                .toString();
                            var stok =
                                _materialModel!.posts[index].stok.toString();
                            return listData(
                                id, material, satuan, keterangan, stok);
                          }),
            ),
          ))
        ],
      ),
    );
  }

  Widget listData(String id, String material, String satuan, String keterangan,
      String stok) {
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        toInventoryDetailPage(id);
      },
      child: Container(
          // height: screenHeight * 0.085,
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(material,
                      style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Text(
                    keterangan,
                    style: TextStyle(color: Colors.grey[800], fontSize: 16.0),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Qty : $stok $satuan',
                    style: TextStyle(color: Colors.grey[800], fontSize: 16.0),
                  ),
                ],
              ),
            ],
          )),
    );
  }
}
