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
  List<DetectedObject> _detectedObjects = [];

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

        // Update detected objects and check if ID card is present
        setState(() {
          _detectedObjects = objects;
          _detectionResult = objects.any((object) => _isIDCard(object))
              ? "พบบัตรประชาชน"
              : "ไม่พบบัตรประชาชน";
        });
      } catch (e) {
        print("Error during detection: $e");
      } finally {
        _isProcessing = false;
      }
    });
  }

  bool _isIDCard(DetectedObject object) {
    // Logic to check if object is an ID card
    const double minWidth = 100;
    const double minHeight = 50;
    // const double minAspectRatio = 1.5;
    // const double maxAspectRatio = 2.5;

    // final boundingBox = object.boundingBox;
    // final double width = boundingBox.width;
    // final double height = boundingBox.height;
    // final double aspectRatio = width / height;

    // if (width < minWidth || height < minHeight) return false;
    // if (aspectRatio < minAspectRatio || aspectRatio > maxAspectRatio)
    //   return false;
    return true;
  }

  List<Widget> _buildBoundingBoxes() {
    return _detectedObjects.map((object) {
      final boundingBox = object.boundingBox;
      return Positioned(
        left: boundingBox.left,
        top: boundingBox.top,
        width: boundingBox.width,
        height: boundingBox.height,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
    }).toList();
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
      body: Stack(
        children: [
          if (_isCameraInitialized)
            CameraPreview(_cameraController)
          else
            Center(child: CircularProgressIndicator()),
          if (_isCameraInitialized) ..._buildBoundingBoxes(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _detectionResult,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
