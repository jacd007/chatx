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

  test('every method does nothing after dispose', () {
    final c = ChatController(messages: [text('a', 1)]);
    final a = c.messageById('a')!;
    c.dispose();
    expect(() => c.scrollToMessage('a'), returnsNormally);
    expect(() => c.scrollToDate(DateTime(2026)), returnsNormally);
    expect(c.updateStatus('a', MessageStatus.read), isFalse);
    expect(c.appendText('a', 'x'), isFalse);
    expect(c.toggleReaction('a', '👍', 'me'), isFalse);
    expect(c.upsert(text('b', 2)), isFalse);
    expect(c.pin('a'), isFalse);
    expect(c.remove('a'), isFalse);
    expect(
      () => c
        ..insert(text('c', 3))
        ..insertAll([text('d', 4)])
        ..setMessages(const [])
        ..setTyping(ana, isTyping: true)
        ..setDraft('x')
        ..startReply(a)
        ..cancelReply()
        ..startEditing(a as TextMessage)
        ..cancelEditing()
        ..toggleSaved('a')
        ..unpin('a')
        ..toggleSelection('a')
        ..clearSelection()
        ..addAttachments(const [ChatAttachment(id: 'f', name: 'f')])
        ..removeAttachment('f')
        ..clearAttachments(),
      returnsNormally,
    );
  });

  group('index', () {
    test('finds messages that share a timestamp, anywhere in the list', () {
      controller.insertAll([
        for (var i = 0; i < 50; i++) text('t$i', i ~/ 10),
      ]);
      for (final id in ['t0', 't9', 't25', 't49']) {
        expect(controller.updateStatus(id, MessageStatus.read), isTrue);
        expect(controller.messageById(id)!.status, MessageStatus.read);
      }
      expect(controller.remove('t25'), isTrue);
      expect(controller.contains('t25'), isFalse);
      expect(controller.updateStatus('t26', MessageStatus.sent), isTrue);
    });

    test('moving a message in time keeps lookups working', () {
      controller.insertAll([text('a', 1), text('b', 2), text('c', 3)]);
      controller.update(
        (controller.messageById('a')! as TextMessage)
            .copyWith(createdAt: DateTime(2026, 1, 1, 10, 5)),
      );
      expect(controller.messages.map((m) => m.id), ['b', 'c', 'a']);
      expect(controller.updateStatus('a', MessageStatus.read), isTrue);
      expect(controller.remove('b'), isTrue);
      expect(controller.messages.map((m) => m.id), ['c', 'a']);
    });

    test('a merged page keeps equal timestamps in insertion order', () {
      controller.insertAll([text('x', 5), text('y', 5)]);
      controller.insertAll([text('z', 5), text('p', 1), text('q', 5)]);
      expect(
        controller.messages.map((m) => m.id),
        ['p', 'x', 'y', 'z', 'q'],
      );
    });

    test('a rejected page leaves the conversation untouched', () {
      controller.insertAll([text('a', 1), text('b', 2)]);
      expect(
        () => controller.insertAll([text('c', 0), text('a', 3)]),
        throwsArgumentError,
      );
      expect(controller.messages.map((m) => m.id), ['a', 'b']);
      expect(controller.contains('c'), isFalse);
    });
  });

  test('search sees edits of a message it already indexed', () {
    controller.insert(text('a', 1));
    expect(controller.search('message a'), ['a']);
    controller.editText('a', 'hello **world**');
    expect(controller.search('message a'), isEmpty);
    expect(controller.search('world'), ['a']);
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
