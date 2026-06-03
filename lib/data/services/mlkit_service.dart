import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class MLKitService {
  // Instance of the ML Kit text recognizer
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );
  //Camera logic
  Future<CameraController?> initializeCamera() async {
    try {
      // Get list of available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras found on this device');
      }
      // Try to find the back camera, otherwise fallback to the first available
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      // Initialize the controller with max resolution (better for OCR)
      final controller = CameraController(
        backCamera,
        ResolutionPreset.max,
        enableAudio: false, // Audio not needed for meter reading.
      );

      await controller.initialize();
      return controller;
    } catch (e) {
      // Handle permission denied or camera errors here
      print('Camera initialization error: $e');
      return null;
    }
  }

  //ML kit feeder logic
  Future<String?> processMeterImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);

      // Extract raw text from the image
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      // Combine all extracted text blocks into a single string
      String fullRawText = recognizedText.text;

      // Pass it through the cleaning logic
      return _cleanExtractedText(fullRawText);
    } catch (e) {
      print('ML Kit Processing Error: $e');
      return null;
    }
  }

  //Cleaning logic
  //Removes all letters, symbols, spaces, and formatting, leaving only the meter number.
  String _cleanExtractedText(String rawText) {
    // Remove all characters EXCEPT digits (0-9) and the decimal point (.)
    // This strips out "kWh", spaces, dashes, or accidental OCR noise.
    String cleaned = rawText.replaceAll(RegExp(r'[^0-9.]'), '');

    // OCR sometimes misinterprets noise as extra decimals.
    // If multiple decimals exist, we keep only the first one to ensure it's a valid number.
    if (cleaned.contains('.')) {
      List<String> parts = cleaned.split('.');
      if (parts.length > 2) {
        // Reconstruct string keeping only the first decimal point
        cleaned = '${parts[0]}.${parts.sublist(1).join('')}';
      }
    }

    return cleaned;
  }

  // Disposing the recognizer to prevent memory leaks
  void dispose() {
    _textRecognizer.close();
  }
}
