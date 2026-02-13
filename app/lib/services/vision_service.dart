import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';

class VisionService {
  static const String _baseUrl =
      'https://vision.googleapis.com/v1/images:annotate';

  // Recognize monument from image
  Future<List<String>> recognizeMonument(File imageFile) async {
    try {
      // Convert image to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('$_baseUrl?key=${ApiKeys.googleCloudVisionKey}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requests': [
            {
              'image': {'content': base64Image},
              'features': [
                {'type': 'LANDMARK_DETECTION', 'maxResults': 5},
                {'type': 'LABEL_DETECTION', 'maxResults': 10},
                {'type': 'WEB_DETECTION', 'maxResults': 5},
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final annotations = data['responses'][0];

        List<String> detectedNames = [];

        // Priority 1: Landmark detection (most accurate)
        if (annotations['landmarkAnnotations'] != null) {
          for (var landmark in annotations['landmarkAnnotations']) {
            detectedNames.add(landmark['description']);
          }
        }

        // Priority 2: Web entities (if landmark not found)
        if (detectedNames.isEmpty && annotations['webDetection'] != null) {
          final webEntities = annotations['webDetection']['webEntities'];
          if (webEntities != null) {
            for (var entity in webEntities) {
              if (entity['description'] != null) {
                detectedNames.add(entity['description']);
              }
            }
          }
        }

        // Priority 3: Labels (fallback)
        if (detectedNames.isEmpty && annotations['labelAnnotations'] != null) {
          for (var label in annotations['labelAnnotations']) {
            detectedNames.add(label['description']);
          }
        }

        return detectedNames;
      } else {
        print('Vision API Error: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Vision Service Error: $e');
      return [];
    }
  }
}