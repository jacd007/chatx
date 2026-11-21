import 'package:chatx/chatx.dart';
import 'package:chatx/src/material.dart';
import 'package:flutter_test/flutter_test.dart';

const me = ChatUser(id: 'me', name: 'Me');
const ana = ChatUser(id: 'ana', name: 'Ana');
const leo = ChatUser(id: 'leo', name: 'Leo');

DateTime ago(int minutes) =>
    DateTime.now().subtract(Duration(minutes: minutes));

const surveyQuestions = <SurveyQuestion>[
  ChoiceQuestion(
    id: 'q1',
    title: 'What do you use most?',
    choices: [
      SurveyChoice(id: 'chat', text: 'Chat'),
      SurveyChoice(id: 'calls', text: 'Calls'),
    ],
  ),
  RatingQuestion(id: 'q2', title: 'Rate the app'),
  NpsQuestion(id: 'q3', title: 'Would you recommend us?'),
  TextQuestion(id: 'q4', title: 'Anything else?', isRequired: false),
];

void main() {
  late ChatController controller;
  setUp(() => controller = ChatController());
  tearDown(() => controller.dispose());

  Future<void> pump(
    WidgetTester tester, {
    void Function(SurveyMessage, ChatSurveyResponse)? onSurveySubmit,
    void Function(ChatMessage, ChatMessageButton)? onMessageButton,
    void Function(ChatQuickReply, ChatMessage)? onQuickReply,
    ValueChanged<String>? onSend,
    ValueChanged<ChatMessage>? onThreadTap,
    ChatMessage? threadRoot,
    ValueChanged<List<ChatMessage>>? onForward,
    ChatReactionCallback? onReaction,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatView(
            controller: controller,
            currentUser: me,
            onSendMessage: (text, _) => onSend?.call(text),
            onSurveySubmit: onSurveySubmit,
            onMessageButton: onMessageButton,
            onQuickReply: onQuickReply,
            onThreadTap: onThreadTap,
            threadRoot: threadRoot,
            onForwardMessages: onForward,
            onReactionSelected: onReaction,
          ),
        ),
      ),
    );
  }

  group('survey', () {
    SurveyMessage make() => SurveyMessage(
          id: 's',
          author: ana,
          createdAt: ago(1),
          title: 'Product feedback',
          questions: surveyQuestions,
        );

    testWidgets('walks through every question type and submits',
        (tester) async {
      ChatSurveyResponse? response;
      controller.insert(make());
      await pump(
        tester,
        onSurveySubmit: (s, r) {
          response = r;
          controller.recordSurveyResponse(s.id, me.id);
        },
      );
      expect(find.text('4 questions · 0 responses'), findsOneWidget);
      await tester.tap(find.byKey(const Key('chatx_survey_s')));
      await tester.pumpAndSettle();
      expect(find.text('Question 1 of 4'), findsOneWidget);

      final next = find.byKey(const Key('chatx_survey_next'));
      expect(tester.widget<FilledButton>(next).onPressed, isNull,
          reason: 'required question');
      await tester.tap(find.byKey(const Key('chatx_survey_choice_calls')));
      await tester.pump();
      await tester.tap(next);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('chatx_survey_rating_4')));
      await tester.pump();
      await tester.tap(next);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('chatx_survey_nps_9')));
      await tester.pump();
      await tester.tap(next);
      await tester.pumpAndSettle();

      expect(find.text('Question 4 of 4 · Optional'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('chatx_survey_text')),
        '  More themes  ',
      );
      await tester.pump();
      await tester.tap(next);
      await tester.pumpAndSettle();

      expect(response!.choices('q1'), ['calls']);
      expect(response!.rating('q2'), 4);
      expect(response!.rating('q3'), 9);
      expect(response!.text('q4'), 'More themes');
      expect(find.text('Answered'), findsOneWidget);
    });

    testWidgets('closed surveys cannot be answered', (tester) async {
      controller.insert(make().copyWith(isClosed: true));
      await pump(tester, onSurveySubmit: (_, __) {});
      expect(find.text('Closed'), findsOneWidget);
      await tester.tap(find.byKey(const Key('chatx_survey_s')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('chatx_survey_flow')), findsNothing);
    });
  });

  testWidgets('buttons and quick replies', (tester) async {
    final pressed = <String>[];
    final sent = <String>[];
    controller.insert(
      TextMessage(
        id: 'bot',
        author: ana,
        createdAt: ago(1),
        text: 'How can I help?',
        buttons: const [
          ChatMessageButton(
            id: 'track',
            label: 'Track order',
            style: ChatButtonStyle.primary,
          ),
        ],
        quickReplies: const [
          ChatQuickReply(label: 'Talk to a human'),
          ChatQuickReply(label: '👍', value: 'Thanks!'),
        ],
      ),
    );
    await pump(
      tester,
      onMessageButton: (m, b) => pressed.add(b.id),
      onSend: sent.add,
    );
    await tester.tap(find.byKey(const Key('chatx_button_bot_track')));
    expect(pressed, ['track']);

    expect(find.byKey(const Key('chatx_quick_replies')), findsOneWidget);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chatx_quick_reply_1')));
    await tester.pump();
    expect(sent, ['Thanks!']);

    controller.insert(
      TextMessage(
          id: 'mine', author: me, createdAt: DateTime.now(), text: 'ok'),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chatx_quick_replies')), findsNothing,
        reason: 'only for the newest incoming message');
  });

  testWidgets('thread summary opens the thread and roots render',
      (tester) async {
    final opened = <String>[];
    final root = TextMessage(
      id: 'root',
      author: ana,
      createdAt: ago(10),
      text: 'Ideas for the trip?',
      thread: ChatThreadSummary(
        replyCount: 3,
        participants: const [leo, me],
        lastReplyAt: ago(2),
      ),
    );
    controller.insert(root);
    await pump(tester, onThreadTap: (m) => opened.add(m.id));
    expect(find.text('3 replies'), findsOneWidget);
    await tester.tap(find.byKey(const Key('chatx_thread_root')));
    expect(opened, ['root']);

    final thread = ChatController(
      messages: [
        TextMessage(id: 'r1', author: leo, createdAt: ago(5), text: 'Beach!'),
      ],
    );
    addTearDown(thread.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatView(
            controller: thread,
            currentUser: me,
            onSendMessage: (_, __) {},
            threadRoot: root,
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('chatx_thread_header')), findsOneWidget);
    expect(find.text('Ideas for the trip?'), findsOneWidget);
    expect(find.text('1 reply'), findsOneWidget);
  });

  testWidgets('seen by and message info', (tester) async {
    controller.insertAll([
      TextMessage(
        id: 'old',
        author: me,
        createdAt: ago(5),
        text: 'first',
        receipts: [ChatReadReceipt(user: ana, readAt: ago(4))],
      ),
      TextMessage(
        id: 'new',
        author: me,
        createdAt: ago(3),
        text: 'second',
        receipts: [
          ChatReadReceipt(user: ana, readAt: ago(2)),
          ChatReadReceipt(user: leo, readAt: ago(1)),
        ],
      ),
    ]);
    await pump(tester);
    expect(find.byKey(const Key('chatx_seen_by')), findsOneWidget,
        reason: 'only under the newest outgoing message');
    expect(find.bySemanticsLabel('Seen by Ana, Leo'), findsOneWidget);

    await tester.longPress(find.byKey(const Key('chatx_bubble_new')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Info'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chatx_message_info')), findsOneWidget);
    expect(find.text('Leo'), findsWidgets);
  });

  testWidgets('forwarded label and forward action', (tester) async {
    final forwarded = <List<String>>[];
    controller.insert(
      TextMessage(
        id: 'f',
        author: me,
        createdAt: ago(1),
        text: 'Meeting at 5',
        forwardedFrom: 'Leo',
      ),
    );
    await pump(
      tester,
      onForward: (ms) => forwarded.add([for (final m in ms) m.id]),
    );
    expect(find.text('Forwarded from Leo'), findsOneWidget);
    await tester.longPress(find.byKey(const Key('chatx_bubble_f')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Forward'));
    await tester.pumpAndSettle();
    expect(forwarded, [
      ['f'],
    ]);
  });

  testWidgets('disappearing messages count down and vanish', (tester) async {
    controller.insert(
      TextMessage(
        id: 'e',
        author: ana,
        createdAt: DateTime.now(),
        text: 'secret',
        expiresAt: DateTime.now().add(const Duration(seconds: 30)),
      ),
    );
    await pump(tester);
    expect(find.byKey(const Key('chatx_expiry')), findsOneWidget);
    await tester.pump(const Duration(seconds: 31));
    await tester.pumpAndSettle();
    expect(controller.contains('e'), isFalse);
    expect(find.text('secret'), findsNothing);
  });

  testWidgets('drafts survive rebuilding the view and edits', (tester) async {
    controller.insert(
      TextMessage(id: 'm', author: me, createdAt: ago(1), text: 'old'),
    );
    await pump(tester);
    final field = find.byKey(const Key('chatx_input_field'));
    await tester.enterText(field, 'half-written');
    expect(controller.draft.value, 'half-written');

    controller.startEditing(controller.messageById('m')! as TextMessage);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field).controller!.text, 'old');
    controller.cancelEditing();
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field).controller!.text, 'half-written');

    await tester.pumpWidget(const SizedBox());
    await pump(tester);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('chatx_input_field')))
          .controller!
          .text,
      'half-written',
    );
  });

  group('emoji', () {
    testWidgets('the picker inserts emoji and searches', (tester) async {
      await pump(tester);
      await tester.tap(find.byKey(const Key('chatx_emoji_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('chatx_emoji_picker')), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('chatx_emoji_search')),
        'pizza',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('chatx_emoji_🍕')));
      await tester.pump();
      final field = find.byKey(const Key('chatx_input_field'));
      expect(tester.widget<TextField>(field).controller!.text, '🍕');
      expect(ChatEmojiPicker.recent.first, '🍕');
    });

    testWidgets('"+" in the reaction row opens the picker', (tester) async {
      final reactions = <String>[];
      controller.insert(
        TextMessage(id: 'm', author: ana, createdAt: ago(1), text: 'hi'),
      );
      await pump(tester, onReaction: (m, e) => reactions.add(e));
      await tester.longPress(find.byKey(const Key('chatx_bubble_m')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('chatx_react_more')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('chatx_emoji_search')),
        'rocket',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('chatx_emoji_🚀')));
      await tester.pumpAndSettle();
      expect(reactions, ['🚀']);
    });
  });

  group('ChatHeader', () {
    Future<void> header(WidgetTester tester, Widget child) => tester
        .pumpWidget(MaterialApp(home: Scaffold(appBar: AppBar(title: child))));

    testWidgets('shows online, last seen and members', (tester) async {
      await header(tester, const ChatHeader(user: ana, isOnline: true));
      expect(find.text('online'), findsOneWidget);

      await header(
        tester,
        ChatHeader(user: ana, lastSeenAt: ago(5)),
      );
      expect(find.text('last seen 5 min ago'), findsOneWidget);

      await header(tester, const ChatHeader(user: leo, memberCount: 4));
      expect(find.text('4 members'), findsOneWidget);
    });

    testWidgets('typing replaces the status', (tester) async {
      await header(
        tester,
        ChatHeader(user: ana, isOnline: true, controller: controller),
      );
      controller.setTyping(ana, isTyping: true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('typing…'), findsOneWidget);
    });
  });
}
