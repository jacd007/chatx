import 'package:chatx/chatx.dart';
import 'package:flutter_test/flutter_test.dart';

const me = ChatUser(id: 'me', name: 'Me');
const ana = ChatUser(id: 'ana', name: 'Ana');

TextMessage text(String id, int minute, {ChatUser author = me}) => TextMessage(
      id: id,
      author: author,
      createdAt: DateTime(2026, 1, 1, 10, minute),
      text: 'message $id',
    );

void main() {
  group('ChatController', () {
    late ChatController controller;
    late int notifications;

    setUp(() {
      controller = ChatController();
      notifications = 0;
      controller.addListener(() => notifications++);
    });

    tearDown(() => controller.dispose());

    test('keeps messages sorted by createdAt, oldest first', () {
      controller
        ..insert(text('b', 2))
        ..insert(text('a', 1))
        ..insert(text('c', 3));
      expect(controller.messages.map((m) => m.id), ['a', 'b', 'c']);
      expect(notifications, 3);
    });

    test('keeps insertion order for equal timestamps', () {
      controller
        ..insert(text('first', 1))
        ..insert(text('second', 1))
        ..insert(text('third', 1));
      expect(controller.messages.map((m) => m.id), [
        'first',
        'second',
        'third',
      ]);
    });

    test('initial messages are sorted and validated', () {
      final c = ChatController(messages: [text('b', 2), text('a', 1)]);
      addTearDown(c.dispose);
      expect(c.messages.map((m) => m.id), ['a', 'b']);
      expect(
        () => ChatController(messages: [text('a', 1), text('a', 2)]),
        throwsArgumentError,
      );
    });

    test('insert throws on duplicate IDs', () {
      controller.insert(text('a', 1));
      expect(() => controller.insert(text('a', 2)), throwsArgumentError);
    });

    test('insertAll notifies once and rejects duplicates atomically', () {
      controller.insert(text('c', 3));
      notifications = 0;
      controller.insertAll([text('a', 1), text('b', 2)]);
      expect(controller.messages.map((m) => m.id), ['a', 'b', 'c']);
      expect(notifications, 1);

      expect(
        () => controller.insertAll([text('d', 4), text('a', 5)]),
        throwsArgumentError,
      );
      expect(controller.length, 3);
    });

    test('messages view is read-only', () {
      controller.insert(text('a', 1));
      expect(
          () => controller.messages.add(text('b', 2)), throwsUnsupportedError);
    });

    test('content updates notify only the message watcher', () {
      controller.insert(text('a', 1));
      final watcher = controller.watch('a');
      var watcherCalls = 0;
      watcher.addListener(() => watcherCalls++);
      notifications = 0;

      expect(controller.updateStatus('a', MessageStatus.read), isTrue);

      expect(notifications, 0);
      expect(watcherCalls, 1);
      expect(watcher.value.status, MessageStatus.read);
      expect(controller.messageById('a')!.status, MessageStatus.read);
    });

    test('updating createdAt reorders and notifies listeners', () {
      controller
        ..insert(text('a', 1))
        ..insert(text('b', 2));
      notifications = 0;
      controller.update(text('a', 3));
      expect(controller.messages.map((m) => m.id), ['b', 'a']);
      expect(notifications, 1);
    });

    test('update returns false for unknown IDs', () {
      expect(controller.update(text('x', 1)), isFalse);
      expect(controller.updateStatus('x', MessageStatus.sent), isFalse);
    });

    test('upsert inserts or replaces', () {
      expect(controller.upsert(text('a', 1)), isTrue);
      expect(
        controller.upsert(text('a', 1).copyWith(text: 'edited')),
        isFalse,
      );
      expect((controller.messageById('a')! as TextMessage).text, 'edited');
      expect(controller.length, 1);
    });

    test('appendText and completeStream build a streamed message', () {
      controller.insert(
        TextMessage(
          id: 'bot',
          author: ana,
          createdAt: DateTime(2026),
          text: '',
          isStreaming: true,
        ),
      );
      notifications = 0;
      controller
        ..appendText('bot', 'Hel')
        ..appendText('bot', 'lo');
      expect((controller.messageById('bot')! as TextMessage).text, 'Hello');

      controller.completeStream('bot', status: MessageStatus.sent);
      final done = controller.messageById('bot')! as TextMessage;
      expect(done.isStreaming, isFalse);
      expect(done.status, MessageStatus.sent);
      expect(notifications, 0, reason: 'streaming must not rebuild the list');
    });

    test('appendText ignores non-text messages', () {
      controller.insert(
        CustomMessage(
          id: 'c',
          author: me,
          createdAt: DateTime(2026),
          type: 'image',
        ),
      );
      expect(controller.appendText('c', 'x'), isFalse);
    });

    test('remove deletes the message', () {
      controller.insert(text('a', 1));
      controller.watch('a');
      expect(controller.remove('a'), isTrue);
      expect(controller.isEmpty, isTrue);
      expect(controller.remove('a'), isFalse);
      expect(() => controller.watch('a'), throwsArgumentError);
    });

    test('setMessages replaces everything and keeps watchers fresh', () {
      controller.insert(text('a', 1));
      final watcher = controller.watch('a');
      controller
          .setMessages([text('a', 1).copyWith(text: 'new'), text('b', 2)]);
      expect(controller.length, 2);
      expect((watcher.value as TextMessage).text, 'new');

      expect(
        () => controller.setMessages([text('x', 1), text('x', 2)]),
        throwsArgumentError,
      );
      expect(controller.length, 2, reason: 'failed replace must roll back');
    });

    test('setTyping tracks users without duplicates', () {
      controller
        ..setTyping(ana, isTyping: true)
        ..setTyping(ana, isTyping: true);
      expect(controller.typingUsers.value, [ana]);
      controller.setTyping(ana, isTyping: false);
      expect(controller.typingUsers.value, isEmpty);
    });
  });

  group('ChatUser.initials', () {
    test('uses first and last name', () {
      expect(const ChatUser(id: '1', name: 'Ana María López').initials, 'AL');
      expect(const ChatUser(id: '1', name: 'ana').initials, 'A');
      expect(const ChatUser(id: 'xyz').initials, 'X');
      expect(const ChatUser(id: '1', name: '  ').initials, '1');
    });
  });

  group('ChatController conversation state', () {
    late ChatController controller;

    setUp(() => controller = ChatController(messages: [text('a', 1)]));
    tearDown(() => controller.dispose());

    test('toggleReaction adds, counts and removes reactions', () {
      controller
        ..toggleReaction('a', '👍', 'me')
        ..toggleReaction('a', '👍', 'ana')
        ..toggleReaction('a', '🎉', 'me');
      var reactions = controller.messageById('a')!.reactions;
      expect(reactions.map((r) => (r.emoji, r.count)), [('👍', 2), ('🎉', 1)]);

      controller
        ..toggleReaction('a', '👍', 'me')
        ..toggleReaction('a', '🎉', 'me');
      reactions = controller.messageById('a')!.reactions;
      expect(reactions.single.userIds, ['ana']);
      expect(controller.toggleReaction('missing', '👍', 'me'), isFalse);
    });

    test('editText replaces text and sets editedAt', () {
      final at = DateTime(2026, 5, 5);
      expect(controller.editText('a', 'new', editedAt: at), isTrue);
      final message = controller.messageById('a')! as TextMessage;
      expect(message.text, 'new');
      expect(message.editedAt, at);
    });

    test('reply and edit are mutually exclusive', () {
      final message = controller.messageById('a')! as TextMessage;
      controller.composer.startReply(message);
      expect(controller.composer.replyingTo.value, message);
      controller.composer.startEditing(message);
      expect(controller.composer.replyingTo.value, isNull);
      expect(controller.composer.editing.value, message);
      controller.composer.startReply(message);
      expect(controller.composer.editing.value, isNull);
    });

    test('removing a message clears its reply or edit', () {
      controller.composer.startReply(controller.messageById('a')!);
      controller.remove('a');
      expect(controller.composer.replyingTo.value, isNull);
    });

    test('the reply follows new versions of its message', () {
      controller.composer.startReply(controller.messageById('a')!);
      controller.editText('a', 'fixed');
      expect(
        (controller.composer.replyingTo.value! as TextMessage).text,
        'fixed',
      );
    });

    test('the edit keeps the version the user started from', () {
      final message = controller.messageById('a')! as TextMessage;
      controller.composer.startEditing(message);
      controller.updateStatus('a', MessageStatus.read);
      expect(controller.composer.editing.value, same(message));
      controller.remove('a');
      expect(controller.composer.editing.value, isNull);
    });
  });
}
