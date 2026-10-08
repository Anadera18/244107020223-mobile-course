import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api_errors.dart';
import '../data/token_store.dart';
import '../providers/auth_provider.dart';
import '../providers/push_provider.dart';

/// Evidence page for the report: shows ONLY truncated tokens, push status,
/// the three-state event log, and buttons that force the auth edge cases.
class DebugPage extends ConsumerStatefulWidget {
  const DebugPage({super.key});

  @override
  ConsumerState<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends ConsumerState<DebugPage> {
  String _accessPreview = '...';
  String _output = 'Press a button to run a test.';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refreshPreview();
  }

  Future<void> _refreshPreview() async {
    final token = await ref.read(tokenStoreProvider).readAccess();
    if (!mounted) return;
    setState(() {
      _accessPreview = token == null ? '(none)' : truncateToken(token);
    });
  }

  Future<void> _expireAccess() async {
    final store = ref.read(tokenStoreProvider);
    final refresh = await store.readRefresh() ?? '';
    await store.save(access: 'expired-access', refresh: refresh);
    if (!mounted) return;
    setState(() => _output =
        'Access token replaced with an expired one.\nNext API call must '
        'trigger: 401 -> refresh -> retry.');
    await _refreshPreview();
  }

  Future<void> _killRefresh() async {
    final store = ref.read(tokenStoreProvider);
    await store.save(access: 'expired-access', refresh: '');
    if (!mounted) return;
    setState(() => _output =
        'Access AND refresh token are now dead.\nNext API call must clear '
        'the session and send you to /login.');
    await _refreshPreview();
  }

  Future<void> _callApi() async {
    setState(() => _busy = true);
    String result;
    try {
      final res = await ref
          .read(dioProvider)
          .get<Map<String, dynamic>>('/announcements');
      final count = (res.data?['data'] as List<dynamic>?)?.length ?? 0;
      result = 'HTTP ${res.statusCode}: $count announcements loaded';
    } catch (e) {
      result = 'Failed: ${friendlyApiError(e)}';
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _output = result;
    });
    await _refreshPreview();
  }

  @override
  Widget build(BuildContext context) {
    final push = ref.watch(pushProvider);
    final permission = push.permissionGranted == null
        ? 'not requested yet'
        : (push.permissionGranted! ? 'granted' : 'denied');

    return Scaffold(
      appBar: AppBar(title: const Text('Debug')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('Auth / secure storage', [
            _row('Access token', _accessPreview),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: _busy ? null : _expireAccess,
                  child: const Text('1. Expire access token'),
                ),
                FilledButton(
                  onPressed: _busy ? null : _callApi,
                  child: const Text('2. Call protected API'),
                ),
                OutlinedButton(
                  onPressed: _busy ? null : _killRefresh,
                  child: const Text('Kill refresh token'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(_output),
          ]),
          _section('Push (FCM)', [
            _row('Status', push.status),
            _row('Permission', permission),
            _row('Token', push.tokenPreview ?? '(none)'),
            _row('onTokenRefresh count', '${push.tokenRefreshCount}'),
            _row('Backend sync', push.lastSync ?? '-'),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Topic: campus-announcement'),
              value: push.topicSubscribed,
              onChanged: (v) =>
                  ref.read(pushProvider.notifier).setTopicSubscribed(v),
            ),
          ]),
          _section('Message events (last 10)', [
            if (push.events.isEmpty)
              const Text('No messages received yet.')
            else
              for (final e in push.events) Text(e),
          ]),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text(label)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
