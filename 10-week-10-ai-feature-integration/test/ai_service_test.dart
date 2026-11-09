import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:week10_ai_feature_integration/ai/ai_service.dart';
import 'package:week10_ai_feature_integration/ai/api_key_store.dart';

class _MemoryKeyStore implements ApiKeyStore {
  _MemoryKeyStore(this.key);

  String? key;

  @override
  Future<void> delete() async => key = null;

  @override
  Future<String?> read() async => key;

  @override
  Future<void> write(String value) async => key = value;
}

void main() {
  test('sends prompt and parses Gemini text with the key in a header',
      () async {
    http.Request? captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response(
        jsonEncode({
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Belajar bertahap dan konsisten.'},
                ],
              },
            },
          ],
        }),
        200,
      );
    });
    final service =
        AiService(keyStore: _MemoryKeyStore('test-secret'), client: client);

    final answer = await service.ask('Bagaimana cara belajar?');

    expect(answer, 'Belajar bertahap dan konsisten.');
    expect(captured!.headers['x-goog-api-key'], 'test-secret');
    expect(captured!.url.queryParameters, isEmpty);
    final body = jsonDecode(captured!.body) as Map<String, dynamic>;
    expect(body['contents'][0]['parts'][0]['text'], 'Bagaimana cara belajar?');
    expect(
        body['systemInstruction']['parts'][0]['text'], AiService.systemPrompt);
    expect(body['generationConfig']['maxOutputTokens'], 256);
    client.close();
  });

  test('requires an API key before requesting the network', () async {
    final client =
        MockClient((_) async => fail('network should not be called'));
    final service = AiService(keyStore: _MemoryKeyStore(null), client: client);

    await expectLater(service.ask('Halo'), throwsA(isA<AiServiceException>()));
    client.close();
  });

  test('maps rate limits to a friendly error', () async {
    final client = MockClient((_) async => http.Response('{}', 429));
    final service =
        AiService(keyStore: _MemoryKeyStore('test-secret'), client: client);

    await expectLater(
      service.ask('Halo'),
      throwsA(isA<AiServiceException>()
          .having((e) => e.message, 'message', contains('Batas penggunaan'))),
    );
    client.close();
  });

  test('rejects an empty or malformed model response', () async {
    final client =
        MockClient((_) async => http.Response('{"candidates":[]}', 200));
    final service =
        AiService(keyStore: _MemoryKeyStore('test-secret'), client: client);

    await expectLater(service.ask('Halo'), throwsA(isA<AiServiceException>()));
    client.close();
  });
}
