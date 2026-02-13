import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

// ✅ Updated imports
import '../services/vision_service.dart';
import '../services/firebase_service.dart';
import '../services/openai_service.dart';
import '../models/monument.dart';
import 'result_screen.dart';

class CameraScreen extends StatefulWidget {
  final String userId;
  final List<String> userInterests;

  const CameraScreen({
    super.key,
    required this.userId,
    required this.userInterests,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image;
  bool _isProcessing = false;
  String _statusMessage = '';

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isProcessing = true;
          _statusMessage = 'Analyzing image...';
        });

        await _recognizeMonument();
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _recognizeMonument() async {
    if (_image == null) return;

    final visionService = context.read<VisionService>();
    final firebaseService = context.read<FirebaseService>();

    try {
      // Step 1: Recognize using Cloud Vision
      setState(() => _statusMessage = 'Recognizing monument...');
      final detectedNames = await visionService.recognizeMonument(_image!);

      if (detectedNames.isEmpty) {
        _showError('Could not identify monument. Try a clearer photo.');
        return;
      }

      // Step 2: Search in Firebase
      setState(() => _statusMessage = 'Fetching monument details...');
      Monument? monument;
      
      for (var name in detectedNames) {
        monument = await firebaseService.searchMonumentByName(name);
        if (monument != null) break;
      }

      if (monument == null) {
        _showError(
          'Monument not recognized. Detected: ${detectedNames.first}\n'
          'This monument is not yet in our database.',
        );
        return;
      }

      // Step 3: Navigate to result
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              monument: monument!,
              userId: widget.userId,
              userInterests: widget.userInterests,
            ),
          ),
        );
      }
    } catch (e) {
      _showError('Recognition failed: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showError(String message) {
    setState(() {
      _isProcessing = false;
      _statusMessage = '';
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Recognition Failed', style: GoogleFonts.poppins()),
        content: Text(message, style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _image = null);
            },
            child: Text('Try Again', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Text('CultureScan', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFFF6F00),
      ),
      body: _isProcessing
          ? _buildProcessingView()
          : _image != null
              ? _buildImagePreview()
              : _buildCameraOptions(),
    );
  }

  Widget _buildCameraOptions() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 30),
            Text(
              'Scan a Monument',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Point your camera at a historical monument\nto learn about its cultural significance',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 50),

            // Camera Button
            _buildOptionButton(
              icon: Icons.camera_alt,
              label: 'Take Photo',
              onTap: () => _pickImage(ImageSource.camera),
            ),
            const SizedBox(height: 20),

            // Gallery Button
            _buildOptionButton(
              icon: Icons.photo_library,
              label: 'Choose from Gallery',
              onTap: () => _pickImage(ImageSource.gallery),
              isPrimary: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = true,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: isPrimary ? Colors.white : const Color(0xFFFF6F00)),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isPrimary ? Colors.white : const Color(0xFFFF6F00),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFFFF6F00) : Colors.white,
          foregroundColor: isPrimary ? Colors.white : const Color(0xFFFF6F00),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: isPrimary
                ? BorderSide.none
                : const BorderSide(color: Color(0xFFFF6F00), width: 2),
          ),
          elevation: isPrimary ? 3 : 0,
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.file(_image!, height: 300),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => setState(() => _image = null),
            child: const Text('Retake'),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6F00)),
          ),
          const SizedBox(height: 30),
          Text(
            _statusMessage,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}