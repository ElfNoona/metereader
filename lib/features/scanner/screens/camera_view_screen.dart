import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../core/app_theme.dart';
import '../../../routes.dart';
import '../controllers/scanner_controller.dart';

class CameraViewScreen extends StatefulWidget {
  const CameraViewScreen({super.key});

  @override
  State<CameraViewScreen> createState() => _CameraViewScreenState();
}

class _CameraViewScreenState extends State<CameraViewScreen> {
  late ScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScannerController();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _controller.initCamera();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleCapture() async {
    final imagePath = await _controller.captureImage();
    if (mounted && imagePath != null && imagePath.isNotEmpty) {
      Navigator.pushNamed(context, AppRoutes.cropping, arguments: imagePath);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to take picture. Please try again.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
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
          onPressed: () {}, // Hamburger menu
        ),
        title: const Text('Submit Reading', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppTheme.primaryYellow),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: AppTheme.primaryYellow,
          borderRadius: BorderRadius.circular(32.0),
        ),
        child: Column(
          children: [
            const Text(
              'Upload you electricity meter reading\nBefore 30 Oct 2021',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Stack(
                children: [
                  // Dashed Border Outline
                  Positioned.fill(
                    child: CustomPaint(
                      painter: DashedRectPainter(
                        color: Colors.white,
                        strokeWidth: 2,
                        gap: 8,
                      ),
                    ),
                  ),
                  // Camera Preview Area
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_controller.isCameraInitialized && _controller.cameraController != null)
                            SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: CameraPreview(_controller.cameraController!),
                            )
                          else
                            const Center(child: CircularProgressIndicator(color: Colors.white)),
                          
                          // Dark overlay to make white text readable over camera
                          Container(
                            color: Colors.black.withOpacity(0.3),
                          ),

                          // Overlay Icons & Text
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 64),
                              const SizedBox(height: 16),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 32.0),
                                child: Text(
                                  'Ignore any red numbers on your meter or anything after decimal points.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                ),
                                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                                label: const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: _controller.isProcessing ? null : _handleCapture,
                              ),
                            ],
                          ),
                          
                          // Flashlight toggle button (Moved here so it sits on top of the dark overlay!)
                          if (_controller.isCameraInitialized)
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    _controller.isFlashOn ? Icons.flash_on : Icons.flash_off,
                                    color: AppTheme.primaryYellow,
                                  ),
                                  onPressed: () => _controller.toggleFlash(),
                                ),
                              ),
                            ),

                          if (_controller.isProcessing)
                            Container(
                              color: Colors.black54,
                              child: const Center(
                                child: CircularProgressIndicator(color: AppTheme.primaryYellow),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Black Submit Button per wireframe
            SizedBox(
              width: 180,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2C2E), // Dark Grey/Black
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                onPressed: _controller.isProcessing ? null : _handleCapture,
                child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for dashed borders
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({this.color = Colors.white, this.strokeWidth = 2.0, this.gap = 5.0});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    
    var path = Path()
      ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(24)));

    PathMetrics pathMetrics = path.computeMetrics();
    Path dashPath = Path();
    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
