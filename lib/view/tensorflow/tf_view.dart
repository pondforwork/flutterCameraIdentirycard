import 'package:came/Controller/tflite_controller.dart';
import 'package:flutter/material.dart';

class TensorFlowView extends StatefulWidget {
  const TensorFlowView({super.key});

  @override
  State<TensorFlowView> createState() => _TensorFlowViewState();
}

class _TensorFlowViewState extends State<TensorFlowView> {
  TfliteController tfliteController = TfliteController();
  @override
  void initState() {
    super.initState();
    tfliteController.loadModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
