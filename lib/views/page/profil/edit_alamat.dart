import 'package:Eksys/controllers/master_controller.dart';
import 'package:Eksys/controllers/user_controller.dart';
import 'package:Eksys/models/master_model.dart';
import 'package:Eksys/services/localstorage_service.dart';
import 'package:flutter/material.dart';

class EditAlamatPage extends StatefulWidget {
  final String idEncrypt;
  final String userId;

  const EditAlamatPage(
      {super.key, required this.idEncrypt, required this.userId});

  @override
  State<EditAlamatPage> createState() => _EditAlamatPageState();
}

class _EditAlamatPageState extends State<EditAlamatPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  final TextEditingController _jalanController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _noRumahController = TextEditingController();

  final MasterController _masterController = MasterController();
  final UserController _userController = UserController(StorageService());

  bool _isLoading = true;
  bool _isDefault = false;

  // Data for Display/Selection
  String? _provinsi;
  String? _kota;
  String? _kecamatan;
  String? _kelurahan;
  String? _kodePos;

  // We might need IDs if we are to update.
  // Assuming the API returns the names or IDs we need.
  // The UI requirement shows "JAWA TENGAH KOTA SEMARANG..." displayed.

  @override
  void initState() {
    super.initState();
    // Fetch initial province list
    _fetchProvinsi();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data =
        await _masterController.getPelangganAlamatByEncryptId(widget.idEncrypt);
    if (data != null && data.data.isNotEmpty) {
      var alamatData = data.data[0];

      if (alamatData != null) {
        setState(() {
          _namaController.text = alamatData.namaPenerima ?? '';
          _teleponController.text = alamatData.teleponPenerima ?? '';
          _jalanController.text = alamatData.alamatPengiriman ?? '';

          // Assuming these fields map to available data.
          // The API response shows IDs (alamat_provinsi="10", etc).
          // If we want names, we might need to fetch them OR maybe the API returns names in some cases?
          // But based on USER REQUEST response example: "alamat_provinsi": "10".
          // So we are displaying IDs here unless we fetch master data names separately.
          // For now, I will bind to what is available as per request,
          // but the image shows names "JAWA TENGAH".
          // Since I don't have a way to resolve ID "10" to "JAWA TENGAH" in this specific response
          // (it only has IDs), I will display the IDs or just put placeholders if names aren't there.
          // WAIT, the previous code tried to map 'provinsi', 'kota' etc keys which don't exist in the JSON.
          // I will map to the defined fields in PelangganAlamatDetail.
          // To get Names, we would technically need to look them up from MasterController using the IDs,
          // OR the API should return names.
          // I will assign ID for now, or just leave as is if user wants names later.
          // Actually, I'll display the IDs for now as that's what we have.

          _provinsi = alamatData.alamatProvinsi;
          _kota = alamatData.alamatKota;
          _kecamatan = alamatData.alamatKecamatan;
          _kelurahan = alamatData.alamatKelurahan;
          _kodePos = alamatData.alamatKodepos;

          // Set selected IDs inside setState
          _selectedProvinsi = _provinsi;
          _selectedKabKota = _kota;
          _selectedKecamatan = _kecamatan;
          _selectedKelurahan = _kelurahan;
          _selectedKodePos = _kodePos;

          _detailController.text = alamatData.alamatDetailLain ?? '';
          _noRumahController.text = alamatData.alamatNo ?? '';

          _isLoading = false;
          _isDefault = alamatData.isDefault == "1";
        });

        // Cascade fetch to populate dropdowns (outside setState)
        if (_selectedProvinsi != null) {
          await _fetchKabKota(_selectedProvinsi!, true);
        }
        if (_selectedKabKota != null) {
          await _fetchKecamatan(_selectedKabKota!, true);
        }
        if (_selectedKecamatan != null) {
          await _fetchKelurahan(_selectedKecamatan!, true);
        }
        if (_selectedKelurahan != null) {
          await _fetchKodePos(_selectedKelurahan!);
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat data alamat')),
        );
      }
    }
  }

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

  Future<void> _fetchKabKota(String provinsiId, bool initial) async {
    final result = await _masterController.getKabKota(provinsiId);
    if (result != null) {
      if (!initial) {
        _selectedKecamatan = "- Pilih -";
        _kecamatanList.clear();
        _selectedKelurahan = "- Pilih -";
        _kelurahanList.clear();
        _selectedKodePos = "- Pilih -";
        _kodePosList.clear();
      }
      setState(() {
        _kabKotaList = result.data;
        _kabKotaNames = _kabKotaList
            .map((e) => e.kabkota ?? '')
            .where((e) => e.isNotEmpty)
            .toList();
      });
    }
  }

  Future<void> _fetchKecamatan(String kotaId, bool initial) async {
    final result = await _masterController.getKecamatan(kotaId);
    if (result != null) {
      if (!initial) {
        _selectedKelurahan = "- Pilih -";
        _kelurahanList.clear();
        _selectedKodePos = "- Pilih -";
        _kodePosList.clear();
      }
      setState(() {
        _kecamatanList = result.data;
        _kecamatanNames = _kecamatanList
            .map((e) => e.kecamatan ?? '')
            .where((e) => e.isNotEmpty)
            .toList();
      });
    }
  }

  Future<void> _fetchKelurahan(String kecamatanId, bool initial) async {
    if (!initial) {
      _selectedKodePos = "- Pilih -";
      _kodePosList.clear();
    }
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

  Future<void> _deleteAlamat() async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: const Text("Apakah anda yakin ingin menghapus alamat ini?"),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text("Hapus"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm) {
      setState(() {
        _isLoading = true;
      });

      bool success =
          await _userController.deleteAlamatPelanggan(widget.idEncrypt);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Berhasil"),
                content: const Text("Alamat berhasil dihapus"),
                actions: [
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Go back to previous screen
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Gagal"),
                content: const Text("Gagal menghapus alamat"),
                actions: [
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

  Future<void> _saveAlamat() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedProvinsi == null ||
          _selectedKabKota == null ||
          _selectedKecamatan == null ||
          _selectedKelurahan == null ||
          _selectedKodePos == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mohon lengkapi data wilayah')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      Map<String, dynamic> data = {
        "id_encrypt": widget.idEncrypt,
        "user_id": widget.userId,
        "nama_penerima": _namaController.text,
        "telepon_penerima": _teleponController.text,
        "alamat_pengiriman": _jalanController.text,
        "alamat_provinsi": _selectedProvinsi,
        "alamat_kota": _selectedKabKota,
        "alamat_kecamatan": _selectedKecamatan,
        "alamat_kelurahan": _selectedKelurahan,
        "alamat_rt": "1", // Default/Placeholder as per request
        "alamat_rw": "1", // Default/Placeholder as per request
        "alamat_no": _noRumahController.text.isNotEmpty
            ? _noRumahController.text
            : "1", // Use controller or default
        "alamat_kodepos": _selectedKodePos,
        "alamat_detail_lain": _detailController.text,
        "is_default": _isDefault ? "1" : "0"
      };

      bool success = await _userController.updateAlamatPelanggan(data);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Berhasil"),
                content: const Text("Alamat berhasil diperbarui"),
                actions: [
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Go back to previous screen
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Gagal"),
                content: const Text("Gagal memperbarui alamat"),
                actions: [
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Alamat', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Alamat',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildLabel('Nama Lengkap'),
                      _buildTextField(_namaController),
                      const SizedBox(height: 16),
                      _buildLabel('Nomor Telepon'),
                      _buildTextField(_teleponController,
                          keyboardType: TextInputType.phone),
                      const SizedBox(height: 16),
                      _buildRegionDropdowns(),
                      const SizedBox(height: 16),
                      _buildLabel('Nama Jalan, Gedung, No. Rumah'),
                      _buildTextField(_jalanController, maxLines: 2),
                      const SizedBox(height: 16),
                      _buildLabel(
                          'Detail Lainnya (Cth: Blok / Unit No., Patokan)'),
                      _buildTextField(_detailController),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Set as Default',
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                          Switch(
                            value: _isDefault,
                            onChanged: (value) {
                              setState(() {
                                _isDefault = value;
                              });
                            },
                            activeColor: const Color.fromARGB(255, 254, 185, 3),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _deleteAlamat,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color.fromARGB(255, 0, 48, 47),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Hapus Alamat',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveAlamat,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                    255, 0, 48, 47), // Color from image roughly
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Simpan',
                                      style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child:
          Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
    );
  }

  Widget _buildTextField(TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        isDense: true,
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildRegionDropdowns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Provinsi
        _buildDropdownItem(
            "Provinsi",
            "Provinsi",
            _provinsiList
                .map((e) => DropdownMenuItem(
                    value: e.id, child: Text(e.provinsi ?? '')))
                .toList(),
            _selectedProvinsi, (val) {
          setState(() {
            _selectedProvinsi = val;
            _selectedKabKota = null;
            _selectedKecamatan = null;
            _selectedKelurahan = null;
            _selectedKodePos = null;
            _kabKotaList.clear();
            _kecamatanList.clear();
            _kelurahanList.clear();
            _kodePosList.clear();
            if (val != null) _fetchKabKota(val, false);
          });
        }),
        const SizedBox(height: 16),
        Row(
          children: [
            // Kota
            Expanded(
              child: _buildDropdownItem(
                  "Kota/Kabupaten",
                  "Kota/Kabupaten",
                  _kabKotaList
                      .map((e) => DropdownMenuItem(
                          value: e.id, child: Text(e.kabkota ?? '')))
                      .toList(),
                  _selectedKabKota, (val) {
                setState(() {
                  _selectedKabKota = val;
                  _selectedKecamatan = null;
                  _selectedKelurahan = null;
                  _selectedKodePos = null;
                  _kecamatanList.clear();
                  _kelurahanList.clear();
                  _kodePosList.clear();
                  if (val != null) _fetchKecamatan(val, false);
                });
              }),
            ),
            const SizedBox(width: 16),
            // Kecamatan
            Expanded(
                child: _buildDropdownItem(
                    "Kecamatan",
                    "Kecamatan",
                    _kecamatanList
                        .map((e) => DropdownMenuItem(
                            value: e.id, child: Text(e.kecamatan ?? '')))
                        .toList(),
                    _selectedKecamatan, (val) {
              setState(() {
                _selectedKecamatan = val;
                _selectedKelurahan = null;
                _selectedKodePos = null;
                _kelurahanList.clear();
                _kodePosList.clear();
                if (val != null) _fetchKelurahan(val, false);
              });
            }))
          ],
        ),
        const SizedBox(height: 16),
        // Kelurahan
        Row(
          children: [
            Expanded(
                child: _buildDropdownItem(
                    "Kelurahan",
                    "Kelurahan",
                    _kelurahanList
                        .map((e) => DropdownMenuItem(
                            value: e.id, child: Text(e.kelurahan ?? '')))
                        .toList(),
                    _selectedKelurahan, (val) {
              setState(() {
                _selectedKelurahan = val;
                _selectedKodePos = null;
                _kodePosList.clear();
                if (val != null) _fetchKodePos(val);
              });
            })),
            const SizedBox(width: 16),
            // Kode Pos
            Expanded(
                child: _buildDropdownItem(
                    "Kode Pos",
                    "Kode Pos",
                    _kodePosList
                        .map((e) => DropdownMenuItem(
                            value: e.kodePos, child: Text(e.kodePos ?? '')))
                        .toList(),
                    _selectedKodePos, (val) {
              setState(() {
                _selectedKodePos = val;
              });
            }))
          ],
        )
      ],
    );
  }

  Widget _buildDropdownItem(
      String label,
      String hint,
      List<DropdownMenuItem<String>> items,
      String? value,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.any((item) => item.value == value) ? value : null,
              hint: Text(hint,
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13)), // Using hint as label style
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
