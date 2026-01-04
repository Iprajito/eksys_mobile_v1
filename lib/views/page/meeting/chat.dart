import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:Eksys/controllers/auth_controller.dart';
import 'package:Eksys/controllers/user_controller.dart';
import 'package:Eksys/functions/global_functions.dart';
import 'package:Eksys/services/api_service.dart';
import 'package:Eksys/services/localstorage_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'package:saver_gallery/saver_gallery.dart';

class ChatMeetingPage extends StatefulWidget {
  final String? token;
  final String? userid;
  final String? usergroup;
  final String? id;
  const ChatMeetingPage(
      {super.key, this.token, this.userid, this.usergroup, this.id});

  @override
  State<ChatMeetingPage> createState() => _ChatMeetingPageState();
}

class _ChatMeetingPageState extends State<ChatMeetingPage> {
  final storageService = StorageService();
  final userController = UserController(StorageService());
  bool isLoading = true;
  List<Map<String, dynamic>> records = [];
  String userId = "",
      userName = "",
      userEmail = "",
      userToken = "",
      userGroup = "";
  final TextEditingController _messageTextController = TextEditingController();

  bool _showAttachMenu = false;
  final ImagePicker _picker = ImagePicker();

  List<File> _selectedImages = [];
  List<File> _selectedDocs = [];

  final pb = PocketBase('https://pb.pemapi.com');
  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final authController = AuthController(ApiServive(), StorageService());
    final check = await authController.validateToken();
    if (check == 'success') {
      // print('Valid Token');
      _dataUser();
      fetchAllRecords();
      subscribeToCollectionChanges();
    } else {
      if (mounted) {
        showExpiredTokenDialog(context: context);
      }
    }
  }

  Future<void> _dataUser() async {
    final user = await userController.getUserFromStorage();
    // print(user?.user_group.toString());
    if (mounted) {
      setState(() {
        isLoading = true;
      });
      setState(() {
        userId = user!.uid.toString();
        userName = user.name.toString();
        userEmail = user.email.toString();
        userToken = user.token.toString();
        userGroup = user.user_group.toString();
        isLoading = false;
      });
    }
  }

  Future<void> fetchAllRecords() async {
    final result = await pb
        .collection('chat_meeting')
        .getList(filter: 'meeting_id="${widget.id}"');
    setState(() {
      isLoading = true;
      records = result.items.map((item) {
        // Gunakan .get<String>() untuk mengambil nama file tunggal
        final String fileName = item.get<String>('file_attach', '');

        String fileUrl = '';

        // Jika ada nama file, buat URL-nya
        if (fileName.isNotEmpty) {
          // Gunakan pb.files.getUrl untuk membuat URL file
          final url = pb.files.getUrl(item, fileName);
          fileUrl = url.toString();
        }

        return {
          'id': item.id,
          'meeting_id': item.data['meeting_id'] ?? '',
          'anggota_id': item.data['anggota_id'] ?? '',
          'nama_anggota': item.data['nama_anggota'] ?? '',
          'wilayah_anggota': item.data['wilayah_anggota'] ?? '',
          'chat_content': item.data['chat_content'] ?? '',
          'file_attach': fileUrl,
          'created': item.data['created'] ?? '',
        };
      }).toList();
      isLoading = false;
    });
  }

  void subscribeToCollectionChanges() {
    pb.collection('chat_meeting').subscribe('*', (e) {
      setState(() {
        final id = e.record?.id;
        if (e.action == 'create') {
          records.add({
            'id': id,
            'meeting_id': e.record?.data['meeting_id'] ?? '',
            'anggota_id': e.record?.data['anggota_id'] ?? '',
            'nama_anggota': e.record?.data['nama_anggota'] ?? '',
            'wilayah_anggota': e.record?.data['wilayah_anggota'] ?? '',
            'chat_content': e.record?.data['chat_content'] ?? '',
            'file_attach': e.record?.data['file_attach'] ?? '',
            'created': e.record?.data['created'] ?? '',
          });
        } else if (e.action == 'update') {
          final index = records.indexWhere((r) => r['id'] == id);
          if (index != -1) {
            records[index] = {
              'id': id,
              'meeting_id': e.record?.data['meeting_id'] ?? '',
              'anggota_id': e.record?.data['anggota_id'] ?? '',
              'nama_anggota': e.record?.data['nama_anggota'] ?? '',
              'wilayah_anggota': e.record?.data['wilayah_anggota'] ?? '',
              'chat_content': e.record?.data['chat_content'] ?? '',
              'file_attach': e.record?.data['file_attach'] ?? '',
              'created': e.record?.data['created'] ?? '',
            };
          }
        } else if (e.action == 'delete') {
          records.removeWhere((r) => r['id'] == id);
        }
      });
    });
  }

  @override
  void dispose() {
    pb.collection('chat_meeting').unsubscribe('*');
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageTextController.text.trim();

    // kalau tidak ada teks dan tidak ada file → stop
    if (message.isEmpty && _selectedImages.isEmpty && _selectedDocs.isEmpty) {
      return;
    }

    try {
      // 🔹 kirim setiap image sebagai record baru
      for (var file in _selectedImages) {
        final record = await pb.collection('chat_meeting').create(
          files: [
            http.MultipartFile.fromBytes(
              'file_attach',
              file.readAsBytesSync(),
              filename: file.path.split('/').last,
            )
          ],
        );

        final body = <String, dynamic>{
          'meeting_id': widget.id,
          'anggota_id': widget.userid,
          'nama_anggota': userName,
          'wilayah_anggota': 'Semarang',
        };
        await pb.collection('chat_meeting').update(record.id, body: body);
      }

      // 🔹 kirim setiap dokumen sebagai record baru
      for (var file in _selectedDocs) {
        final record = await pb.collection('chat_meeting').create(
          body: {
            "meeting_id": widget.id,
            "anggota_id": widget.userid,
            "nama_anggota": userName,
            "wilayah_anggota": "Semarang",
            "chat_content": "", // kosong kalau cuma file
          },
          files: [
            http.MultipartFile.fromBytes(
              'file_attach',
              file.readAsBytesSync(),
              filename: file.path.split('/').last,
            )
          ],
        );
        final body = <String, dynamic>{
          'meeting_id': widget.id,
          'anggota_id': widget.userid,
          'nama_anggota': userName,
          'wilayah_anggota': 'Semarang',
        };
        await pb.collection('chat_meeting').update(record.id, body: body);
      }

      // 🔹 kalau ada teks → kirim dulu sebagai 1 record
      if (message.isNotEmpty) {
        await pb.collection('chat_meeting').create(
          body: {
            "meeting_id": widget.id,
            "anggota_id": widget.userid,
            "nama_anggota": userName,
            "wilayah_anggota": "Semarang",
            "chat_content": message,
          },
        );
      }

      // reset form
      _messageTextController.clear();
      setState(() {
        _selectedImages.clear();
        _selectedDocs.clear();
      });

      print("✅ Semua pesan & file berhasil dikirim!");
    } catch (e) {
      print("❌ Error sending message: $e");
    }
  }

  void _toggleAttachMenu() {
    setState(() {
      _showAttachMenu = !_showAttachMenu;
    });
  }

  // Gallery multiple
  Future<void> _pickGallery() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images.map((f) => File(f.path)).toList();
        _showAttachMenu = false;
      });
    }
    setState(() => _showAttachMenu = false);
  }

  // Camera single
  Future<void> _pickCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _selectedImages.add(File(photo.path));
        _showAttachMenu = false;
      });
    }
    setState(() => _showAttachMenu = false);
  }

  // Document multiple
  Future<void> _pickDocuments() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _selectedDocs = result.paths.map((path) => File(path!)).toList();
        _showAttachMenu = false;
      });
    }
    setState(() => _showAttachMenu = false);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text("Chat Meeting",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          backgroundColor: const Color.fromARGB(255, 0, 48, 47),
        ),
        backgroundColor: const Color(0xFFf3f6f9),
        body: Stack(children: [
          Column(
            children: [
              // 🔹 List pesan
              Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : records.length != 0
                          ? ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: records.length,
                              reverse:
                                  true, // untuk menampilkan pesan terbaru di bawah
                              itemBuilder: (context, index) {
                                final reversedIndex =
                                    records.length - 1 - index;
                                final record = records[reversedIndex];

                                final file_attach = record['file_attach'] ?? '';
                                if (file_attach != '') {
                                  return chattingFile(
                                      index,
                                      record['anggota_id'].toString(),
                                      record['nama_anggota'],
                                      record['file_attach'],
                                      record['created']);
                                } else {
                                  return chattingText(
                                      index,
                                      record['anggota_id'].toString(),
                                      record['nama_anggota'],
                                      record['chat_content'],
                                      record['created']);
                                }
                              },
                            )
                          : const Center(child: Text('Belum ada data'))),
              // 🔹 Preview file (jika ada)
              if (_selectedImages.isNotEmpty || _selectedDocs.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFf3f6f9),
                    // border: const Border(
                    //   top: BorderSide(color: Colors.grey, width: 0.5),
                    // ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Preview Gambar
                        for (int i = 0; i < _selectedImages.length; i++)
                          Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 100,
                                height: 100,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Image.file(_selectedImages[i],
                                    fit: BoxFit.cover),
                              ),
                              Positioned(
                                right: 4,
                                top: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedImages.removeAt(i));
                                  },
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.black54,
                                    child: Icon(Icons.close,
                                        size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),

                        // Preview Dokumen
                        for (int i = 0; i < _selectedDocs.length; i++)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade700,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.insert_drive_file,
                                    color: Colors.white),
                                const SizedBox(width: 6),
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    _selectedDocs[i].path.split('/').last,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 13),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedDocs.removeAt(i));
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 6),
                                    child: Icon(Icons.close,
                                        size: 18, color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          // 🔹 Overlay untuk tutup menu
          if (_showAttachMenu)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _showAttachMenu = false),
                behavior: HitTestBehavior
                    .translucent, // biar tap di area kosong tetap bisa
                child: Container(color: Colors.transparent),
              ),
            ),

          // 🔹 Attach Menu dengan animasi
          _buildAttachMenu(),
        ]),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context)
                .viewInsets
                .bottom, // naik sesuai keyboard
          ),
          child: Container(
            height: 65,
            // width: (screenWidth/2),
            // margin: const EdgeInsets.only(left: 0.0, right: 1.0),
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              // border: Border.all(color: Colors.white),
              color: const Color(0xFFf3f6f9),
              // borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Row(
              children: [
                // 🔹 TextFormField dengan emoji di kiri + attachment + camera
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2C34), // warna field WhatsApp
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.attach_file,
                              color: Colors.grey, size: 22),
                          onPressed: _toggleAttachMenu,
                        ),
                        // const SizedBox(width: 20),
                        // const Icon(Icons.emoji_emotions_outlined,
                        //     color: Colors.grey, size: 24),
                        // const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _messageTextController,
                            textInputAction: TextInputAction
                                .newline, // 🔹 ganti "Done" jadi ENTER (newline)
                            keyboardType: TextInputType
                                .multiline, // 🔹 aktifkan multi-baris
                            maxLines: null,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Message",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                            onFieldSubmitted: (_) => _sendMessage(),
                            onTap: () =>
                                setState(() => _showAttachMenu = false),
                            enableInteractiveSelection:
                                false, // pastikan selection aktif
                            contextMenuBuilder: (BuildContext context,
                                EditableTextState editableTextState) {
                              return AdaptiveTextSelectionToolbar.editableText(
                                editableTextState: editableTextState,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // 🔹 Tombol hijau mic
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF005F5B),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => _sendMessage(),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget chattingText(int index, String anggota_id, String nama_anggota,
      String chat_content, String created) {
    String formatDate(String dateStr) {
      // parsing dari UTC
      DateTime dateUtc = DateTime.parse(dateStr);
      // konversi ke local (+7 kalau device pakai WIB)
      DateTime dateLocal = dateUtc.toLocal();
      // format hasil
      // final df = DateFormat('dd MMM yyyy HH:mm', 'id_ID');
      final df = DateFormat('HH:mm', 'id_ID');
      return df.format(dateLocal);
    }

    double screenWidth = MediaQuery.of(context).size.width;

    return Align(
        alignment: widget.userid == anggota_id
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
          decoration: BoxDecoration(
            color: widget.userid == anggota_id
                ? const Color(0xFF005F5B)
                : const Color(0xFF1F2C34),
            borderRadius: BorderRadius.circular(10),
          ),
          constraints: BoxConstraints(
            minWidth: 100, // lebar minimal
            maxWidth: screenWidth * 0.75, // lebar maksimal
            // minHeight: 50,   // tinggi minimal
            // maxHeight: 100,  // tinggi maksimal
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: widget.userid != anggota_id ? true : false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama_anggota,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              // const SizedBox(height: 4),
              Text(
                chat_content,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                formatDate(created),
                style: const TextStyle(fontSize: 10, color: Colors.white70),
              ),
            ],
          ),
        ));
  }

  Widget chattingFile(int index, String anggota_id, String nama_anggota,
      String file_attach, String created) {
    String formatDate(String dateStr) {
      // parsing dari UTC
      DateTime dateUtc = DateTime.parse(dateStr);
      // konversi ke local (+7 kalau device pakai WIB)
      DateTime dateLocal = dateUtc.toLocal();
      // format hasil
      // final df = DateFormat('dd MMM yyyy HH:mm', 'id_ID');
      final df = DateFormat('HH:mm', 'id_ID');
      return df.format(dateLocal);
    }

    double screenWidth = MediaQuery.of(context).size.width;

    void downloadFile(String url) async {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final originalFileName = url.split('/').last;
          final filePath = '${tempDir.path}/${url.split('/').last}';
          final file = File(filePath);

          final downloadsDir = Directory('/storage/emulated/0/Download');
          await file.copy('${downloadsDir.path}/$originalFileName');

          if (mounted) {
            Fluttertoast.showToast(
              msg: 'File Berhasil Diunduh!',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        } else {
          if (mounted) {
            Fluttertoast.showToast(
              msg: 'Gagal mengunduh file.',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: 'Error: $e',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
    }

    return file_attach.endsWith('.jpg') ||
            file_attach.endsWith('.jpeg') ||
            file_attach.endsWith('.png')
        ? GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return FullScreenImage(
                  imageUrl: file_attach,
                  namaAnggota: nama_anggota,
                  created: formatDate(created),
                  tag: "generate_a_unique_tag",
                );
              }));
            },
            child: Align(
                alignment: widget.userid == anggota_id
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: widget.userid == anggota_id
                        ? const Color(0xFF005F5B)
                        : const Color(0xFF1F2C34),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 100, // lebar minimal
                    maxWidth: screenWidth * 0.75, // lebar maksimal
                    // minHeight: 50,   // tinggi minimal
                    // maxHeight: 100,  // tinggi maksimal
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: widget.userid != anggota_id ? true : false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nama_anggota,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                      // const SizedBox(height: 4),

                      // ClipRRect(
                      //   borderRadius: BorderRadius.circular(10),
                      //   child: Image.network(file_attach),
                      // ) // Tampilkan sebagai gambar jika formatnya sesuai
                      // : Text('Dokumen: ${file_attach.split('/').last}'),
                      // Container(
                      //   padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                      //   decoration: BoxDecoration(
                      //     borderRadius: const BorderRadius.all(Radius.circular(10)),
                      //     image: DecorationImage(
                      //       image: NetworkImage(
                      //         file_attach, // URL gambar
                      //       ),
                      //       fit: BoxFit.cover, // atur cover / contain / fill
                      //     )
                      //   ),
                      //   // height: 60,
                      //   width: double.infinity
                      // ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            Image.network(
                              file_attach,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Jika gagal memuat gambar, tampilkan ikon dokumen
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  color: Colors.blueGrey.shade700,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.insert_drive_file,
                                          color: Colors.white),
                                      const SizedBox(width: 6),
                                      SizedBox(
                                        width: 120,
                                        child: Text(
                                          file_attach.split('/').last,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  formatDate(created),
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.white70),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      // const SizedBox(height: 4),
                      // Text(
                      //   formatDate(created),
                      //   style: const TextStyle(fontSize: 10, color: Colors.white70),
                      // ),
                    ],
                  ),
                )))
        : Align(
            alignment: widget.userid == anggota_id
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: widget.userid == anggota_id
                    ? const Color(0xFF005F5B)
                    : const Color(0xFF1F2C34),
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: BoxConstraints(
                minWidth: 100, // lebar minimal
                maxWidth: screenWidth * 0.75, // lebar maksimal
                // minHeight: 50,   // tinggi minimal
                // maxHeight: 100,  // tinggi maksimal
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                    visible: widget.userid != anggota_id ? true : false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nama_anggota,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 4),

                  // ClipRRect(
                  //   borderRadius: BorderRadius.circular(10),
                  //   child: Image.network(file_attach),
                  // ) // Tampilkan sebagai gambar jika formatnya sesuai
                  // : Text('Dokumen: ${file_attach.split('/').last}'),
                  // Container(
                  //   padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                  //   decoration: BoxDecoration(
                  //     borderRadius: const BorderRadius.all(Radius.circular(10)),
                  //     image: DecorationImage(
                  //       image: NetworkImage(
                  //         file_attach, // URL gambar
                  //       ),
                  //       fit: BoxFit.cover, // atur cover / contain / fill
                  //     )
                  //   ),
                  //   // height: 60,
                  //   width: double.infinity
                  // ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.insert_drive_file,
                            color: Colors.white),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 120,
                          child: Text(
                            file_attach.split('/').last,
                            // overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 26),
                        InkWell(
                          onTap: () {
                            // buka file di browser
                            // downloadFile(file_attach);
                            downloadFile(file_attach);
                          },
                          child: const Icon(Icons.downloading,
                              size: 35, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  // Add missing closing brackets for Column and its children
                ],
              ),
            ),
          );
  }

  Widget _buildAttachMenu() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      bottom: _showAttachMenu ? 0 : -300, // sembunyi di bawah layar
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: _showAttachMenu ? 1 : 0,
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            children: [
              _buildAttachItem(Icons.image, "Gallery", Colors.blue,
                  onTap: _pickGallery),
              _buildAttachItem(Icons.camera_alt, "Camera", Colors.pink,
                  onTap: _pickCamera),
              _buildAttachItem(
                  Icons.insert_drive_file, "Document", Colors.purple,
                  onTap: _pickDocuments),
              // _buildAttachItem(Icons.audiotrack, "Audio", Colors.orange),
              // _buildAttachItem(Icons.location_on, "Location", Colors.green),
              // _buildAttachItem(Icons.person, "Contact", Colors.cyan),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachItem(IconData icon, String label, Color color,
      {VoidCallback? onTap}) {
    return AnimatedScale(
      scale: _showAttachMenu ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      child: GestureDetector(
        onTap: onTap,
        // ?? () {
        //   setState(() => _showAttachMenu = false);
        //   print("$label clicked");
        // },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String? imageUrl;
  final String tag;
  final String namaAnggota;
  final String created;

  const FullScreenImage(
      {super.key,
      this.imageUrl,
      required this.tag,
      required this.namaAnggota,
      required this.created});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(namaAnggota,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            Text(created,
                style: const TextStyle(color: Colors.white, fontSize: 12))
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              onPressed: () {
                _downloadImage(context, imageUrl ?? '');
              }),
        ],
      ),
      body: InteractiveViewer(
        panEnabled: true,
        boundaryMargin: const EdgeInsets.all(0),
        minScale: 0.1,
        maxScale: 5.0,
        clipBehavior: Clip.none,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Hero(
            tag: tag,
            child: CachedNetworkImage(
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.contain,
              imageUrl: imageUrl ?? '',
              placeholder: (context, url) => const CircularProgressIndicator(
                color: Colors.white,
              ),
              errorWidget: (context, url, error) => const Icon(
                Icons.error,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _downloadImage(BuildContext context, String url) async {
    try {
      if (url == null || url.isEmpty) {
        Fluttertoast.showToast(
          msg: 'Invalid image url',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      }
      final image = await http.get(Uri.parse(url));
      if (image.statusCode == 200) {
        Uint8List bytes = image.bodyBytes;

        // 🔹 Simpan ke galeri
        await SaverGallery.saveImage(bytes,
            fileName: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
            skipIfExists: true);

        Fluttertoast.showToast(
          msg: 'Gambar berhasil disimpan di galeri',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Gagal mengunduh gambar',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error downloading image: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
