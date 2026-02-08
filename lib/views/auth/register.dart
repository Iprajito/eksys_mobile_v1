import 'package:flutter/material.dart';
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
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _nomorKtaController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _kodeReferralController = TextEditingController();

  // Dropdown values
  String? _selectedTipePelanggan;
  String? _selectedWilayah;
  String? _selectedTipePpn;
  String? _selectedSyaratBayar;

  // Mock data for dropdowns
  final List<String> _tipePelangganList = ['Distributor', 'Agen', 'Reseller'];
  final List<String> _wilayahList = ['Jakarta', 'Bandung', 'Surabaya', 'Other'];
  final List<String> _tipePpnList = ['Tanpa Ppn', 'Include Ppn', 'Exclude Ppn'];
  final List<String> _syaratBayarList = ['Cash', 'Credit 30 Days', 'Credit 60 Days'];

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
        title: const Text('Register Eksys', style: TextStyle(color: Colors.white)),
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
          _buildDropdown('Tipe Pelanggan', _tipePelangganList, _selectedTipePelanggan, (val) {
            setState(() => _selectedTipePelanggan = val);
          }),
          _buildTextField('NIK', _nikController),
          _buildTextField('Nama', _namaController),
          _buildDatePicker('Tanggal Lahir', _tanggalLahirController, context),
          _buildTextField('Tempat Lahir', _tempatLahirController),
          _buildTextField('Telepon', _teleponController, keyboardType: TextInputType.phone),
          _buildTextField('Email', _emailController, keyboardType: TextInputType.emailAddress),
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
    return Column(
      children: [
        _buildTextField('Alamat', _alamatController, maxLines: 3),
        const SizedBox(height: 10),
        _buildDropdown("Provinsi", _tipePelangganList, _selectedSyaratBayar, (val) {
          setState(() => _selectedSyaratBayar = val);
        }),
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

  Widget _buildDatePicker(String label, TextEditingController controller, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
                value: currentValue,
                isExpanded: true,
                hint: Text('- Pilih -', style: TextStyle(color: Colors.grey[400])),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                items: items.map((String value) {
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

  Widget _buildFileUpload(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('File picker not implemented yet')),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: const Text('Choose file', style: TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(width: 12),
                  const Text('No file chosen', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
