import 'package:chatx/chatx.dart';
import 'package:flutter_test/flutter_test.dart';

const me = ChatUser(id: 'me', name: 'Me');
const ana = ChatUser(id: 'ana', name: 'Ana');

TextMessage text(String id, int minute, {ChatUser author = ana}) => TextMessage(
      id: id,
      author: author,
      createdAt: DateTime(2026, 1, 1, 10, minute),
      text: 'message $id',
    );

void main() {
  late ChatController controller;

  setUp(() => controller = ChatController());
  tearDown(() => controller.dispose());

  group('setMessages', () {
    test('cancels a reply or edit whose message is gone', () {
      controller.insertAll([text('a', 1), text('b', 2, author: me)]);
      controller.startReply(controller.messageById('a')!);
      controller.setMessages([text('c', 3)]);
      expect(controller.replyingTo.value, isNull);

      controller.setMessages([text('b', 2, author: me)]);
      controller.startEditing(controller.messageById('b')! as TextMessage);
      controller.setMessages([text('c', 3)]);
      expect(controller.editing.value, isNull);
    });

    test('keeps a reply whose message survives, with its latest version', () {
      controller.insert(text('a', 1));
      controller.startReply(controller.messageById('a')!);
      final refreshed = text('a', 1).copyWith(text: 'fixed typo');
      controller.setMessages([refreshed, text('b', 2)]);
      expect(controller.replyingTo.value, refreshed);
    });

    test('newConversation clears the state of the previous conversation', () {
      controller
        ..insert(text('a', 1))
        ..startReply(controller.messageById('a')!)
        ..setTyping(ana, isTyping: true)
        ..addAttachments(const [
          ChatAttachment(
            id: 'f',
            name: 'f.pdf',
            uri: 'file://f.pdf',
            kind: ChatAttachmentKind.file,
          ),
        ])
        ..setDraft('half written');

      controller.setMessages([text('x', 1)], newConversation: true);

      expect(controller.replyingTo.value, isNull);
      expect(controller.typingUsers.value, isEmpty);
      expect(controller.attachments.value, isEmpty);
      expect(controller.draft.value, isEmpty);
    });

    test('a plain refresh keeps typing users, attachments and draft', () {
      controller
        ..insert(text('a', 1))
        ..setTyping(ana, isTyping: true)
        ..setDraft('half written');

      controller.setMessages([text('a', 1), text('b', 2)]);

      expect(controller.typingUsers.value, [ana]);
      expect(controller.draft.value, 'half written');
    });
  });

  test('scrollToMessage after dispose does nothing', () {
    final c = ChatController(messages: [text('a', 1)]);
    c.dispose();
    expect(() => c.scrollToMessage('a'), returnsNormally);
    expect(() => c.scrollToDate(DateTime(2026)), returnsNormally);
  });

  group('copyWithMeta clears', () {
    final original = TextMessage(
      id: 'a',
      author: ana,
      createdAt: DateTime(2026),
      text: 'hi',
      replyToId: 'r',
      forwardedFrom: 'Bob',
      metadata: const {'k': 1},
    );

    test('replyToId, forwardedFrom and metadata', () {
      final cleared = original.copyWithMeta(
        clearReplyToId: true,
        clearForwardedFrom: true,
        clearMetadata: true,
      );
      expect(cleared.replyToId, isNull);
      expect(cleared.forwardedFrom, isNull);
      expect(cleared.metadata, isNull);
      expect(cleared.text, 'hi');
    });

    test('on every message type', () {
      final messages = <ChatMessage>[
        original,
        SystemMessage(
          id: 's',
          createdAt: DateTime(2026),
          text: 'x',
          replyToId: 'r',
          forwardedFrom: 'Bob',
          metadata: const {'k': 1},
        ),
        CustomMessage(
          id: 'c',
          author: ana,
          createdAt: DateTime(2026),
          type: 't',
          replyToId: 'r',
          forwardedFrom: 'Bob',
          metadata: const {'k': 1},
        ),
      ];
      for (final m in messages) {
        final cleared = m.copyWithMeta(
          clearReplyToId: true,
          clearForwardedFrom: true,
          clearMetadata: true,
        );
        expect(cleared.runtimeType, m.runtimeType);
        expect(cleared.replyToId, isNull, reason: '$m');
        expect(cleared.forwardedFrom, isNull, reason: '$m');
        expect(cleared.metadata, isNull, reason: '$m');
      }
    });

    test('copyWith keeps the fields without the flags', () {
      final copy = original.copyWith(text: 'edited');
      expect(copy.replyToId, 'r');
      expect(copy.forwardedFrom, 'Bob');
      expect(copy.metadata, const {'k': 1});
    });
  });
}
