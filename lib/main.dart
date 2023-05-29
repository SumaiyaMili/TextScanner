import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocr/result_screen.dart';
import 'package:permission_handler/permission_handler.dart';

final textRecognizer = TextRecognizer();
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  bool _isPermissionGranted = false;
  late final Future<void> _future;
  late File? _image;
  bool _isImageLoaded = false;

  // Add this controller to be able to control de camera
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.removeObserver(this);
    _future = _requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    textRecognizer.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
      _startCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (BuildContext context, snapshot) {
          return Column(children: [
            if (_isImageLoaded && _image != null)
              Expanded(
                child: Center(
                  child: Image.file(_image!),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: const EdgeInsets.all(30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _captureImage,
                        child: const Text('Camera'),
                      ),
                      ElevatedButton(
                        onPressed: _selectImage,
                        child: const Text('Gallery'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_isImageLoaded && _image != null)
              Container(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: _scanImage,
                    child: const Text('Scan text'),
                  ),
                ),
              ),
          ]);
        }

        //   Stack(
        //   children: [
        //     // Show the camera feed behind everything
        //     if (_isPermissionGranted)
        //       FutureBuilder<List<CameraDescription>>(
        //         future: availableCameras(),
        //         builder: (context, snapshot) {
        //           if (snapshot.hasData) {
        //             _initCameraController(snapshot.data!);
        //
        //             return Center(child: CameraPreview(_cameraController!));
        //           } else {
        //             return const LinearProgressIndicator();
        //           }
        //         },
        //       ),
        //     Scaffold(
        //       appBar: AppBar(
        //         title: const Text('Text Recognition Sample'),
        //       ),
        //       // Set the background to transparent so you can see the camera preview
        //       backgroundColor: _isPermissionGranted ? Colors.transparent : null,
        //       body: _isPermissionGranted
        //           ? Column(
        //               children: [
        //                 Expanded(
        //                   child: Container(),
        //                 ),
        //                 Container(
        //                   padding: const EdgeInsets.only(bottom: 30.0),
        //                   child: Row(
        //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //                     children: [
        //                       ElevatedButton(
        //                         onPressed: _captureImage,
        //                         child: const Text('Camera'),
        //                       ),
        //                       ElevatedButton(
        //                         onPressed: _selectImage,
        //                         child: const Text('Gallery'),
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //                 if (_isImageLoaded && _image != null)
        //                   Container(
        //                     padding: const EdgeInsets.only(bottom: 30.0),
        //                     child: Center(
        //                       child: ElevatedButton(
        //                         onPressed: _scanImage,
        //                         child: const Text('Scan text'),
        //                       ),
        //                     ),
        //                   ),
        //               ],
        //             )
        //           : Center(
        //               child: Container(
        //                 padding: const EdgeInsets.only(left: 24.0, right: 24.0),
        //                 child: const Text(
        //                   'Camera permission denied',
        //                   textAlign: TextAlign.center,
        //                 ),
        //               ),
        //             ),
        //     ),
        //   ],
        // );

        );
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    _isPermissionGranted = status == PermissionStatus.granted;
  }

  void _startCamera() {
    if (_cameraController != null) {
      _cameraSelected(_cameraController!.description);
    }
  }

  void _stopCamera() {
    if (_cameraController != null) {
      _cameraController?.dispose();
    }
  }

  void _initCameraController(List<CameraDescription> cameras) {
    if (_cameraController != null) {
      return;
    }

    // Select the first rear camera.
    CameraDescription? camera;
    for (var i = 0; i < cameras.length; i++) {
      final CameraDescription current = cameras[i];
      if (current.lensDirection == CameraLensDirection.back) {
        camera = current;
        break;
      }
    }

    if (camera != null) {
      _cameraSelected(camera);
    }
  }

  Future<void> _cameraSelected(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _captureImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
        _isImageLoaded = true;
      });
    }
  }

  Future<void> _selectImage() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
        _isImageLoaded = true;
      });
    }
  }

  Future<void> _scanImage() async {
    if (_image == null) return;

    final navigator = Navigator.of(context);

    try {
      final inputImage = InputImage.fromFile(_image!);
      final recognizedText = await textRecognizer.processImage(inputImage);
      print(recognizedText.text);
      await navigator.push(
        MaterialPageRoute(
          builder: (BuildContext context) =>
              ResultScreen(text: recognizedText.text),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred when scanning text'),
        ),
      );
    }
  }

  // Future<void> _scanImage() async {
  //   if (_cameraController == null) return;
  //
  //   final navigator = Navigator.of(context);
  //
  //   try {
  //     final pictureFile = await _cameraController!.takePicture();
  //
  //     final file = File(pictureFile.path);
  //
  //     final inputImage = InputImage.fromFile(file);
  //     final recognizedText = await textRecognizer.processImage(inputImage);
  //
  //     await navigator.push(
  //       MaterialPageRoute(
  //         builder: (BuildContext context) =>
  //             ResultScreen(text: recognizedText.text),
  //       ),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('An error occurred when scanning text'),
  //       ),
  //     );
  //   }
  // }
}
