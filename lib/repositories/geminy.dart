import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class GeminiRepository {
  late final GenerativeModel _model;
  late final ChatSession chat;
  final String apiKey;

  GeminiRepository({required this.apiKey}) {
    _init();
  }

  void _init() async {
    final apiKey = dotenv.env['API_KEY'];

    if (apiKey == null) {
      throw Exception('API_KEY is not defined in the environment');
    }

    _model = GenerativeModel(model: "gemini-pro-vision", apiKey: apiKey);
    chat = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    final response = await chat.sendMessage(Content.text(message));
    final text = response.text;
    if (text == null) {
      return 'No response from API.';
    }
    return text;
  }

  Future<String> sendMessageWithImage(String textInput, XFile image) async {
    try {
      if (await image.length() == 0) {
        print("Error: No image selected or invalid file");
        return '';
      }

      final text = textInput;
      final imageBytes = await image.readAsBytes();
      final content =
          Content.multi([TextPart(text), DataPart(image.path, imageBytes)]);

      print('Sending image...'
          'Path: ${image.path}'
          'Text: $textInput'
          'Image: ${imageBytes.length} bytes');

      final response = await _model.generateContent([content]);
      return response.text ?? 'No response from API.';
    } catch (e) {
      print('Error: $e');
      return '';
    }
  }
}
