import 'package:flutter/material.dart';

import 'ai/ai_service.dart';
import 'ai/secure_api_key_store.dart';
import 'features/chat/chat_page.dart';

void main() {
  runApp(const CampusAiApp());
}

class CampusAiApp extends StatelessWidget {
  const CampusAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus AI Assistant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF335CFF)),
        useMaterial3: true,
      ),
      home: ChatPage(
        service: AiService(keyStore: SecureApiKeyStore()),
        keyStore: SecureApiKeyStore(),
      ),
    );
  }
}
