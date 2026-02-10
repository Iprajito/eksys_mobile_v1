import 'package:Eksys/controllers/master_controller.dart';
import 'package:Eksys/models/master_model.dart';
import 'package:flutter/material.dart';

class TambahAlamat extends StatefulWidget {
  const TambahAlamat({super.key});

  @override
  State<TambahAlamat> createState() => _TambahAlamatState();
}

class _TambahAlamatState extends State<TambahAlamat> {
  final _formKey = GlobalKey<FormState>();
  int _currentPage = 0;

  final TextEditingController _alamatController = TextEditingController();
  final MasterController _masterController = MasterController();

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

  @override
  void initState() {
    super.initState();
    _fetchProvinsi();
  }

  Future<void> _fetchProvinsi() async {
    final result = await _masterController.getProvinsi();
    if (result != null) {
      setState(() {
        _provinsiList = result.data;
        _provinsiNames = _provinsiList.map((e) => e.provinsi ?? '').where((e) => e.isNotEmpty).toList();
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
        _kabKotaNames = _kabKotaList.map((e) => e.kabkota ?? '').where((e) => e.isNotEmpty).toList();
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
        _kecamatanNames = _kecamatanList.map((e) => e.kecamatan ?? '').where((e) => e.isNotEmpty).toList();
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
        _kelurahanNames = _kelurahanList.map((e) => e.kelurahan ?? '').where((e) => e.isNotEmpty).toList();
      });
    }
  }
  
  Future<void> _fetchKodePos(String kelurahanId) async {
    final result = await _masterController.getKodePos(kelurahanId);
    if (result != null) {
      setState(() {
        _kodePosList = result.data;
        _kodePosNames = _kodePosList.map((e) => e.kodePos ?? '').where((e) => e.isNotEmpty).toList();
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
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 48, 47),
      appBar: AppBar(
        title: const Text('Tambah Alamat Baru', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: _currentPage == 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousPage,
              )
            : null, // Default back button behavior for the first page
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWidgetAlamat(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetAlamat() {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
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
                child: _buildDropdown("Kota/Kabupaten", _kabKotaNames, _selectedKabKota, (val) {
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
                child: _buildDropdown("Kecamatan", _kecamatanNames, _selectedKecamatan, (val) {
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
                child: _buildDropdown("Kelurahan", _kelurahanNames, _selectedKelurahan, (val) {
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
                child: _buildDropdown("Kode Pos", _kodePosNames, _selectedKodePos, (val) {
                  setState(() => _selectedKodePos = val);
                }),
              ),
              const SizedBox(width: 10),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(
            color: Colors.grey, // Warna garis
            thickness: 1,       // Ketebalan garis
            indent: 0,          // Jarak kosong di awal garis
            endIndent: 0,       // Jarak kosong di akhir garis
          ),
          const SizedBox(height: 30),
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
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
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

  Widget _buildDropdown(String label, List<String> items, String? currentValue, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<String>(
              initialValue: items.contains(currentValue) ? currentValue : null,
              isExpanded: true,
              hint: Text('- Pilih -', style: TextStyle(color: Colors.grey[400])),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              items: items.toSet().map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(color: Colors.grey[800])),
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
}