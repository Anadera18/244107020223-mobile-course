import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_key_store.dart';

class AiServiceException implements Exception {
  const AiServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AiService {
  AiService({
    required ApiKeyStore keyStore,
    http.Client? client,
    this.model = 'gemini-2.5-flash',
  })  : _keyStore = keyStore,
        _client = client ?? http.Client();

  final ApiKeyStore _keyStore;
  final http.Client _client;
  final String model;

  static const systemPrompt =
      'You are Campus AI Assistant, a friendly academic helper. '
      'Answer in Indonesian in at most three short sentences. '
      'Do not request or reveal private student information. '
      'If unsure, say so and suggest checking an official campus source.';

  Future<String> ask(String question) async {
    final apiKey = await _keyStore.read();
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw const AiServiceException('Tambahkan API key Gemini di Pengaturan.');
    }

    final uri = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$model:generateContent',
    );
    late final http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': apiKey,
            },
            body: jsonEncode({
              'systemInstruction': {
                'parts': [
                  {'text': systemPrompt},
                ],
              },
              'contents': [
                {
                  'role': 'user',
                  'parts': [
                    {'text': question},
                  ],
                },
              ],
              'generationConfig': {'maxOutputTokens': 256, 'temperature': 0.4},
            }),
          )
          .timeout(const Duration(seconds: 25));
    } on Exception {
      throw const AiServiceException(
        'Tidak dapat terhubung ke AI. Periksa jaringan lalu coba lagi.',
      );
    }

    if (response.statusCode != 200) {
      throw AiServiceException(
        response.statusCode == 429
            ? 'Batas penggunaan tercapai. Coba lagi nanti.'
            : 'Layanan AI sedang bermasalah (${response.statusCode}). Coba lagi nanti.',
      );
    }

    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = decoded['candidates'] as List<dynamic>?;
      final content = candidates?.first['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;
      final answer = parts
          ?.map((part) => (part as Map<String, dynamic>)['text'] as String?)
          .whereType<String>()
          .join('\n')
          .trim();
      if (answer == null || answer.isEmpty) {
        throw const FormatException('Missing text');
      }
      return answer;
    } on Object {
      throw const AiServiceException(
        'Respons AI tidak dapat dibaca. Silakan coba lagi.',
      );
    }
  }
}
