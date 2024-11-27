import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'dart:async';

class IDCardDetectionPage extends StatefulWidget {
  @override
  _IDCardDetectionPageState createState() => _IDCardDetectionPageState();
}

class _IDCardDetectionPageState extends State<IDCardDetectionPage> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String _detectionResult = "กำลังตรวจจับ..."; // Default: Detecting
  Timer? _detectionTimer;
  late ObjectDetector _objectDetector;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeObjectDetector();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _cameraController = CameraController(
          _cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
        _startDetection();
      } else {
        print("No cameras found.");
      }
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  void _initializeObjectDetector() {
    final options = ObjectDetectorOptions(
      mode: DetectionMode.stream,
      classifyObjects: false,
      multipleObjects: true,
    );
    _objectDetector = ObjectDetector(options: options);
  }

  void _startDetection() {
    _detectionTimer =
        Timer.periodic(Duration(milliseconds: 200), (timer) async {
      if (!_isCameraInitialized || _isProcessing) return;

      _isProcessing = true;

      try {
        print("Detecting");
        final image = await _cameraController.takePicture();
        final inputImage = InputImage.fromFilePath(image.path);

        // Detect objects in the image
        final objects = await _objectDetector.processImage(inputImage);

        // Check if an ID card is detected
        bool hasIDCard = objects.any((object) => _isIDCard(object));

        setState(() {
          _detectionResult = hasIDCard ? "พบบัตรประชาชน" : "ไม่พบบัตรประชาชน";
        });
      } catch (e) {
        print("Error during detection: $e");
      } finally {
        _isProcessing = false;
      }
    });
  }

  bool _isIDCard(DetectedObject object) {
    // Define logic to check if the object is an ID card
    // Example: Check object labels or bounding box size
    return object.boundingBox.width > 100 && object.boundingBox.height > 50;
  }

  @override
  void dispose() {
    _detectionTimer?.cancel();
    _cameraController.dispose();
    _objectDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ตรวจจับบัตรประชาชน")),
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
            child: Text(
              _detectionResult,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
