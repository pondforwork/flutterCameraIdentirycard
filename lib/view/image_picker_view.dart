import 'dart:io';
import 'package:came/Class/image_sharpness_calculate.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// import 'best_image_picker_page.dart';
class ImagePickerView extends StatefulWidget {
  @override
  _ImagePickerViewState createState() => _ImagePickerViewState();
}

class _ImagePickerViewState extends State<ImagePickerView> {
  final ImagePicker _picker = ImagePicker();
  ImageSharpnessCalculate imageSharpnessCalculate = ImageSharpnessCalculate();
  List<File> _pickedImages = [];

  // Function to pick multiple images
  Future<void> _pickImages() async {
    // final pickedFiles = await _picker.pickMultiImage();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    File? _pickedImage;

    // File? pickedImage = File(pickedFile.path);

    // if (pickedFile != null) {
    //   imageSharpnessCalculate.calculateSharpness(pickedFile);
    //   // setState(() {
    //   //   _pickedImages = pickedFiles.map((e) => File(e.path)).toList();
    //   // });
    // }

    if (pickedFile != null) {
      // File conversion is safe now because pickedFile is not null
      File pickedImage = File(pickedFile.path);

      // Call your image sharpness calculation method
      imageSharpnessCalculate.showSharpness(pickedFile.path);

      // Optionally update the state if you need to display the image
      setState(() {
        _pickedImage = pickedImage; // Store the selected image in _pickedImage
      });
    } else {
      // Handle the case when no image is picked (e.g., user cancels the action)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No image selected")),
      );
    }
  }

  // Navigate to the BestImagePickerPage and pass the selected images
  void _navigateToBestImagePicker() {
    if (_pickedImages.isNotEmpty) {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => BestImagePickerPage(images: _pickedImages),
      //   ),
      // );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please pick some images first")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick Images'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _pickImages,
            child: Text('Pick 5 Images'),
          ),
          ElevatedButton(
            onPressed: _navigateToBestImagePicker,
            child: Text('Go to Best Image Picker'),
          ),
          if (_pickedImages.isNotEmpty) ...[
            SizedBox(height: 20),
            Text('Picked Images:'),
            // Use Expanded widget to make sure the ListView takes up available space
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _pickedImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Image.file(_pickedImages[index]),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
