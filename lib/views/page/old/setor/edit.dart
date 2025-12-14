import 'package:eahmindonesia/controllers/old/setorsaldo_controller.dart';
import 'package:eahmindonesia/functions/global_functions.dart';
import 'package:eahmindonesia/models/old/setorsaldo_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditSetorSaldoPage extends StatefulWidget {
  final String? token;
  final String? outletId;
  final String? id;
  final String? nota;
  final String? tgl;
  final int? nilai;
  const EditSetorSaldoPage(
      {super.key,this.token, this.outletId, this.id, this.nota, this.tgl, this.nilai});

  @override
  State<EditSetorSaldoPage> createState() => _EditSetorSaldoPageState();
}

class _EditSetorSaldoPageState extends State<EditSetorSaldoPage> {
  DateTime _selectedDate = DateTime.now();
  // TextEditingController notaController = TextEditingController();
  TextEditingController tanggalController = TextEditingController();
  TextEditingController nominalController = TextEditingController();

  late SetorSaldoController setorSaldoController;

  final _formKey = GlobalKey<FormState>();
  String nota = '';
  String tanggal = '';
  String nominal = '';

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      tanggal = DateFormat('yyyy-MM-dd').format(_selectedDate);
      // print(nota + '# ${tanggal} #' + nominal);

      showLoadingDialog(context: context);
      setorSaldoController = SetorSaldoController();
      var response = await setorSaldoController.saveSetorSaldo(
          widget.token.toString(),
          widget.id.toString(),
          widget.outletId.toString(),
          nota,
          tanggal,
          nominal);
      if (response) {
        hideLoadingDialog(context);
        Navigator.pop(context, 'refresh');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Setor Saldo",
            style: TextStyle(
                color: Color.fromARGB(255, 17, 19, 21),
                fontWeight: FontWeight.w700)),
        backgroundColor: const Color.fromARGB(255, 254, 185, 3),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.grey[800],
                child: ListTile(
                  title: const Text('Nomor Nota',
                      style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 254, 185, 3))),
                  subtitle: TextFormField(
                    controller: TextEditingController(text: widget.nota),
                    style: const TextStyle(color: Colors.white),
                    cursorColor: const Color.fromARGB(255, 254, 185, 3),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[800]!),
                      ),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                    enabled: false,
                    onSaved: (value) {
                      nota = value!;
                    },
                  ),
                ),
              ),
              // const SizedBox(height: 10),
              Card(
                color: Colors.grey[800],
                child: ListTile(
                  title: const Text('Tanggal',
                      style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 254, 185, 3))),
                  subtitle: TextFormField(
                      controller: tanggalController = TextEditingController(
                          text: DateFormat.yMMMd('en_US')
                              .format(DateFormat("dd-MM-yyyy")
                                  .parse(widget.tgl.toString()))
                              .toString()),
                      style: const TextStyle(color: Colors.white),
                      cursorColor: const Color.fromARGB(255, 254, 185, 3),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[800]!),
                        ),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                      focusNode: AlwaysDisabledFocusNode(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tanggal masih kosong';
                        }
                        return null;
                      },
                      onTap: () {
                        _selectDate(context);
                      }),
                ),
              ),
              // const SizedBox(height: 10),
              Card(
                color: Colors.grey[800],
                child: ListTile(
                  title: const Text('Nominal',
                      style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 254, 185, 3))),
                  subtitle: TextFormField(
                    controller:
                        TextEditingController(text: widget.nilai.toString()),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: const Color.fromARGB(255, 254, 185, 3),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[800]!),
                      ),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nominal masih kosong';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      nominal = value!;
                    },
                  ),
                ),
              ),
              // const SizedBox(height: 10),
              Card(
                shadowColor: Colors.transparent,
                child: SizedBox(
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
                      _saveForm();
                    },
                    child: Text(
                      'Update',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.grey[800]),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _selectDate(BuildContext context) async {
    DateTime? newSelectedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2040),
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        builder: (BuildContext context, Widget? widget) => Theme(
              data: ThemeData(
                colorScheme:
                    const ColorScheme.light(primary: Color(0xFFFFB902)),
                datePickerTheme: DatePickerThemeData(
                  backgroundColor: Colors.white,
                  dividerColor: const Color(0xFFFFB902),
                  headerBackgroundColor: const Color(0xFFFFB902),
                  headerForegroundColor: Colors.grey[800],
                ),
              ),
              child: widget!,
            ));
    if (newSelectedDate != null) {
      _selectedDate = newSelectedDate;
      tanggalController
        ..text = DateFormat.yMMMd().format(_selectedDate)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: tanggalController.text.length,
            affinity: TextAffinity.upstream));
      // print(DateFormat('yyyy-MM-dd').format(_selectedDate));
    }
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
