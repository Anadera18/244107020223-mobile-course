enum ChatRole { user, assistant }

class ChatMessage {
  const ChatMessage(
      {required this.text, required this.role, this.isOffline = false});

  final String text;
  final ChatRole role;
  final bool isOffline;
}
