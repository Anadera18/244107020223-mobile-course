import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 40),
        const SizedBox(height: 8),
        Text(message.replaceFirst('Exception: ', ''),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        FilledButton(onPressed: onRetry, child: const Text('Retry')),
      ]),
    );
  }
}
