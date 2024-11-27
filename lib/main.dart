import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _switchCamera,
              child: Text("Switch Camera"),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CameraPreviewWithSwitch(),
  ));
}
