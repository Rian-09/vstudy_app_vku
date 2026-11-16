import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class MlKitOcrDataSource {
  MlKitOcrDataSource({TextRecognizer? recognizer})
    : _recognizer = recognizer ?? TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

  Future<String> recognizeFile(String imagePath) async {
    if (kIsWeb) {
      throw UnsupportedError('OCR ML Kit chỉ hỗ trợ Android và iOS.');
    }
    final inputImage = InputImage.fromFilePath(imagePath);
    final result = await _recognizer.processImage(inputImage);
    return result.text.trim();
  }

  Future<void> dispose() => _recognizer.close();
}
