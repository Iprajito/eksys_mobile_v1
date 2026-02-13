import 'package:Eksys/controllers/master_controller.dart';
import 'package:Eksys/controllers/user_controller.dart';
import 'package:Eksys/models/master_model.dart';
import 'package:Eksys/services/localstorage_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentPage = 0; // 0 for the first page, 1 for the second page

  // Controllers
  final MasterController _masterController = MasterController();
  final UserController _userController = UserController(StorageService());
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _nomorKtaController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  final TextEditingController _detailAlamatController = TextEditingController();
  final TextEditingController _namaPenerimaController = TextEditingController();
  final TextEditingController _noTelpController = TextEditingController();
  final TextEditingController _noRumahController = TextEditingController();
  final TextEditingController _rtController = TextEditingController();
  final TextEditingController _rwController = TextEditingController();

  final TextEditingController _kodeReferralController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Dropdown values
  String? _selectedTipePelanggan;
  String? _selectedWilayah;
  String? _selectedTipePpn;
  String? _selectedSyaratBayar;

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

  // Mock data for dropdowns
  final List<String> _tipePelangganList = ['Distributor', 'Agen', 'Reseller'];
  final List<String> _wilayahList = ['Jakarta', 'Bandung', 'Surabaya', 'Other'];
  final List<String> _tipePpnList = ['Tanpa Ppn', 'Include Ppn', 'Exclude Ppn'];
  final List<String> _syaratBayarList = [
    'Cash',
    'Credit 30 Days',
    'Credit 60 Days'
  ];

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

  @override
  void dispose() {
    _nikController.dispose();
    _nomorKtaController.dispose();
    _namaController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _teleponController.dispose();
    _emailController.dispose();
    _alamatController.dispose();
    _kodeReferralController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _tanggalLahirController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _nextPage() async {
    if (_formKey.currentState!.validate()) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      try {
        final result = await _masterController.checkRegister(
            _kodeReferralController.text,
            _emailController.text,
            _teleponController.text);

        if (!mounted) return;

        // Hide loading
        Navigator.pop(context);

        if (result != null && result['status'] == 'success') {
          // Check if data is valid
          // Assuming result['data'] having "1" means valid.
          // If the API returns success, we likely can proceed.
          if (result['data'][0]['kode_referral'] == '1' &&
              result['data'][0]['email'] == '0' &&
              result['data'][0]['telepon'] == '0') {
            setState(() {
              _currentPage = 1;
            });
          } else {
            String message = result['message'] ??
                'Validasi Gagal. Silakan cek data anda kembali.';
            if (result['data'][0]['kode_referral'] == '0') {
              _showErrorDialog("Kode Referral Tidak Valid");
            } else if (result['data'][0]['email'] == '1') {
              _showErrorDialog("Email Sudah Terdaftar");
            } else if (result['data'][0]['telepon'] == '1') {
              _showErrorDialog("Nomor Telepon Sudah Terdaftar");
            }
          }
        } else {
          String message = result != null && result['message'] != null
              ? result['message']
              : 'Validasi Gagal. Silakan cek data anda kembali.';
          _showErrorDialog(message);
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Hide loading on error
          _showErrorDialog('Terjadi kesalahan: $e');
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Informasi"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Informasi"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => GoRouter.of(context).go('/login'),
            child: const Text("OK"),
          ),
        ],
      ),
    );
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
        title:
            const Text('Register Eksys', style: TextStyle(color: Colors.white)),
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
              const Text(
                'Informasi Personal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              if (_currentPage == 0) _buildPageOne(),
              if (_currentPage == 1) _buildPageTwo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageOne() {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Column(
        children: [
          _buildTextField('Kode Referral', _kodeReferralController),
          const SizedBox(height: 30),
          _buildDropdown(
              'Tipe Pelanggan', _tipePelangganList, _selectedTipePelanggan,
              (val) {
            setState(() => _selectedTipePelanggan = val);
          }),
          _buildTextField('NIK', _nikController),
          _buildTextField('Nama', _namaController),
          _buildDatePicker('Tanggal Lahir', _tanggalLahirController, context),
          _buildTextField('Tempat Lahir', _tempatLahirController),
          _buildTextField('Telepon', _teleponController,
              keyboardType: TextInputType.phone),
          _buildTextField('Email', _emailController,
              keyboardType: TextInputType.emailAddress),
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
              onPressed: _nextPage,
              child: Text(
                'Next',
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

  Widget _buildPageTwo() {
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
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTextField("RT", _rtController, maxLines: 1),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField("RW", _rwController, maxLines: 1),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTextField('No Rumah / Gedung', _noRumahController,
                    maxLines: 1),
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
          const SizedBox(height: 10),
          _buildTextField('Detail Alamat Lainnya', _detailAlamatController,
              maxLines: 3),
          const SizedBox(height: 10),
          _buildTextField('Nama Penerima', _namaPenerimaController,
              maxLines: 1),
          const SizedBox(height: 10),
          _buildTextField('Telepon Penerima', _noTelpController, maxLines: 1),
          const SizedBox(height: 20),
          const Divider(
            color: Colors.grey, // Warna garis
            thickness: 1, // Ketebalan garis
            indent: 0, // Jarak kosong di awal garis
            endIndent: 0, // Jarak kosong di akhir garis
          ),
          const SizedBox(height: 20),
          _buildPasswordField(
              'Password', _passwordController, _isPasswordVisible, () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          }),
          const SizedBox(height: 16),
          _buildPasswordField('Re-type Password', _confirmPasswordController,
              _isConfirmPasswordVisible, () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          }),
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
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Show Loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const Center(child: CircularProgressIndicator());
                    },
                  );

                  // Get IDs
                  String? provinsiId = _provinsiList
                      .firstWhere((e) => e.provinsi == _selectedProvinsi,
                          orElse: () => Provinsi())
                      .id;
                  String? kotaId = _kabKotaList
                      .firstWhere((e) => e.kabkota == _selectedKabKota,
                          orElse: () => KabKota())
                      .id;
                  String? kecamatanId = _kecamatanList
                      .firstWhere((e) => e.kecamatan == _selectedKecamatan,
                          orElse: () => Kecamatan())
                      .id;
                  String? kelurahanId = _kelurahanList
                      .firstWhere((e) => e.kelurahan == _selectedKelurahan,
                          orElse: () => Kelurahan())
                      .id;

                  Map<String, dynamic> data = {
                    "kodereferral": _kodeReferralController.text,
                    "tipe_pelanggan": _selectedTipePelanggan,
                    "nik": _nikController.text,
                    "nama": _namaController.text,
                    "tgl_lahir": _tanggalLahirController.text,
                    "kota_lahir": _tempatLahirController.text,
                    "telepon": _teleponController.text,
                    "email": _emailController.text,
                    "alamat_pengiriman": _alamatController.text,
                    "alamat_provinsi": provinsiId ?? "",
                    "alamat_kota": kotaId ?? "",
                    "alamat_kecamatan": kecamatanId ?? "",
                    "alamat_kelurahan": kelurahanId ?? "",
                    "alamat_rt": _rtController.text,
                    "alamat_rw": _rwController.text,
                    "alamat_no": _noRumahController.text,
                    "alamat_kodepos": _selectedKodePos ?? "",
                    "alamat_detail_lain": "",
                    "password": _passwordController.text
                  };

                  try {
                    final result = await _userController.registerUser(data);

                    if (!mounted) return;
                    Navigator.pop(context); // Hide loading

                    if (result != null && result['status'] == 'success') {
                      _showSuccessDialog("Registrasi Berhasil. Silakan Login.");
                    } else {
                      String message =
                          result != null && result['message'] != null
                              ? result['message']
                              : "Registrasi Gagal";
                      _showErrorDialog(message);
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context);
                      _showErrorDialog("Terjadi kesalahan: $e");
                    }
                  }
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

  Widget _buildPasswordField(String label, TextEditingController controller,
      bool isVisible, VoidCallback toggleVisibility) {
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
            obscureText: !isVisible,
            style: TextStyle(color: Colors.grey[800]),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$label tidak boleh kosong';
              }
              if (label == 'Re-type Password' &&
                  value != _passwordController.text) {
                return 'Password tidak sama';
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
              suffixIcon: IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: toggleVisibility,
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
              if (value == null || value.isEmpty) {
                return '$label tidak boleh kosong';
              }

              if (keyboardType == TextInputType.emailAddress &&
                  value.isNotEmpty) {
                // Basic email regex
                final bool emailValid = RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                    .hasMatch(value);
                if (!emailValid) {
                  return 'Format email tidak valid';
                }
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

  Widget _buildDatePicker(
      String label, TextEditingController controller, BuildContext context) {
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
            readOnly: true,
            onTap: () => _selectDate(context),
            style: TextStyle(color: Colors.grey[800]),
            validator: (value) {
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
              hintText: 'Select Date',
              hintStyle: TextStyle(color: Colors.grey[400]),
              suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
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
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
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

  Widget _buildFileUpload(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('File picker not implemented yet')),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: const Text('Choose file',
                        style: TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(width: 12),
                  const Text('No file chosen',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
