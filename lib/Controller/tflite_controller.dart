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

  Future<List<double>> preprocessImage(img.Image image) async {
    // Resize the image to the required input size (e.g., 300x300)
    img.Image resizedImage = img.copyResize(image, width: 300, height: 300);

    // Normalize the pixel values to [0, 1]
    List<double> input = [];

    // Loop through the resized image and normalize each pixel
    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        int pixel = resizedImage.getPixel(x, y);

        // Extract RGB values from the pixel
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);

        // Normalize RGB values and add them to the input list
        input.add(r / 255.0); // Normalize red
        input.add(g / 255.0); // Normalize green
        input.add(b / 255.0); // Normalize blue
      }
    }

    return input; // Return the flattened input tensor
  }

  // Run the model with the input tensor
  Future<List<double>> runModel(List<double> input) async {
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
    List<double> inputTensor = await preprocessImage(image);
    List<double> result = await runModel(inputTensor);
    return result;
  }
}
