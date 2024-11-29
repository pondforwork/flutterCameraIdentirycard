import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img; // To handle image processing
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteModel {
  late Interpreter _interpreter;

  Future<void> loadModel() async {
    try {
      // Load the model file from assets
      final modelFile = await _loadModelFile('assets/model_coco_mobile.tflite');

      // Convert ByteData to Uint8List
      final modelData = modelFile.buffer.asUint8List();

      // Load the model using the converted Uint8List
      _interpreter = await Interpreter.fromBuffer(modelData);

      print("Model loaded successfully!");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  // Helper function to load the model from the assets
  Future<ByteData> _loadModelFile(String path) async {
    final modelData = await rootBundle.load(path);
    return modelData;
  }

  Future<int> processImage(String imagePath) async {
    try {
      // Load the image
      File imageFile = File(imagePath);
      img.Image image = img.decodeImage(imageFile.readAsBytesSync())!;
      print("Image loaded successfully.");

      // Resize the image to match the model input shape
      int height = 224;
      int width = 224;
      img.Image resizedImage =
          img.copyResize(image, width: width, height: height);
      print("Image resized to $width x $height.");

      // Convert the image to a list of integers (Uint8List)
      List<int> imageList = resizedImage.getBytes();
      print("Image converted to Uint8List.");

      // Convert the image bytes to a Uint8List
      Uint8List imageData = Uint8List.fromList(imageList);

      // Reshape the data to match the model input shape [1, 224, 224, 3]
      List<List<List<List<int>>>> input = List.generate(
        1,
        (i) => List.generate(
          height,
          (j) => List.generate(
            width,
            (k) => List.generate(3, (l) => imageData[(j * width + k) * 3 + l]),
          ),
        ),
      );

      // Run inference
      var output = List<List<num>>.generate(
          1, (_) => List.filled(2, 0.0, growable: false));

      _interpreter.run(input, output);

      List<double> softmax(List<double> logits) {
        double maxLogit =
            logits.reduce((a, b) => a > b ? a : b); // For numerical stability
        List<double> exps =
            logits.map((logit) => exp(logit - maxLogit)).toList();
        double sumExps = exps.reduce((a, b) => a + b);
        return exps.map((e) => e / sumExps).toList();
      }

      List<double> predictions = output[0].map((e) => e.toDouble()).toList();
      List<double> probabilities = softmax(predictions);

      // Find the class with the highest probability
      int predictedClass =
          probabilities.indexOf(probabilities.reduce((a, b) => a > b ? a : b));

      print("Probabilities: $probabilities");
      print("Predicted class: $predictedClass");

      // Return the predicted class
      return predictedClass;
    } catch (e) {
      print("Error processing image: $e");
      // Return a default error class, e.g., -1
      return -1;
    }
  }

  void startImageProcessingLoop(String imagePath) {
    Timer.periodic(Duration(seconds: 1), (timer) async {
      try {
        int predictedClass = await processImage(imagePath);
        print("Predicted Class: $predictedClass");
      } catch (e) {
        print("Error during image processing: $e");
      }
    });
  }

  // Function to get predicted class
  int getPredictedClass(List<dynamic> output) {
    int predictedClass = output.indexOf(output.reduce((a, b) => a > b ? a : b));
    return predictedClass;
  }
}
