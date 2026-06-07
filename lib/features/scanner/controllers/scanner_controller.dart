import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../data/services/mlkit_service.dart';

class ScannerController extends ChangeNotifier {
  final MLKitService _mlKitService = MLKitService();
  CameraController? cameraController;
  bool isCameraInitialized = false;
  bool isProcessing = false;

  Future<void> initCamera() async {
    cameraController = await _mlKitService.initializeCamera();
    if (cameraController != null) {
      isCameraInitialized = true;
    }
    notifyListeners();
  }

  Future<String?> captureImage() async {
    if (cameraController == null || !cameraController!.value.isInitialized) return null;
    isProcessing = true;
    notifyListeners();

    try {
      final XFile file = await cameraController!.takePicture();
      final String? extractedText = await _mlKitService.processMeterImage(file.path);
      isProcessing = false;
      notifyListeners();
      return extractedText;
    } catch (e) {
      isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    _mlKitService.dispose();
    super.dispose();
  }
}
