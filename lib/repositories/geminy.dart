import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiRepository {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final String apiKey;

  GeminiRepository._({required this.apiKey});

  static Future<GeminiRepository> create({required String apiKey}) async {
    final instance = GeminiRepository._(apiKey: apiKey);
    instance._init();
    return instance;
  }

  void _init() async {
    final apiKey = dotenv.env['API_KEY'];

    if (apiKey == null) {
      throw Exception('API_KEY is not defined in the environment');
    }
    
    _model = GenerativeModel(model: "gemini-pro", apiKey: apiKey);
    _chat = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    final response = await _chat.sendMessage(Content.text(message));
    final text = response.text;
    if (text == null) {
      return 'No response from API.';
    }
    return text;
  }
}
