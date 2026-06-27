import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../core/validators.dart';

import '../../../data/local/storage_service.dart';
import '../../../routes.dart';

class ConfirmationScreen extends StatefulWidget {
  final String extractedText;

  const ConfirmationScreen({super.key, required this.extractedText});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  late TextEditingController _textController;
  final bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.extractedText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    final readingStr = _textController.text;
    final validationError = Validators.validateMeterReading(readingStr);
    
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(validationError),
        backgroundColor: AppTheme.errorRed,
      ));
      return;
    }

    // Since the reading was already uploaded by ScannerController 
    // and processed by the server, "Confirming" just completes the flow.
    // If the backend needs a separate confirm step, the ApiService call would go here.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reading confirmed!'))
      );
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.menu, arguments: AppRoutes.confirmation),
        ),
        title: const Text('Confirm Meter Reading', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(24.0),
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          decoration: BoxDecoration(
            color: AppTheme.primaryYellow,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Your Meter Reading is', 
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              // Read-only text field for the reading
              TextField(
                controller: _textController,
                readOnly: true,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 48, 
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  letterSpacing: 4.0,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  filled: false,
                ),
              ),
              
              const SizedBox(height: 48),
              
              const Text(
                'I confirm that the reading is correct', 
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              
              // Confirm Button (Dark)
              SizedBox(
                width: 180,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2C2E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  onPressed: _isSaving ? null : _handleConfirm,
                  child: _isSaving 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Confirm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              
              // Try Again Button (White)
              SizedBox(
                width: 180,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Try Again', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
