import 'dart:io';
import 'package:image/image.dart';

class ImageSharpnessCalculate {
  double laplacianVariance(Image image) {
    // Convert image to grayscale
    Image grayImage = grayscale(image);

    // Initialize Laplacian matrix
    List<List<int>> laplacianImage = List.generate(
        grayImage.height, (_) => List<int>.filled(grayImage.width, 0));

    // Apply Laplacian filter to detect edges
    int width = grayImage.width;
    int height = grayImage.height;

    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        int sum = 0;
        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            int pixel = grayImage.getPixel(x + kx, y + ky);
            int grayValue = getLuminance(pixel); // Grayscale intensity of pixel
            sum += grayValue *
                [-1, -1, -1, -1, 8, -1, -1, -1, -1][(ky + 1) * 3 + (kx + 1)];
          }
        }
        laplacianImage[y][x] = sum;
      }
    }

    // Calculate variance of Laplacian
    int mean = 0;
    int count = 0;
    int sumSquares = 0;
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        int lapVal = laplacianImage[y][x];
        mean += lapVal;
        sumSquares += lapVal * lapVal;
        count++;
      }
    }

    mean ~/= count;
    double variance = ((sumSquares ~/ count) - (mean * mean)) as double;
    return variance.toDouble();
  }

  double compareBlurriness(String imagePath1, String imagePath2) {
    // Load images
    final image1 = decodeImage(File(imagePath1).readAsBytesSync());
    final image2 = decodeImage(File(imagePath2).readAsBytesSync());

    if (image1 == null || image2 == null) {
      throw Exception("Error loading images.");
    }

    // Calculate Laplacian variance for both images
    double variance1 = laplacianVariance(image1);
    double variance2 = laplacianVariance(image2);

    print("Image 1 Laplacian variance: $variance1");
    print("Image 2 Laplacian variance: $variance2");

    // Compare variance to determine which is sharper (less blurry)
    if (variance1 > variance2) {
      print("Image 1 is sharper.");
    } else if (variance2 > variance1) {
      print("Image 2 is sharper.");
    } else {
      print("Both images have the same sharpness.");
    }

    return variance1 - variance2;
  }

  void showSharpness(String imagePath) {
    // Load the image
    final image = decodeImage(File(imagePath).readAsBytesSync());

    if (image == null) {
      throw Exception("Error loading image.");
    }

    // Calculate Laplacian variance for the image (sharpness value)
    double variance = laplacianVariance(image);
    print("Sharpness value (Laplacian variance) of the image: $variance");

    // Higher variance indicates sharper image
    if (variance > 1000) {
      print("The image is sharp.");
    } else {
      print("The image is blurry.");
    }
  }
}
