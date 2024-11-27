import 'dart:async';

import 'package:came/Class/image_sharpness_calculate.dart';
import 'package:came/view/image_picker_view.dart';
import 'package:came/view/live_id_card_detection_view.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';

import 'package:get/get.dart';

class CameraPreviewWithSwitch extends StatefulWidget {
  @override
  _CameraPreviewWithSwitchState createState() =>
      _CameraPreviewWithSwitchState();
}

class _CameraPreviewWithSwitchState extends State<CameraPreviewWithSwitch> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  int _currentCameraIndex = 0;
  File? _imageFile;

  List<File> _capturedImages = [];
  Timer? _captureTimer;
  int _captureCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _currentCameraIndex = 0; // Start with the first camera (usually back)
        _setupCamera(_cameras[_currentCameraIndex]);
      } else {
        print("No cameras available.");
      }
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    _cameraController = CameraController(camera, ResolutionPreset.high);
    await _cameraController.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  void _switchCamera() {
    if (_cameras.length > 1) {
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
      _setupCamera(_cameras[_currentCameraIndex]);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No secondary camera available")),
      );
    }
  }

  void _goToCardDetect() {
    Get.to(IDCardDetectionPage());
  }

  Future<void> _captureImage() async {
    try {
      final image = await _cameraController.takePicture();
      setState(() {
        _imageFile = File(image.path);
      });
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  Future<void> _captureImageContinuously() async {
    ImageSharpnessCalculate imageSharpnessCalculate = ImageSharpnessCalculate();
    _captureCount = 0;
    _capturedImages.clear();

    for (int i = 0; i < 5; i++) {
      try {
        final image = await _cameraController.takePicture();
        print("Capture ${_captureCount + 1}");
        setState(() {
          _capturedImages.add(File(image.path));

          File pickedImage = File(image.path);

          // imageSharpnessCalculate.showSharpness(pickedImage.path);
          _captureCount++;
        });
        await Future.delayed(
            Duration(milliseconds: 250)); // Wait 0.2s before next capture
      } catch (e) {
        print("Error capturing image: $e");
        break; // Stop capturing if an error occurs
      }
    }

    print("Captured $_captureCount images.");
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Camera Preview with Switch")),
      body: Column(
        children: [
          if (_isCameraInitialized)
            Expanded(
              child: CameraPreview(_cameraController),
            )
          else
            Center(child: CircularProgressIndicator()),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _switchCamera,
                  child: Text("Switch Camera"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _goToCardDetect,
                  child: Text("Go to Detect Card"),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _captureImage,
              child: Text("Capture Image"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _captureImageContinuously,
              child: Text("Capture Continously"),
            ),
          ),
          if (_imageFile != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.file(
                _imageFile!,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: (() {
        Get.to(ImagePickerView());
        print("Clicked");
      })),
    );
  }
}

void main() {
  runApp(GetMaterialApp(
    home: CameraPreviewWithSwitch(),
  ));
}
