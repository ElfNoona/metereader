import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../data/remote/api_service.dart';
import '../../../data/local/storage_service.dart';

class ScannerController extends ChangeNotifier {
  CameraController? cameraController;
  bool isCameraInitialized = false;
  bool isProcessing = false;
  bool isFlashOn = false;
  
  final ApiService _apiService;

  ScannerController({ApiService? apiService}) 
    : _apiService = apiService ?? ApiService();

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
      print('Error toggling flash: $e');
    }
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await cameraController!.initialize();
      isCameraInitialized = true;
      notifyListeners();
    }
  }

  // Captures the photo and returns its file path
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

  // Opens the native cropper and then uploads the cropped result to the backend.
  Future<Map<String, String>?> cropAndProcessImage(String imagePath) async {
    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Meter Reading',
            toolbarColor: const Color(0xFFFFD13B),
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Meter Reading',
          ),
        ],
      );

      if (croppedFile != null) {
        isProcessing = true;
        notifyListeners();

        final userId = await StorageService.getUserId() ?? '';

        final response = await _apiService.uploadFile(
          '/reading/submit',
          croppedFile.path,
          {
            'userId': userId,
            'isManualOverride': 'false',
          }
        );

        isProcessing = false;
        notifyListeners();

        if (response.statusCode == 200 || response.statusCode == 201) {
           return {
             'readingId': response.data['reading']['_id'].toString(),
             'extractedText': response.data['reading']['rawOcrValue'].toString()
           };
        }
        return null;
      }
      return null;
    } catch (e) {
      print('Network processing error: $e');
      isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }
}
