import 'package:flutter/material.dart';

import '../../ai/ai_service.dart';
import '../../ai/api_key_store.dart';
import 'chat_message.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.service, required this.keyStore});

  final AiService service;
  final ApiKeyStore keyStore;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <ChatMessage>[
    const ChatMessage(
      text: 'Halo! Saya asisten akademik kampus. Apa yang ingin kamu tanyakan?',
      role: ChatRole.assistant,
    ),
  ];
  bool _isLoading = false;
  String? _status;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final question = _controller.text.trim();
    if (question.isEmpty || _isLoading) return;
    if (question.length > 500) {
      setState(() => _status = 'Pertanyaan maksimal 500 karakter.');
      return;
    }

    setState(() {
      _status = null;
      _isLoading = true;
      _messages.add(ChatMessage(text: question, role: ChatRole.user));
      _controller.clear();
    });
    _jumpToBottom();

    try {
      final answer = await widget.service.ask(question);
      if (!mounted) return;
      setState(() => _messages.add(
            ChatMessage(text: answer, role: ChatRole.assistant),
          ));
    } on AiServiceException catch (error) {
      if (!mounted) return;
      setState(() {
        _status = error.message;
        _messages.add(const ChatMessage(
          text:
              'Contoh offline: coba tanyakan topik kuliah, Flutter, atau cara belajar. Untuk jawaban terbaru, periksa sumber resmi kampus.',
          role: ChatRole.assistant,
          isOffline: true,
        ));
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _jumpToBottom();
      }
    }
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _openSettings() async {
    final savedKey = await widget.keyStore.read();
    if (!mounted) return;
    final keyController = TextEditingController(text: savedKey);
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pengaturan Gemini'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('API key disimpan di secure storage perangkat.'),
            const SizedBox(height: 12),
            TextField(
              controller: keyController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Gemini API key',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Jangan bagikan key atau kirim data pribadi.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'delete'),
            child: const Text('Hapus key'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (action == 'save' && keyController.text.trim().isNotEmpty) {
      await widget.keyStore.write(keyController.text.trim());
      if (mounted) setState(() => _status = 'API key tersimpan dengan aman.');
    } else if (action == 'delete') {
      await widget.keyStore.delete();
      if (mounted) setState(() => _status = 'API key telah dihapus.');
    }
    keyController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Campus AI'),
            Text('Gemini study assistant', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            key: const Key('settingsButton'),
            tooltip: 'Pengaturan API key',
            onPressed: _openSettings,
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                key: const Key('chatList'),
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: _messages.length,
                itemBuilder: (context, index) =>
                    _MessageBubble(message: _messages[index]),
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('AI sedang menyiapkan jawaban...'),
                  ],
                ),
              ),
            if (_status case final status?)
              Container(
                key: const Key('statusBanner'),
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(status),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('questionField'),
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 500,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Tanyakan sesuatu...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    key: const Key('sendButton'),
                    onPressed: _isLoading ? null : _send,
                    tooltip: 'Kirim pertanyaan',
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? colors.primary : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isUser ? const Radius.circular(5) : null,
            bottomLeft: isUser ? null : const Radius.circular(5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.isOffline)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  'MODE OFFLINE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ),
            Text(
              message.text,
              style: TextStyle(
                  color: isUser ? colors.onPrimary : colors.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
