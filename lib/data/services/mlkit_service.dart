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
      print('Camera initialization error: \$e');
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
      print('ML Kit Processing Error: \$e');
      return null;
    }
  }

  //Cleaning logic
  String _cleanExtractedText(String rawText) {
    // Rule A (Numeric Only): Strip all alphabetical text and noise.
    String numbersOnly = rawText.replaceAll(RegExp(r'[^0-9\s]'), ' ');

    // Rule B (Length Match): Reject sequences that look like long serial numbers 
    Iterable<Match> matches = RegExp(r'\b\d{5,8}\b').allMatches(numbersOnly);

    for (Match m in matches) {
      String sequence = m.group(0)!;
      // Rule C (Red Decimal Elimination): If we matched 5 to 8 digits, 
      return sequence.substring(0, 5);
    }

    return ''; // Return empty if no valid sequence is found
  }

  // Disposing the recognizer to prevent memory leaks
  void dispose() {
    _textRecognizer.close();
  }
}
