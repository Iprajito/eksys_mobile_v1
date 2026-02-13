import 'package:Eksys/controllers/auth_controller.dart';
import 'package:Eksys/controllers/master_controller.dart';
import 'package:Eksys/controllers/user_controller.dart';
import 'package:Eksys/functions/global_functions.dart';
import 'package:Eksys/models/master_model.dart';
import 'package:Eksys/services/api_service.dart';
import 'package:Eksys/services/localstorage_service.dart';
import 'package:Eksys/views/page/profil/edit_alamat.dart';
import 'package:Eksys/views/page/profil/tambah_alamat.dart';
import 'package:Eksys/widgets/global_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:go_router/go_router.dart';

class AlamatPage extends StatefulWidget {
  final String? token;
  final String? userid;
  const AlamatPage({super.key, this.token, this.userid});

  @override
  State<AlamatPage> createState() => _AlamatPageState();
}

class _AlamatPageState extends State<AlamatPage> {
  final authController = AuthController(ApiServive(), StorageService());
  final storageService = StorageService();
  final userController = UserController(StorageService());

  final MasterController _masterController = MasterController();
  final TextEditingController _alamatController = TextEditingController();

  // Ubah jadi masterController
  late MasterController masterController;
  PelangganModel? _pelangganModel;
  PelangganAlamatModel? _pelangganAlamatModel;

  String userId = "", userToken = "";
  String _selectedAlamatId = "";

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkToken();
    _fetchProvinsi();
    // _dataUser();
  }

  @override
  void dispose() {
    // Dispose resources
    super.dispose();
  }

  Future<void> _checkToken() async {
    final authController = AuthController(ApiServive(), StorageService());
    final check = await authController.validateToken();
    if (check == 'success') {
      print('Valid Token');
      // ini uncomment
      _dataUser();
    } else {
      if (mounted) {
        showExpiredTokenDialog(context: context);
      }
    }
  }

  Future<void> _dataUser() async {
    final user = await userController.getUserFromStorage();

    setState(() {
      isLoading = true;
    });

    setState(() {
      userId = user!.uid.toString();
      userToken = user.token.toString();
      _dataPelanggan(userToken, userId);
      _dataPelangganAlamat(userToken, userId);
      isLoading = false;
    });
  }

  void _dataPelanggan(String token, String id) async {
    masterController = MasterController();
    PelangganModel? data = await masterController.getpelangganbyid(token, id);
    if (mounted) {
      setState(() {
        _pelangganModel = data;
      });
    }
  }

  void _dataPelangganAlamat(String token, String id) async {
    masterController = MasterController();
    PelangganAlamatModel? data =
        await masterController.getpelangganalamatbyuserid(token, id);
    if (mounted) {
      setState(() {
        _pelangganAlamatModel = data;
      });
    }
  }

  final _formKey = GlobalKey<FormState>();
  int _currentPage = 0;

  // Data lists --> Start
  String? _selectedProvinsi;
  String? _selectedKabKota;
  String? _selectedKecamatan;
  String? _selectedKelurahan;
  String? _selectedKodePos;

  List<Provinsi> _provinsiList = [];
  List<String> _provinsiNames = [];

  List<KabKota> _kabKotaList = [];
  List<String> _kabKotaNames = [];

  List<Kecamatan> _kecamatanList = [];
  List<String> _kecamatanNames = [];

  List<Kelurahan> _kelurahanList = [];
  List<String> _kelurahanNames = [];

  List<KodePos> _kodePosList = [];
  List<String> _kodePosNames = [];
  // Data lists --> End

  Future<void> _fetchProvinsi() async {
    final result = await _masterController.getProvinsi();
    if (result != null) {
      setState(() {
        _provinsiList = result.data;
        _provinsiNames = _provinsiList
            .map((e) => e.provinsi ?? '')
            .where((e) => e.isNotEmpty)
            .toList();
      });
    }
  }

  Future<void> _fetchKabKota(String provinsiId) async {
    final result = await _masterController.getKabKota(provinsiId);
    if (result != null) {
      _selectedKecamatan = "- Pilih -";
      _kecamatanList.clear();
      _selectedKelurahan = "- Pilih -";
      _kelurahanList.clear();
      _selectedKodePos = "- Pilih -";
      _kodePosList.clear();
      setState(() {
        _kabKotaList = result.data;
        _kabKotaNames = _kabKotaList
            .map((e) => e.kabkota ?? '')
            .where((e) => e.isNotEmpty)
            .toList();
      });
    }
  }

  Future<void> _fetchKecamatan(String kotaId) async {
    _selectedKelurahan = "- Pilih -";
    _kelurahanList.clear();
    _selectedKodePos = "- Pilih -";
    _kodePosList.clear();
    final result = await _masterController.getKecamatan(kotaId);
    if (result != null) {
      _selectedKelurahan = "- Pilih -";
      _kelurahanList.clear();
      setState(() {
        _kecamatanList = result.data;
        _kecamatanNames = _kecamatanList
            .map((e) => e.kecamatan ?? '')
            .where((e) => e.isNotEmpty)
            .toList();
      });
    }
  }

  Future<void> _fetchKelurahan(String kecamatanId) async {
    _selectedKodePos = "- Pilih -";
    _kodePosList.clear();
    final result = await _masterController.getKelurahan(kecamatanId);
    if (result != null) {
      setState(() {
        _kelurahanList = result.data;
        _kelurahanNames = _kelurahanList
            .map((e) => e.kelurahan ?? '')
            .where((e) => e.isNotEmpty)
            .toList();
      });
    }
  }

  Future<void> _fetchKodePos(String kelurahanId) async {
    final result = await _masterController.getKodePos(kelurahanId);
    if (result != null) {
      setState(() {
        _kodePosList = result.data;
        _kodePosNames = _kodePosList
            .map((e) => e.kodePos ?? '')
            .where((e) => e.isNotEmpty)
            .toList();
      });
    }
  }

  void _nextPage() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _currentPage = 1;
      });
    }
  }

  void _previousPage() {
    setState(() {
      _currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          leading: _currentPage == 1
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: _previousPage,
                )
              : IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
          title: const Row(
            children: [
              Text("Alamat Saya",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 0, 48, 47),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        body: SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: _currentPage == 0 ? _buildPageOne() : _buildPageTwo()),
        ),
        bottomNavigationBar: Container(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey[300]!,
                    blurRadius: 1.0,
                    spreadRadius: 2 //, offset: Offset(0, -3)
                    )
              ],
            ),
            child: Container(
              height: 65,
              // width: (screenWidth/2),
              // margin: const EdgeInsets.only(left: 0.0, right: 1.0),
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                // border: Border.all(color: Colors.white),
                color: Colors.white,
                // borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _currentPage == 0
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: (screenWidth) - 16,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) => //DrawerExample(),
                                            TambahAlamat(userId: userId),
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          const begin = Offset(
                                              1.0, 0.0); // Slide from right
                                          const end = Offset.zero;
                                          const curve = Curves.ease;

                                          final tween = Tween(
                                                  begin: begin, end: end)
                                              .chain(CurveTween(curve: curve));
                                          final offsetAnimation =
                                              animation.drive(tween);

                                          return SlideTransition(
                                            position: offsetAnimation,
                                            child: child,
                                          );
                                        },
                                      ));
                                  _dataUser();
                                }, //_saveProduks
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(8),
                                  backgroundColor:
                                      const Color.fromARGB(255, 254, 185, 3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Tambah Alamat Baru',
                                  style: TextStyle(
                                      color: Colors.grey[800], fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container()
                ],
              ),
            )));
  }

  Widget _buildPageOne() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _pelangganAlamatModel == null
          ? const ListMenuShimmer(total: 5)
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _pelangganAlamatModel!.data.length,
              itemBuilder: (context, index) {
                final item = _pelangganAlamatModel!.data[index];
                print("item.id_encrypt: " + item.id_encrypt.toString());
                return listAlamat(
                  item.id.toString(),
                  item.nama_penerima.toString(),
                  item.telepon_penerima.toString(),
                  item.alamat_kirim1.toString(),
                  item.alamat_kirim2.toString(),
                  item.prim_address.toString(),
                  item.id_encrypt.toString(),
                );
              },
            ),
    );
  }

  Widget _buildPageTwo() {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom, left: 16, right: 16),
      child: Column(
        children: [
          _buildTextField('Alamat', _alamatController, maxLines: 3),
          const SizedBox(height: 10),
          _buildDropdown("Provinsi", _provinsiNames, _selectedProvinsi, (val) {
            setState(() {
              _selectedProvinsi = val;
              if (val != null) {
                int index = _provinsiNames.indexOf(val);
                if (index != -1 && index < _provinsiList.length) {
                  String id = _provinsiList[index].id ?? '';
                  _fetchKabKota(id);
                }
              }
            });
          }),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                    "Kota/Kabupaten", _kabKotaNames, _selectedKabKota, (val) {
                  setState(() {
                    _selectedKabKota = val;
                    if (val != null) {
                      int index = _kabKotaNames.indexOf(val);
                      if (index != -1 && index < _kabKotaList.length) {
                        String id = _kabKotaList[index].id ?? '';
                        _fetchKecamatan(id);
                      }
                    }
                  });
                }),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDropdown(
                    "Kecamatan", _kecamatanNames, _selectedKecamatan, (val) {
                  setState(() {
                    _selectedKecamatan = val;
                    if (val != null) {
                      int index = _kecamatanNames.indexOf(val);
                      if (index != -1 && index < _kecamatanList.length) {
                        String id = _kecamatanList[index].id ?? '';
                        _fetchKelurahan(id);
                      }
                    }
                  });
                }),
              ),
              const SizedBox(width: 10),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                    "Kelurahan", _kelurahanNames, _selectedKelurahan, (val) {
                  setState(() {
                    _selectedKelurahan = val;
                    if (val != null) {
                      int index = _kelurahanNames.indexOf(val);
                      if (index != -1 && index < _kelurahanList.length) {
                        String id = _kelurahanList[index].id ?? '';
                        print(id);
                        _fetchKodePos(id);
                      }
                    }
                  });
                }),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDropdown(
                    "Kode Pos", _kodePosNames, _selectedKodePos, (val) {
                  setState(() => _selectedKodePos = val);
                }),
              ),
              const SizedBox(width: 10),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(
            color: Colors.grey, // Warna garis
            thickness: 1, // Ketebalan garis
            indent: 0, // Jarak kosong di awal garis
            endIndent: 0, // Jarak kosong di akhir garis
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: const Color.fromARGB(255, 254, 185, 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Process data
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );
                }
              },
              child: Text(
                'Simpan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: TextStyle(color: Colors.grey[800]),
            validator: (value) {
              // Basic validation, allow empty if not critical, but typically fields are required
              // For now, let's say only Nama and Email are strictly required for demo or all are required?
              // Assuming all text fields are required for simplicity as per form logic usually
              // But modifying to be lenient or strict based on requirement.
              // Let's make it simple: required.
              if (value == null || value.isEmpty) {
                return '$label tidak boleh kosong';
              }
              return null;
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              hintText: label,
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? currentValue,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.black, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<String>(
                initialValue:
                    items.contains(currentValue) ? currentValue : null,
                isExpanded: true,
                hint: Text('- Pilih -',
                    style: TextStyle(color: Colors.grey[400])),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                items: items.toSet().map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child:
                        Text(value, style: TextStyle(color: Colors.grey[800])),
                  );
                }).toList(),
                onChanged: onChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '$label harus dipilih';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget listAlamat(String id, String nama, String telepon, String alamat1,
      String alamat2, String prim_address, String id_encrypt) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditAlamatPage(
                      idEncrypt: id_encrypt,
                      userId: userId,
                    )));
        _dataUser();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8.0)),
        padding: const EdgeInsets.all(16),
        child: BootstrapContainer(fluid: true, children: [
          BootstrapRow(
            // height: 60,
            children: [
              BootstrapCol(
                sizes: 'col-12',
                child: Row(
                  children: [
                    Text(nama.toUpperCase(),
                        style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                    const SizedBox(width: 5),
                    Text(
                      telepon,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          BootstrapRow(
            // height: 60,
            children: [
              BootstrapCol(
                sizes: 'col-12',
                child: Text(
                  alamat1,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          BootstrapRow(
            // height: 60,
            children: [
              BootstrapCol(
                sizes: 'col-12',
                child: Text(
                  alamat2,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          BootstrapRow(
            // height: 60,
            children: [
              BootstrapCol(
                sizes: 'col-2',
                child: prim_address != 'Utama'
                    ? const Text('')
                    : Container(
                        margin: const EdgeInsets.only(top: 8.0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(
                              color: Colors.orangeAccent.shade700, width: 1.0),
                        ),
                        child: Text(
                          'Utama',
                          style: TextStyle(
                            color: Colors.orangeAccent.shade700,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
