import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../data/services/mlkit_service.dart';

class ScannerController extends ChangeNotifier {
  final MLKitService _mlKitService = MLKitService();
  CameraController? cameraController;
  bool isCameraInitialized = false;
  bool isProcessing = false;
  bool isFlashOn = false;

  Future<void> toggleFlash() async {
    if (cameraController == null || !cameraController!.value.isInitialized) return;
    
    try {
      if (isFlashOn) {
        await cameraController!.setFlashMode(FlashMode.off);
        isFlashOn = false;
      } else {
        await cameraController!.setFlashMode(FlashMode.torch);
        isFlashOn = true;
      }
      notifyListeners();
    } catch (e) {
      print('Error toggling flash: \$e');
    }
  }

  Future<void> initCamera() async {
    cameraController = await _mlKitService.initializeCamera();
    if (cameraController != null) {
      isCameraInitialized = true;
    }
    notifyListeners();
  }

  // Captures the photo and returns its file path, without running ML Kit yet.
  Future<String?> captureImage() async {
    if (cameraController == null || !cameraController!.value.isInitialized) return null;
    isProcessing = true;
    notifyListeners();

    try {
      final XFile file = await cameraController!.takePicture();
      isProcessing = false;
      notifyListeners();
      return file.path;
    } catch (e) {
      isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  // Opens the native cropper and then passes the cropped result to ML Kit.
  Future<String?> cropAndProcessImage(String imagePath) async {
    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Meter Reading',
            toolbarColor: const Color(0xFFFFD13B), // AppTheme.primaryYellow
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ],
          ),
          IOSUiSettings(
            title: 'Crop Meter Reading',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ],
          ),
        ],
      );

      if (croppedFile != null) {
        // Run ML Kit only on the freshly cropped file
        final String? extractedText = await _mlKitService.processMeterImage(croppedFile.path);
        return extractedText;
      }
      return null;
    } catch (e) {
      print('Cropping error: \$e');
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
