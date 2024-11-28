import 'package:get/get.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class TfliteController extends GetxController {
  late Interpreter interpreter;

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('assets/ssd_mobilenet.tflite');
      print('Model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
    }
  }
}
