import 'package:chatx/chatx.dart';
import 'package:flutter_test/flutter_test.dart';

const me = ChatUser(id: 'me');
final t0 = DateTime(2026, 1, 1, 10);

PollMessage poll({bool multiple = false, bool closed = false}) => PollMessage(
      id: 'p',
      author: me,
      createdAt: t0,
      question: 'Lunch?',
      allowsMultipleAnswers: multiple,
      isClosed: closed,
      options: const [
        PollOption(id: 'a', text: 'Pizza'),
        PollOption(id: 'b', text: 'Tacos'),
      ],
    );

void main() {
  test('votePoll replaces the vote in single-answer polls', () {
    final c = ChatController(messages: [poll()]);
    addTearDown(c.dispose);
    c
      ..votePoll('p', 'a', 'me')
      ..votePoll('p', 'b', 'me');
    final p = c.messageById('p')! as PollMessage;
    expect(p.options[0].votes, 0);
    expect(p.options[1].voterIds, ['me']);
    c.votePoll('p', 'b', 'me');
    expect((c.messageById('p')! as PollMessage).totalVotes, 0);
  });

  test('votePoll accumulates in multiple-answer polls', () {
    final c = ChatController(messages: [poll(multiple: true)]);
    addTearDown(c.dispose);
    c
      ..votePoll('p', 'a', 'me')
      ..votePoll('p', 'b', 'me');
    expect((c.messageById('p')! as PollMessage).totalVotes, 2);
  });

  test('votePoll rejects closed polls and unknown options', () {
    final c = ChatController(messages: [poll(closed: true)]);
    addTearDown(c.dispose);
    expect(c.votePoll('p', 'a', 'me'), isFalse);
    expect(c.votePoll('p', 'zzz', 'me'), isFalse);
  });

  test('pins and selection follow message removal', () {
    final c = ChatController(
      messages: [
        TextMessage(id: '1', author: me, createdAt: t0, text: 'a'),
        TextMessage(id: '2', author: me, createdAt: t0, text: 'b'),
      ],
    );
    addTearDown(c.dispose);
    c
      ..pin('1')
      ..pin('2')
      ..toggleSelection('1')
      ..toggleSelection('2');
    expect(c.pinnedIds.value, ['1', '2']);
    expect(c.isSelecting, isTrue);

    c.remove('1');
    expect(c.pinnedIds.value, ['2']);
    expect(c.selectedIds.value, {'2'});

    c.setMessages(const []);
    expect(c.pinnedIds.value, isEmpty);
    expect(c.isSelecting, isFalse);
  });

  test('search ignores case and markdown and looks at every type', () {
    final c = ChatController(
      messages: [
        TextMessage(id: 't', author: me, createdAt: t0, text: 'The **Plan**'),
        FileMessage(id: 'f', author: me, createdAt: t0, name: 'plan.pdf'),
        poll(),
        ImageMessage(
          id: 'i',
          author: me,
          createdAt: t0,
          images: const [ChatImage(uri: 'x')],
          caption: 'Floor plan',
        ),
      ],
    );
    addTearDown(c.dispose);
    expect(c.search('PLAN'), ['i', 'f', 't']);
    expect(c.search('tacos'), ['p']);
    expect(c.search('  '), isEmpty);
  });

  test('scrollToMessage emits requests for existing messages', () async {
    final c = ChatController(
      messages: [TextMessage(id: '1', author: me, createdAt: t0, text: 'a')],
    );
    addTearDown(c.dispose);
    final requests = <String>[];
    c.scrollRequests.listen((r) => requests.add(r.messageId));
    c
      ..scrollToMessage('1')
      ..scrollToMessage('missing');
    await Future<void>.delayed(Duration.zero);
    expect(requests, ['1']);
  });

  test('ChatSearchController moves between results', () {
    final c = ChatController(
      messages: [
        for (var i = 0; i < 3; i++)
          TextMessage(
            id: '$i',
            author: me,
            createdAt: t0.add(Duration(minutes: i)),
            text: 'hello $i',
          ),
      ],
    );
    final search = ChatSearchController(chatController: c);
    addTearDown(() {
      search.dispose();
      c.dispose();
    });
    search.search('hello');
    expect(search.results, ['2', '1', '0']);
    expect(search.currentId, '2');
    search
      ..next()
      ..next()
      ..next();
    expect(search.currentId, '0');
    search.previous();
    expect(search.currentId, '1');

    c.remove('1');
    expect(search.results, ['2', '0']);
    search.clear();
    expect(search.isActive, isFalse);
  });

  test('ChatSearchController follows edits and streamed text', () {
    final c = ChatController(
      messages: [
        TextMessage(id: 'a', author: me, createdAt: t0, text: 'hello'),
        TextMessage(
          id: 'b',
          author: me,
          createdAt: t0.add(const Duration(minutes: 1)),
          text: '',
          isStreaming: true,
        ),
      ],
    );
    final search = ChatSearchController(chatController: c);
    var notifications = 0;
    search.addListener(() => notifications++);
    addTearDown(() {
      search.dispose();
      c.dispose();
    });
    var contentChanges = 0;
    c.contentChanges.addListener(() => contentChanges++);

    search.search('hello');
    expect(search.results, ['a']);
    notifications = 0;

    c.editText('a', 'goodbye');
    expect(search.results, isEmpty);
    c.appendText('b', 'hel');
    c.appendText('b', 'lo');
    expect(search.results, ['b']);
    c.appendText('b', ' world');
    expect(search.results, ['b']);
    // Two changes of the results; the last delta changed nothing.
    expect(notifications, 2);
    expect(contentChanges, 4);
  });

  test('file extensions and image ratios', () {
    expect(
      FileMessage(id: 'f', author: me, createdAt: t0, name: 'Report.PDF')
          .extension,
      'pdf',
    );
    expect(
      FileMessage(id: 'f', author: me, createdAt: t0, name: 'README').extension,
      '',
    );
    expect(const ChatImage(uri: 'x', width: 400, height: 200).aspectRatio, 2);
    expect(const ChatImage(uri: 'x').aspectRatio, isNull);
  });

  test('recordSurveyResponse and drafts', () {
    final c = ChatController(
      initialDraft: 'hi',
      messages: [
        SurveyMessage(
          id: 's',
          author: me,
          createdAt: t0,
          title: 'Feedback',
          questions: const [TextQuestion(id: 'q', title: 'Why?')],
        ),
      ],
    );
    addTearDown(c.dispose);
    expect(c.composer.draft.value, 'hi');
    c.composer.setDraft('hello');
    expect(c.composer.draft.value, 'hello');
    expect(c.recordSurveyResponse('s', 'me'), isTrue);
    c.recordSurveyResponse('s', 'me');
    expect((c.messageById('s')! as SurveyMessage).respondentIds, ['me']);
    expect(c.search('feedback'), ['s']);
  });

  test('copyWithMeta keeps type-specific fields', () {
    final poll = PollMessage(
      id: 'p',
      author: me,
      createdAt: t0,
      question: 'Q',
      options: const [PollOption(id: 'a', text: 'A')],
    );
    final copy = poll.withMeta(poll.meta.copyWith(forwardedFrom: 'Ana'));
    expect(copy.question, 'Q');
    expect(copy.forwardedFrom, 'Ana');
    expect(copy.withStatus(null).status, isNull);
  });
}
