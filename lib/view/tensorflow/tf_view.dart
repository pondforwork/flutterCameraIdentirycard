import 'package:came/Class/tflite_model.dart';
import 'package:came/Controller/tflite_controller.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart'; // Import the camera package
import 'package:get/get.dart';
import 'package:image/image.dart' as img; // Import the image package

class TfCamera extends StatefulWidget {
  const TfCamera({super.key});

  @override
  State<TfCamera> createState() => _TfCameraState();
}

class _TfCameraState extends State<TfCamera> {
  // TfliteController tfliteController = Get.put(TfliteController());

  TFLiteModel tfliteController = TFLiteModel();

  bool _isCameraInitialized = false;
  late CameraController
      _cameraController; // Camera controller to control the camera
  late List<CameraDescription> _cameras; // List of available cameras

  @override
  void initState() {
    super.initState();
    _initializeCamera(); // Initialize camera when the widget is created
    // tfliteController.loadModel();
    tfliteController.loadModel();
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Take a picture when the button is pressed
          try {
            // Ensure the camera is initialized
            await _cameraController.initialize();

            // Capture the picture
            final XFile imageFile = await _cameraController.takePicture();
            print("Image captured: ${imageFile.path}");

            img.Image? image = img.decodeImage(await imageFile.readAsBytes());
            if (image != null) {
              // Preprocess the image to match model input

              await tfliteController.processImage(imageFile.path);

              // Run the model with the preprocessed image
              // var result = await tfliteController.runModel(inputTensor);

              // Print the result or process it further
              // print('Model result: $result');
            }
          } catch (e) {
            print('Error capturing image: $e');
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
