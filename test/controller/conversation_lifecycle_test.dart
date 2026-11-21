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
      controller.composer.startReply(controller.messageById('a')!);
      controller.setMessages([text('c', 3)]);
      expect(controller.composer.replyingTo.value, isNull);

      controller.setMessages([text('b', 2, author: me)]);
      controller.composer
          .startEditing(controller.messageById('b')! as TextMessage);
      controller.setMessages([text('c', 3)]);
      expect(controller.composer.editing.value, isNull);
    });

    test('keeps a reply whose message survives, with its latest version', () {
      controller.insert(text('a', 1));
      controller.composer.startReply(controller.messageById('a')!);
      final refreshed = text('a', 1).copyWith(text: 'fixed typo');
      controller.setMessages([refreshed, text('b', 2)]);
      expect(controller.composer.replyingTo.value, refreshed);
    });

    test('newConversation clears the state of the previous conversation', () {
      controller
        ..insert(text('a', 1))
        ..setTyping(ana, isTyping: true);
      controller.composer
        ..startReply(controller.messageById('a')!)
        ..addAttachments(const [ChatAttachment(id: 'f', name: 'f.pdf')])
        ..setDraft('half written');

      controller.setMessages([text('x', 1)], newConversation: true);

      expect(controller.composer.replyingTo.value, isNull);
      expect(controller.typingUsers.value, isEmpty);
      expect(controller.composer.attachments.value, isEmpty);
      expect(controller.composer.draft.value, isEmpty);
    });

    test('a plain refresh keeps typing users and the draft', () {
      controller
        ..insert(text('a', 1))
        ..setTyping(ana, isTyping: true)
        ..composer.setDraft('half written');

      controller.setMessages([text('a', 1), text('b', 2)]);

      expect(controller.typingUsers.value, [ana]);
      expect(controller.composer.draft.value, 'half written');
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
        ..toggleSaved('a')
        ..unpin('a')
        ..toggleSelection('a')
        ..clearSelection(),
      returnsNormally,
    );
    expect(
      () => c.composer
        ..setDraft('x')
        ..startReply(a)
        ..cancelReply()
        ..startEditing(a as TextMessage)
        ..cancelEditing()
        ..addAttachments(const [ChatAttachment(id: 'f', name: 'f')])
        ..removeAttachment('f')
        ..clearAttachments()
        ..reset(),
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

  group('ChatMessageMeta', () {
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
      expect((cleared as TextMessage).text, 'hi');
    });

    test('meta round-trips on every message type', () {
      final at = DateTime(2026);
      final messages = <ChatMessage>[
        original,
        SystemMessage(id: 's', createdAt: at, text: 'x'),
        CustomMessage(id: 'c', author: ana, createdAt: at, type: 't'),
        ImageMessage(
          id: 'i',
          author: ana,
          createdAt: at,
          images: const [ChatImage(uri: 'a')],
        ),
        FileMessage(id: 'f', author: ana, createdAt: at, name: 'f.pdf'),
        VoiceMessage(
          id: 'v',
          author: ana,
          createdAt: at,
          uri: 'v',
          duration: const Duration(seconds: 3),
        ),
        VideoMessage(id: 'vi', author: ana, createdAt: at, uri: 'v'),
        PollMessage(
          id: 'p',
          author: ana,
          createdAt: at,
          question: 'Q',
          options: const [PollOption(id: 'o', text: 'O')],
        ),
        CountdownMessage(
          id: 'cd',
          author: ana,
          createdAt: at,
          title: 'T',
          endsAt: at,
        ),
        SurveyMessage(
          id: 'sv',
          author: ana,
          createdAt: at,
          title: 'T',
          questions: const [TextQuestion(id: 'q', title: 'Why?')],
        ),
        LocationMessage(
          id: 'l',
          author: ana,
          createdAt: at,
          latitude: 1,
          longitude: 2,
        ),
        EventMessage(
          id: 'e',
          author: ana,
          createdAt: at,
          title: 'T',
          startsAt: at,
        ),
        ContactMessage(id: 'co', author: ana, createdAt: at, name: 'Leo'),
        ChecklistMessage(
          id: 'ch',
          author: ana,
          createdAt: at,
          title: 'T',
          items: const [],
        ),
        ProductMessage(
          id: 'pr',
          author: ana,
          createdAt: at,
          products: const [ChatProduct(id: 'x', title: 'X', price: '1')],
        ),
        PaymentMessage(id: 'pa', author: ana, createdAt: at, amount: '1'),
        CallMessage(id: 'ca', author: ana, createdAt: at),
        StickerMessage(id: 'st', author: ana, createdAt: at, uri: 's'),
      ];
      const meta = ChatMessageMeta(
        status: MessageStatus.read,
        replyToId: 'r',
        forwardedFrom: 'Bob',
        metadata: {'k': 1},
      );
      for (final m in messages) {
        final copy = m.withMeta(meta);
        expect(copy.runtimeType, m.runtimeType, reason: '$m');
        expect(copy.meta, meta, reason: '$m');
        expect(copy.withMeta(m.meta), m, reason: '$m');
        final cleared = copy.copyWithMeta(
          clearReplyToId: true,
          clearForwardedFrom: true,
          clearMetadata: true,
        );
        expect(cleared.runtimeType, m.runtimeType, reason: '$m');
        expect(cleared.status, MessageStatus.read, reason: '$m');
        expect(cleared.replyToId, isNull, reason: '$m');
        expect(cleared.forwardedFrom, isNull, reason: '$m');
        expect(cleared.metadata, isNull, reason: '$m');
      }
      // Every type is covered: the switch below must stay exhaustive.
      for (final m in messages) {
        switch (m) {
          case TextMessage() ||
                SystemMessage() ||
                CustomMessage() ||
                ImageMessage() ||
                FileMessage() ||
                VoiceMessage() ||
                VideoMessage() ||
                PollMessage() ||
                CountdownMessage() ||
                SurveyMessage() ||
                LocationMessage() ||
                EventMessage() ||
                ContactMessage() ||
                ChecklistMessage() ||
                ProductMessage() ||
                PaymentMessage() ||
                CallMessage() ||
                StickerMessage():
            break;
        }
      }
      expect(messages.map((m) => m.runtimeType).toSet(), hasLength(18));
    });

    test('copyWith keeps the fields without the flags', () {
      final copy = original.copyWith(text: 'edited');
      expect(copy.replyToId, 'r');
      expect(copy.forwardedFrom, 'Bob');
      expect(copy.metadata, const {'k': 1});
    });
  });
}
