import 'package:Eksys/controllers/old/inventory_controller.dart';
import 'package:Eksys/functions/global_functions.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:path/path.dart' as path;

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final String? token;
  const TakePictureScreen({super.key, this.token, required this.camera});

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  FlashMode _flashMode = FlashMode.off;

  double _currentZoom = 1.0;
  double _baseZoom = 1.0;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  void _toggleFlash() async {
    FlashMode newMode;
    switch (_flashMode) {
      case FlashMode.off:
        newMode = FlashMode.torch;
        break;
      case FlashMode.torch:
        newMode = FlashMode.off;
        break;
      default:
        newMode = FlashMode.off;
    }

    setState(() {
      _flashMode = newMode;
    });

    await _controller.setFlashMode(newMode);
  }

  void _handleFocus(TapDownDetails details, BuildContext context) async {
    if (!_controller.value.isInitialized) return;

    final size = MediaQuery.of(context).size;
    final offset = Offset(
      details.localPosition.dx / size.width,
      details.localPosition.dy / size.height,
    );

    await _controller.setFocusPoint(offset);
    await _controller.setExposurePoint(offset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Take a picture')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Stack(
              children: [
                SizedBox.expand(
                  child: GestureDetector(
                    onTapDown: (details) => _handleFocus(details, context),
                    onScaleStart: (details) {
                      _baseZoom = _currentZoom;
                    },
                    onScaleUpdate: (details) async {
                      double newZoom = (_baseZoom * details.scale)
                          .clamp(1.0, _controller.value.aspectRatio);
                      setState(() {
                        _currentZoom = newZoom;
                      });
                      await _controller.setZoomLevel(newZoom);
                    },
                    child: CameraPreview(_controller),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 30,
                  child: IconButton(
                    icon: Icon(
                      _flashMode == FlashMode.torch
                          ? Icons.flash_on
                          : Icons.flash_off,
                      color: Colors.white,
                      // size: 30,
                    ),
                    onPressed: _toggleFlash,
                  ),
                ),
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        backgroundColor: Colors.white,
        // elevation: 0,
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            if (!context.mounted) return;

            // If the picture was taken, display it on a new screen.

            // setState(() {
            //   _image = File(image.path);
            // });

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  token: widget.token.toString(),
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(
          Icons.camera_alt,
          color: Colors.black,
          size: 30,
        ),
      ),
    );
  }
}

// File? _image;
// late InventoryController inventoryController;

class DisplayPictureScreen extends StatefulWidget {
  final String? token;
  // final String? outletId;
  final String? imagePath;
  const DisplayPictureScreen({super.key, this.token, this.imagePath});

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreen();
}

// A widget that displays the picture taken by the user.
class _DisplayPictureScreen extends State<DisplayPictureScreen> {
  late InventoryController inventoryController;

  void _uploadImage() async {
    String fileName = path.basename(File(widget.imagePath.toString()).path);
    
    FormData formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(
        File(widget.imagePath.toString()).path,
        filename: fileName,
      ),
    });

    showLoadingDialog(context: context);
    inventoryController = InventoryController();
    var response = await inventoryController.uploadImage(widget.token.toString(),formData);
    if (response) {
      hideLoadingDialog(context);
      Navigator.pop(context, 'refresh');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      // appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Center(
            child: Image.file(
              File(widget.imagePath.toString()),
              fit: BoxFit.fill, // or BoxFit.cover for edge-to-edge
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: screenWidth,
              color: const Color.fromARGB(61, 0, 0, 0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.camera_alt, color: Colors.white, size: 30),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.save, color: Colors.white, size: 30),
                      onPressed: () {
                        _uploadImage();
                      },
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
