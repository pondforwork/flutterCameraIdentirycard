import 'package:get/get.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

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

  // Future<List<double>> preprocessImage(img.Image image) async {
  //   img.Image resizedImage =
  //       img.copyResize(image, width: 300, height: 300); // Resize to 300x300
  //   List<double> input = [];
  //   for (int y = 0; y < resizedImage.height; y++) {
  //     for (int x = 0; x < resizedImage.width; x++) {
  //       int pixel = resizedImage.getPixel(x, y);
  //       int r = img.getRed(pixel);
  //       int g = img.getGreen(pixel);
  //       int b = img.getBlue(pixel);
  //       input.add(r / 255.0); // Normalize the pixel values
  //       input.add(g / 255.0);
  //       input.add(b / 255.0);
  //     }
  //   }

  //   // Now return the input as a 4D tensor with shape [1, 300, 300, 3]
  //   return input;
  // }

  Future<List<List<List<List<double>>>>> preprocessImage(
      img.Image image) async {
    img.Image resizedImage = img.copyResize(image, width: 300, height: 300);

    // Create a 4D tensor with shape [1, 300, 300, 3]
    List<List<List<List<double>>>> tensor = [
      List.generate(
          300, (_) => List.generate(300, (_) => List.generate(3, (_) => 0.0)))
    ];

    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        int pixel = resizedImage.getPixel(x, y);
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);

        tensor[0][y][x][0] = r / 255.0;
        tensor[0][y][x][1] = g / 255.0;
        tensor[0][y][x][2] = b / 255.0;
      }
    }

    return tensor;
  }

  // Run the model with the input tensor
  Future<List<double>> runModel(List<List<List<List<double>>>> input) async {
    // Prepare an output buffer to hold the results
    var output =
        List.filled(10, 0.0); // Adjust based on your model's output size

    // Run the model with the input and output buffer
    interpreter.run(input, output);
    // Return the output
    return output;
  }

  // Example method to use preprocessing and model inference
  Future<List<double>> predict(img.Image image) async {
    var inputTensor = await preprocessImage(image);
    var result = await runModel(inputTensor);
    return result;
  }
}
