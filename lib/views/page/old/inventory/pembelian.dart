import 'package:eahmindonesia/controllers/old/inventory_controller.dart';
import 'package:eahmindonesia/functions/global_functions.dart';
import 'package:eahmindonesia/models/old/inventory_model.dart';
import 'package:eahmindonesia/views/page/old/inventory/tambahpembelian.dart';
import 'package:eahmindonesia/widgets/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PembelianInventoryPage extends StatefulWidget {
  final String? token;
  final String? outletId;
  const PembelianInventoryPage({super.key, this.token, this.outletId});

  @override
  State<PembelianInventoryPage> createState() => _PembelianInventoryPageState();
}

class _PembelianInventoryPageState extends State<PembelianInventoryPage> {
  late InventoryController inventoryController;
  PembelianInventoryModel? _pembelianInventoryModel;

  @override
  void initState() {
    super.initState();
    _dataRequestInventory(widget.token, widget.outletId);
  }

  @override
  void dispose() {
    // Dispose resources
    super.dispose();
  }

  Future<void> _dataRequestInventory(token, outletId) async {
    inventoryController = InventoryController();
    PembelianInventoryModel? data = await inventoryController.getPembelianInventory(token, outletId);
    setState(() {
      _pembelianInventoryModel = data;
    });
  }

  Future<void> toPembelianStockPage() async {
    // Use await so that we can run code after the child page is closed
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => //DrawerExample(),
        PembelianStockPage(token: widget.token.toString(),outletId: widget.outletId.toString()),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Slide from right
          const end = Offset.zero;
          const curve = Curves.ease;

          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      )
    );

    // Run this code after the child page is closed
    if (result == 'refresh') {
      setState(() {
        _dataRequestInventory(widget.token, widget.outletId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Expanded(
              child: RefreshIndicator(
            color: Colors.grey[800],
            onRefresh: () => _dataRequestInventory(widget.token.toString(), widget.outletId.toString()),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: _pembelianInventoryModel == null
                  ? const ListMenuShimmer(total: 5)
                  : _pembelianInventoryModel!.posts.length == 0
                      ? const Center(child: Text('Belum ada data'))
                      : ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: _pembelianInventoryModel!.posts.length,
                          itemBuilder: (context, index) {
                            var id = _pembelianInventoryModel!.posts[index].id.toString();
                            var tgl =_pembelianInventoryModel!.posts[index].tgl.toString();
                            var material = _pembelianInventoryModel!.posts[index].material.toString();
                            var qty =_pembelianInventoryModel!.posts[index].qty.toString();
                            var harga = _pembelianInventoryModel!.posts[index].harga.toString();
                            var subtotal = _pembelianInventoryModel!.posts[index].subtotal.toString();
                            
                            return listData(id, tgl, material, qty, int.parse(harga), int.parse(subtotal));
                          }),
            ),
          ))
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'request_stock',
            backgroundColor: const Color.fromARGB(255, 254, 185, 3),
            onPressed: toPembelianStockPage,
            child: const Icon(Icons.add_outlined, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget listData(String id, String tgl, String material, String qty, int harga, int subtotal) {
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        
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
                      style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)
                    ),
                    Text(tgl,style: const TextStyle(color: Colors.black87, fontSize: 16.0))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '@ ${CurrencyFormat.convertToIdr((harga), 0)}',
                      style: const TextStyle(color: Colors.black87, fontSize: 16.0),
                    ),
                    Text(
                      'x$qty',
                      style: const TextStyle(color: Colors.black87, fontSize: 16.0),
                    ),
                    Text(
                      CurrencyFormat.convertToIdr(subtotal, 0),
                      style: const TextStyle(color: Colors.black87, fontSize: 16.0),
                    ),
                  ],
                ),
              ],
            )
          ),
    );
  }
}
