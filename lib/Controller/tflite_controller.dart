import 'package:get/get.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TfliteController extends GetxController {
  late Interpreter interpreter;

  //  double laplacianVariance(Image image) {
  //   // Convert image to grayscale
  //   Image grayImage = grayscale(image);

  //   // Initialize Laplacian matrix
  //   List<List<int>> laplacianImage = List.generate(
  //       grayImage.height, (_) => List<int>.filled(grayImage.width, 0));

  //   // Apply Laplacian filter to detect edges
  //   int width = grayImage.width;
  //   int height = grayImage.height;

  //   for (int y = 1; y < height - 1; y++) {
  //     for (int x = 1; x < width - 1; x++) {
  //       int sum = 0;
  //       for (int ky = -1; ky <= 1; ky++) {
  //         for (int kx = -1; kx <= 1; kx++) {
  //           int pixel = grayImage.getPixel(x + kx, y + ky);
  //           int grayValue = getLuminance(pixel); // Grayscale intensity of pixel
  //           sum += grayValue *
  //               [-1, -1, -1, -1, 8, -1, -1, -1, -1][(ky + 1) * 3 + (kx + 1)];
  //         }
  //       }
  //       laplacianImage[y][x] = sum;
  //     }
  //   }

  //   // Calculate variance of Laplacian
  //   int mean = 0;
  //   int count = 0;
  //   int sumSquares = 0;
  //   for (int y = 1; y < height - 1; y++) {
  //     for (int x = 1; x < width - 1; x++) {
  //       int lapVal = laplacianImage[y][x];
  //       mean += lapVal;
  //       sumSquares += lapVal * lapVal;
  //       count++;
  //     }
  //   }

  //   // mean ~/= count;
  //   // double variance = ((sumSquares ~/ count) - (mean * mean)) as double;

  //   mean ~/= count;
  //   double variance = (sumSquares / count) - (mean * mean).toDouble();

  //   return variance.toDouble();
  // }

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('assets/ssd_mobilenet.tflite');
      print('Model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  Future<List> preprocessImage(img.Image image) async {
    // Resize image to the required input size (e.g., 300x300)
    img.Image resizedImage = img.copyResize(image, width: 300, height: 300);

    // Normalize pixel values to [0, 1] range
    List<double> input = [];
    for (int i = 0; i < resizedImage.width; i++) {
      for (int j = 0; j < resizedImage.height; j++) {
        int pixel = resizedImage.getPixel(i, j);

        // Extract RGB components from the pixel value
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);

        // Normalize and add the RGB values to the input list
        input.add(r / 255.0);
        input.add(g / 255.0);
        input.add(b / 255.0);
      }
    }

    // The input tensor should have the shape [1, 300, 300, 3]
    // Flatten the input to [1, 300, 300, 3] format
    var inputTensor = input.reshape([1, 300, 300, 3]);
    return inputTensor;
  }
}
