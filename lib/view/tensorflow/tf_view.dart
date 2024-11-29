import 'dart:async';

import 'package:came/Class/tflite_model.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // Import the camera package
import 'package:image/image.dart' as img; // Import the image package

class TfCamera extends StatefulWidget {
  const TfCamera({super.key});

  @override
  State<TfCamera> createState() => _TfCameraState();
}

class _TfCameraState extends State<TfCamera> {
  TFLiteModel tfliteController = TFLiteModel();

  bool _isCameraInitialized = false;
  late CameraController
      _cameraController; // Camera controller to control the camera
  late List<CameraDescription> _cameras; // List of available cameras

  int? _classificationResult; // Store the classification result

  @override
  void initState() {
    super.initState();
    _initializeCamera(); // Initialize camera when the widget is created
    tfliteController.loadModel(); // Load the TFLite model
  }

  Future<void> _initializeCamera() async {
    try {
      // Get the available cameras
      _cameras = await availableCameras();

      // Check if there are available cameras
      if (_cameras.isNotEmpty) {
        // Initialize the first available camera
        _cameraController = CameraController(
          _cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );

        // Initialize the camera
        await _cameraController.initialize();
        setState(() {
          _isCameraInitialized =
              true; // Update the state when initialization is complete
        });
      } else {
        print("No cameras found.");
      }
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  // Dispose of the camera controller when done
  @override
  void dispose() {
    _cameraController.dispose(); // Properly dispose of the camera controller
    super.dispose();
  }

  Future<void> _processImage(String imagePath) async {
    int result = await tfliteController.processImage(imagePath);
    setState(() {
      _classificationResult = result; // Update the classification result
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ตรวจจับบัตรประชาชน"), // Thai for "ID Card Detection"
      ),
      body: Stack(
        children: [
          // Display the camera preview if initialized, otherwise show loading indicator
          if (_isCameraInitialized)
            CameraPreview(_cameraController)
          else
            const Center(child: CircularProgressIndicator()),
          if (_classificationResult != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Prediction: $_classificationResult',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Take a picture when the button is pressed
          try {
            // Ensure the camera is initialized
            if (!_isCameraInitialized) return;

            // Capture the picture
            // final XFile imageFile = await _cameraController.takePicture();
            // print("Image captured: ${imageFile.path}");

            // img.Image? image = img.decodeImage(await imageFile.readAsBytes());
            // if (image != null) {
            //   // Process the image
            //   await _processImage(imageFile.path);
            // }

            Timer.periodic(Duration(seconds: 1), (timer) async {
              try {
                // Capture the picture
                final XFile imageFile = await _cameraController.takePicture();
                print("Image captured: ${imageFile.path}");

                // Decode the image
                img.Image? image =
                    img.decodeImage(await imageFile.readAsBytes());

                // if (image != null) {
                //   print("Image decoded successfully.");
                // }
                if (image != null) {
                  print("Image decoded successfully.");

                  // Process the image
                  _processImage(imageFile.path);
                  // print("Predicted class: $predictedClass");
                } else {
                  print("Failed to decode the image.");
                }
              } catch (e) {
                print("Error in camera loop: $e");
              }
            });
          } catch (e) {
            print('Error capturing image: $e');
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
