import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../routes.dart';
import '../controllers/scanner_controller.dart';

class CroppingScreen extends StatefulWidget {
  final String imagePath;
  const CroppingScreen({super.key, required this.imagePath});

  @override
  State<CroppingScreen> createState() => _CroppingScreenState();
}

class _CroppingScreenState extends State<CroppingScreen> {
  final ScannerController _controller = ScannerController();
  bool _isProcessing = false;

  Future<void> _handleCrop() async {
    setState(() => _isProcessing = true);
    final extractedText = await _controller.cropAndProcessImage(widget.imagePath);
    setState(() => _isProcessing = false);

    if (mounted && extractedText != null && extractedText.isNotEmpty) {
      Navigator.pushReplacementNamed(context, AppRoutes.confirmation, arguments: extractedText);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to extract reading or crop was cancelled.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Review Image', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: _isProcessing 
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryYellow))
          : Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Please review the photo before cropping.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24.0),
                      child: Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      style: AppTheme.darkButtonStyle,
                      icon: const Icon(Icons.crop),
                      label: const Text('Proceed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: _handleCrop,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
