import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

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

    _model = GenerativeModel(model: "gemini-pro", apiKey: apiKey);
    chat = _model.startChat();
  }

  Future<String> sendMessage(String message, String mode) async {
    final response = await chat.sendMessage(Content.text(
        "Please respond to this prompt in a " + mode + " way: " + message));
    final text = response.text;
    if (text == null) {
      return 'No response from API.';
    }
    return text;
  }

  // Future<String> sendMessageWithImage(String textInput, List<Uint8List> imageBytes) async {
  //   var content= Content.text(textInput);

  //   final response = await _chat.sendMessage(Content.multi(content, ...imageBytes));
  //   final text = response.text;
  //   if (text == null) {
  //     return 'No response from API.';
  //   }
  //   return text;
  // }
}
