import 'dart:io';
import 'package:image/image.dart' as img;

class ImageSharpnessCalculate {
  double calculateSharpness(File imageFile) {
    // Load the image from file
    img.Image? image = img.decodeImage(imageFile.readAsBytesSync());

    if (image == null) return 0.0;

    // Convert the image to grayscale
    img.Image grayscale = img.grayscale(image);

    // Variable to store sharpness score
    double sharpness = 0.0;

    // Loop through each pixel and calculate the Laplacian to estimate sharpness
    for (int y = 1; y < grayscale.height - 1; y++) {
      for (int x = 1; x < grayscale.width - 1; x++) {
        // Get pixel values at the current pixel and adjacent pixels
        int pixel = grayscale.getPixel(x, y) as int;
        int pixelRight = grayscale.getPixel(x + 1, y) as int;
        int pixelDown = grayscale.getPixel(x, y + 1) as int;

        // Calculate differences in pixel intensity
        int dx = (pixelRight - pixel).abs();
        int dy = (pixelDown - pixel).abs();

        // Add the squared differences to the sharpness score
        sharpness += (dx * dx + dy * dy);
      }
    }

    return sharpness;
  }
}
