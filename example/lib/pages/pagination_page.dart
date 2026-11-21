import 'package:chatx/chatx.dart';
import 'package:flutter/material.dart';

import '../fake_backend.dart';

/// Loads history in pages of 25 as the user scrolls up.
class PaginationPage extends StatefulWidget {
  const PaginationPage({super.key});

  @override
  State<PaginationPage> createState() => _PaginationPageState();
}

class _PaginationPageState extends State<PaginationPage> {
  static const _pageSize = 25;
  static const _totalMessages = 200;

  final ChatController _controller = ChatController();
  final DateTime _now = DateTime.now();
  int _loaded = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Returns whether older messages remain, as `ChatView.onLoadMore` expects.
  Future<bool> _loadMore() async {
    await latency(700);
    final page = [
      for (var i = _loaded; i < _loaded + _pageSize && i < _totalMessages; i++)
        TextMessage(
          id: 'history-$i',
          author: i.isEven ? ana : me,
          // Older messages have bigger indexes: one every 47 minutes.
          createdAt: _now.subtract(Duration(minutes: 47 * i)),
          text: 'Message #${_totalMessages - i}',
          status: i.isEven ? null : MessageStatus.read,
        ),
    ];
    _loaded += page.length;
    _controller.insertAll(page);
    return _loaded < _totalMessages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Infinite history')),
      body: ChatView(
        controller: _controller,
        currentUser: me,
        onLoadMore: _loadMore,
        onSendMessage: (text, replyTo) => _controller.insert(
          TextMessage(
            id: newId(),
            author: me,
            createdAt: DateTime.now(),
            text: text,
            replyToId: replyTo?.id,
            status: MessageStatus.sent,
          ),
        ),
      ),
    );
  }
}
