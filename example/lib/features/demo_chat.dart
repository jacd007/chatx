import 'package:chatx/chatx.dart';
import 'package:flutter/material.dart';

import '../fake_backend.dart';

/// One focused, working example of a chatx feature.
class FeatureDemo {
  const FeatureDemo({
    required this.title,
    required this.description,
    required this.icon,
    required this.builder,
  });

  final String title;

  /// What to try in the demo. Shown under the title in the catalog and as
  /// a banner inside the demo.
  final String description;
  final IconData icon;
  final WidgetBuilder builder;
}

/// A group of demos in the catalog.
class FeatureGroup {
  const FeatureGroup(this.title, this.demos);

  final String title;
  final List<FeatureDemo> demos;
}

/// Builds the [ChatView] of a demo with its controller.
typedef DemoViewBuilder = Widget Function(
  BuildContext context,
  ChatController controller,
);

/// Screen of one feature demo: owns a [ChatController] filled with [seed],
/// shows [hint] above the chat and disposes everything on exit.
class DemoChat extends StatefulWidget {
  const DemoChat({
    super.key,
    required this.title,
    required this.hint,
    required this.view,
    this.seed = _noMessages,
    this.actions = const [],
    this.onReady,
  });

  final String title;
  final String hint;
  final DemoViewBuilder view;

  /// Messages the conversation starts with.
  final List<ChatMessage> Function() seed;
  final List<Widget> actions;

  /// Runs once after the first frame, for demos that animate something.
  final void Function(ChatController controller)? onReady;

  static List<ChatMessage> _noMessages() => const [];

  @override
  State<DemoChat> createState() => _DemoChatState();
}

class _DemoChatState extends State<DemoChat> {
  late final ChatController controller =
      ChatController(messages: widget.seed());

  @override
  void initState() {
    super.initState();
    final onReady = widget.onReady;
    if (onReady != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) onReady(controller);
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: widget.actions),
      body: Column(
        children: [
          Material(
            color: scheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: scheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.hint,
                      style: TextStyle(color: scheme.onSecondaryContainer),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: widget.view(context, controller)),
        ],
      ),
    );
  }
}

/// Inserts what the user types as an outgoing message, like a backend that
/// accepts it at once.
void sendText(ChatController controller, ChatOutgoing outgoing) {
  switch (outgoing) {
    case OutgoingText(:final text, :final replyTo, :final scheduledFor):
      controller.insert(
        TextMessage(
          id: newId(),
          author: me,
          createdAt: DateTime.now(),
          text: text,
          replyToId: replyTo?.id,
          scheduledFor: scheduledFor,
          status: scheduledFor == null ? MessageStatus.sent : null,
        ),
      );
    case OutgoingEdit(:final message, :final text):
      controller.editText(message.id, text);
    case OutgoingSticker(:final sticker, :final replyTo):
      controller.insert(
        StickerMessage(
          id: newId(),
          author: me,
          createdAt: DateTime.now(),
          uri: sticker.uri,
          label: sticker.label,
          replyToId: replyTo?.id,
          status: MessageStatus.sent,
        ),
      );
    case OutgoingAttachments(
        :final attachments,
        :final caption,
        :final replyTo
      ):
      for (final file in attachments) {
        final uri = file.uri;
        if (file.kind == ChatAttachmentKind.image && uri != null) {
          controller.insert(
            ImageMessage(
              id: newId(),
              author: me,
              createdAt: DateTime.now(),
              images: [ChatImage(uri: uri)],
              replyToId: replyTo?.id,
              status: MessageStatus.sent,
            ),
          );
          continue;
        }
        controller.insert(
          FileMessage(
            id: newId(),
            author: me,
            createdAt: DateTime.now(),
            name: file.name,
            sizeBytes: file.sizeBytes,
            replyToId: replyTo?.id,
            status: MessageStatus.sent,
          ),
        );
      }
      if (caption.isNotEmpty) {
        sendText(controller, OutgoingText(caption, replyTo: replyTo));
      }
    case OutgoingScheduledNow(:final message):
      controller.update(
        message.copyWithMeta(
          clearScheduledFor: true,
          status: MessageStatus.sent,
        ),
      );
  }
}

/// A time [minutes] ago, for seed messages.
DateTime ago(int minutes) =>
    DateTime.now().subtract(Duration(minutes: minutes));

/// A text message for seed data.
TextMessage text(
  String id,
  String body, {
  ChatUser author = ana,
  int minutesAgo = 5,
  MessageStatus? status,
  String? replyToId,
  List<ChatReaction> reactions = const [],
}) =>
    TextMessage(
      id: id,
      author: author,
      createdAt: ago(minutesAgo),
      text: body,
      status: status ?? (author.id == me.id ? MessageStatus.read : null),
      replyToId: replyToId,
      reactions: reactions,
    );

/// Shows [message] in a snack bar, for callbacks a real app would handle.
void toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
