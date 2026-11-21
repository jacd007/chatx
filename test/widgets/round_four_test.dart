import 'dart:async';

import 'package:chatx/chatx.dart';
import 'package:chatx/src/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const me = ChatUser(id: 'me', name: 'Me');
const ana = ChatUser(id: 'ana', name: 'Ana', role: ChatRole.admin);
const bot = ChatUser(id: 'bot', name: 'Assistant', isBot: true);

DateTime ago(int minutes) =>
    DateTime.now().subtract(Duration(minutes: minutes));

final Uint8List _pixel = Uint8List.fromList(const [
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

void main() {
  late ChatController controller;
  setUp(() => controller = ChatController());
  tearDown(() => controller.dispose());

  Future<void> pump(WidgetTester tester, Widget view) => tester.pumpWidget(
        MaterialApp(home: Scaffold(body: view)),
      );

  ChatView view({
    ValueChanged<String>? onSend,
    ChatEditCallback? onEdit,
    ValueChanged<ChatSource>? onSource,
    ValueChanged<VideoMessage>? onVideo,
    Future<void> Function(VoiceMessage)? onTranscribe,
    void Function(ChecklistMessage, ChecklistItem)? onCheck,
    void Function(ProductMessage, ChatProduct)? onProduct,
    void Function(PaymentMessage, ChatPaymentAction)? onPayment,
    ValueChanged<CallMessage>? onCallBack,
    VoidCallback? onAttach,
    ChatAttachmentsCallback? onAttachments,
    ChatConnectionState connection = ChatConnectionState.online,
    ValueChanged<List<ChatMessage>>? onQueued,
    List<ChatPrompt> prompts = const [],
    ValueChanged<TextMessage>? onRegenerate,
  }) {
    return ChatView(
      controller: controller,
      currentUser: me,
      onSendMessage: (text, _) => onSend?.call(text),
      onEditMessage: onEdit,
      onSourceTap: onSource,
      onVideoTap: onVideo,
      onTranscribe: onTranscribe,
      onChecklistToggle: onCheck,
      onProductTap: onProduct,
      onPaymentAction: onPayment,
      onCallBack: onCallBack,
      onAttach: onAttach,
      onSendAttachments: onAttachments,
      connectionState: connection,
      onSendQueued: onQueued,
      suggestedPrompts: prompts,
      onRegenerate: onRegenerate,
      onReactionSelected: (_, __) {},
      imageProviderBuilder: (_) => MemoryImage(_pixel),
    );
  }

  group('controller', () {
    test('checklist, regeneration, attachments and queue', () {
      controller.insertAll([
        ChecklistMessage(
          id: 'c',
          author: ana,
          createdAt: ago(3),
          title: 'Trip',
          items: const [
            ChecklistItem(id: 'a', text: 'Tickets'),
            ChecklistItem(id: 'b', text: 'Hotel', doneBy: 'ana'),
          ],
        ),
        TextMessage(id: 't', author: bot, createdAt: ago(2), text: 'v1'),
        TextMessage(
          id: 'q',
          author: me,
          createdAt: ago(1),
          text: 'hi',
          status: MessageStatus.queued,
        ),
      ]);
      expect(controller.toggleChecklistItem('c', 'a', 'me'), isTrue);
      expect((controller.messageById('c')! as ChecklistMessage).doneCount, 2);
      controller.toggleChecklistItem('c', 'b', 'me');
      expect((controller.messageById('c')! as ChecklistMessage).doneCount, 1);
      expect(controller.toggleChecklistItem('c', 'x', 'me'), isFalse);

      controller
        ..startRegeneration('t')
        ..appendText('t', 'v2')
        ..completeStream('t');
      final regenerated = controller.messageById('t')! as TextMessage;
      expect(regenerated.versions, ['v1']);
      expect(regenerated.text, 'v2');

      controller.composer.addAttachments(const [
        ChatAttachment(id: '1', name: 'a.png'),
        ChatAttachment(id: '2', name: 'b.pdf'),
      ]);
      controller.composer.removeAttachment('1');
      expect(controller.composer.attachments.value.map((a) => a.id), ['2']);
      controller.composer.clearAttachments();
      expect(controller.composer.attachments.value, isEmpty);

      expect(controller.queuedMessages.map((m) => m.id), ['q']);
    });

    test('search covers the new types', () {
      controller.insertAll([
        VoiceMessage(
          id: 'v',
          author: ana,
          createdAt: ago(2),
          uri: 'x',
          duration: const Duration(seconds: 3),
          transcript: 'Meet at the harbour',
        ),
        PaymentMessage(
          id: 'p',
          author: ana,
          createdAt: ago(1),
          amount: r'$20',
          note: 'Pizza night',
        ),
      ]);
      expect(controller.search('harbour'), ['v']);
      expect(controller.search('pizza'), ['p']);
    });
  });

  group('AI', () {
    testWidgets('reasoning, tools, sources and versions', (tester) async {
      final opened = <String>[];
      controller.insert(
        TextMessage(
          id: 'a',
          author: bot,
          createdAt: ago(1),
          text: 'Answer two',
          reasoning: const ChatReasoning(
            text: 'Let me think',
            duration: Duration(seconds: 12),
          ),
          toolCalls: const [
            ChatToolCall(id: 'w', name: 'Searched the web', detail: '3 pages'),
          ],
          sources: const [
            ChatSource(title: 'Docs', url: 'https://www.dart.dev/x'),
          ],
          versions: const ['Answer one'],
        ),
      );
      await pump(
        tester,
        view(onSource: (s) => opened.add(s.host), onRegenerate: (_) {}),
      );
      expect(find.text('Thought for 12s'), findsOneWidget);
      expect(find.text('Let me think', findRichText: true), findsNothing);
      await tester.tap(find.byKey(const Key('chatx_reasoning_a')));
      await tester.pumpAndSettle();
      expect(find.text('Let me think', findRichText: true), findsOneWidget);

      expect(find.text('Searched the web'), findsOneWidget);
      await tester.tap(find.byKey(const Key('chatx_tool_w')));
      await tester.pump();
      expect(find.text('3 pages', findRichText: true), findsOneWidget);

      await tester.tap(find.byKey(const Key('chatx_source_a_0')));
      expect(opened, ['dart.dev']);

      expect(find.text('2/2'), findsOneWidget);
      await tester.tap(find.byKey(const Key('chatx_version_previous_a')));
      await tester.pump();
      expect(find.text('1/2'), findsOneWidget);
      expect(find.text('Answer one', findRichText: true), findsOneWidget);
      expect(find.text('Answer two', findRichText: true), findsNothing);
    });

    testWidgets('thinking pulses and prompts send', (tester) async {
      final sent = <String>[];
      await pump(
        tester,
        view(
          onSend: sent.add,
          prompts: const [
            ChatPrompt(title: 'Plan a trip', subtitle: 'to Lisbon'),
          ],
        ),
      );
      await tester.tap(find.byKey(const Key('chatx_prompt_0')));
      expect(sent, ['Plan a trip to Lisbon']);

      controller.insert(
        TextMessage(
          id: 'b',
          author: bot,
          createdAt: DateTime.now(),
          text: '',
          isStreaming: true,
          reasoning: const ChatReasoning(text: 'Hmm', isActive: true),
        ),
      );
      await tester.pump();
      expect(find.text('Thinking…'), findsOneWidget);
      expect(find.text('Hmm', findRichText: true), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
    });
  });

  group('content', () {
    testWidgets('video, transcript, checklist, product, payment, call',
        (tester) async {
      tester.view.physicalSize = const Size(430, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final log = <String>[];
      final transcribing = Completer<void>();
      controller.insertAll([
        VideoMessage(
          id: 'v',
          author: ana,
          createdAt: ago(9),
          uri: 'movie.mp4',
          duration: const Duration(seconds: 75),
        ),
        VoiceMessage(
          id: 'n',
          author: ana,
          createdAt: ago(8),
          uri: 'n.m4a',
          duration: const Duration(seconds: 4),
        ),
        ChecklistMessage(
          id: 'c',
          author: ana,
          createdAt: ago(7),
          title: 'Trip',
          items: const [ChecklistItem(id: 'a', text: 'Tickets')],
        ),
        ProductMessage(
          id: 'p',
          author: ana,
          createdAt: ago(6),
          products: const [
            ChatProduct(id: 'x', title: 'Mug', price: '€9'),
            ChatProduct(id: 'y', title: 'Tee', price: '€19'),
          ],
        ),
        PaymentMessage(
          id: 'pay',
          author: ana,
          createdAt: ago(5),
          amount: r'$12.50',
          note: 'Tickets',
        ),
        PaymentMessage(
          id: 'mine',
          author: me,
          createdAt: ago(4),
          amount: r'$3',
        ),
        CallMessage(
          id: 'call',
          author: ana,
          createdAt: ago(3),
          outcome: ChatCallOutcome.missed,
        ),
      ]);
      await pump(
        tester,
        view(
          onVideo: (m) => log.add('video ${m.uri}'),
          onTranscribe: (m) async {
            log.add('transcribe');
            await transcribing.future;
            controller.update(m.copyWith(transcript: 'See you soon'));
          },
          onCheck: (m, item) =>
              controller.toggleChecklistItem(m.id, item.id, me.id),
          onProduct: (m, product) => log.add('product ${product.id}'),
          onPayment: (m, action) => log.add('payment ${action.name}'),
          onCallBack: (m) => log.add('call back'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1:15'), findsOneWidget);
      await tester.tap(find.byKey(const Key('chatx_video_v')));

      await tester.tap(find.byKey(const Key('chatx_transcribe_n')));
      await tester.pump();
      expect(find.text('Transcribing…'), findsOneWidget);
      transcribing.complete();
      await tester.pumpAndSettle();
      expect(find.text('See you soon'), findsOneWidget);

      expect(find.text('0 of 1 done'), findsOneWidget);
      await tester.tap(find.byKey(const Key('chatx_check_c_a')));
      await tester.pumpAndSettle();
      expect(find.text('1 of 1 done'), findsOneWidget);

      expect(find.byKey(const Key('chatx_products_p')), findsOneWidget);
      await tester.tap(find.byKey(const Key('chatx_product_p_x')));

      expect(find.byKey(const Key('chatx_pay_mine')), findsNothing,
          reason: 'own requests cannot be paid');
      await tester.tap(find.byKey(const Key('chatx_pay_pay')));

      expect(find.text('Missed'), findsOneWidget);
      await tester.tap(find.byKey(const Key('chatx_call_back_call')));

      expect(log, [
        'video movie.mp4',
        'transcribe',
        'product x',
        'payment pay',
        'call back',
      ]);
    });

    testWidgets('role badge next to the name', (tester) async {
      controller.insert(
        TextMessage(id: 'm', author: ana, createdAt: ago(1), text: 'Hi'),
      );
      await pump(tester, view());
      expect(find.byKey(const Key('chatx_role_admin')), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
    });
  });

  group('composer', () {
    testWidgets('attachments tray sends files with a caption', (tester) async {
      final sent = <(List<String>, String)>[];
      var attachTaps = 0;
      await pump(
        tester,
        view(
          onAttach: () => attachTaps++,
          onAttachments: (files, caption, _) =>
              sent.add((files.map((f) => f.name).toList(), caption)),
        ),
      );
      await tester.tap(find.byKey(const Key('chatx_attach_button')));
      expect(attachTaps, 1);

      controller.composer.addAttachments([
        ChatAttachment(
          id: '1',
          name: 'photo.png',
          kind: ChatAttachmentKind.image,
          bytes: _pixel,
        ),
        const ChatAttachment(id: '2', name: 'notes.pdf'),
      ]);
      await tester.pump();
      expect(find.byKey(const Key('chatx_attachment_tray')), findsOneWidget);
      expect(find.text('Add a caption…'), findsOneWidget);

      await tester.tap(find.byKey(const Key('chatx_remove_attachment_2')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('chatx_send_button')));
      await tester.pump();
      expect(sent.single.$1, ['photo.png']);
      expect(sent.single.$2, '');
      expect(find.byKey(const Key('chatx_attachment_tray')), findsNothing);
    });

    testWidgets('formatting shortcuts, up arrow and escape', (tester) async {
      final edits = <String>[];
      controller.insert(
        TextMessage(id: 'mine', author: me, createdAt: ago(1), text: 'old'),
      );
      await pump(tester, view(onEdit: (m, text) => edits.add(m.id)));
      final field = find.byKey(const Key('chatx_input_field'));
      await tester.tap(field);
      await tester.enterText(field, 'hello world');
      final editable =
          tester.state<EditableTextState>(find.byType(EditableText));
      editable.userUpdateTextEditingValue(
        const TextEditingValue(
          text: 'hello world',
          selection: TextSelection(baseOffset: 6, extentOffset: 11),
        ),
        SelectionChangedCause.keyboard,
      );
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      expect(
          tester.widget<TextField>(field).controller!.text, 'hello **world**');

      tester.widget<TextField>(field).controller!.clear();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(controller.composer.editing.value?.id, 'mine');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(controller.composer.editing.value, isNull);
    });
  });

  testWidgets('selection menu offers formatting', (tester) async {
    await pump(tester, view());
    final field = find.byKey(const Key('chatx_input_field'));
    await tester.enterText(field, 'Ship it today');
    final editable = tester.state<EditableTextState>(find.byType(EditableText));
    editable.userUpdateTextEditingValue(
      const TextEditingValue(
        text: 'Ship it today',
        selection: TextSelection(baseOffset: 8, extentOffset: 13),
      ),
      SelectionChangedCause.longPress,
    );
    await tester.pump();
    expect(editable.showToolbar(), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('Bold'), findsOneWidget);
    await tester.tap(find.text('Bold'));
    await tester.pump();
    expect(
        tester.widget<TextField>(field).controller!.text, 'Ship it **today**');
  });

  group('navigation', () {
    testWidgets('offline banner and queued messages', (tester) async {
      final queued = <String>[];
      controller.insert(
        TextMessage(
          id: 'q',
          author: me,
          createdAt: ago(1),
          text: 'later',
          status: MessageStatus.queued,
        ),
      );
      await pump(
        tester,
        view(
          connection: ChatConnectionState.offline,
          onQueued: (m) => queued.addAll(m.map((e) => e.id)),
        ),
      );
      expect(find.text('Waiting for network…'), findsOneWidget);
      // Banner icon and the status icon of the queued message.
      expect(find.byIcon(Icons.cloud_off_rounded), findsNWidgets(2));
      await pump(
        tester,
        view(
          connection: ChatConnectionState.connecting,
          onQueued: (m) => queued.addAll(m.map((e) => e.id)),
        ),
      );
      expect(find.text('Connecting…'), findsOneWidget);
      expect(queued, isEmpty);
      await pump(
        tester,
        view(onQueued: (m) => queued.addAll(m.map((e) => e.id))),
      );
      await tester.pumpAndSettle();
      expect(queued, ['q']);
      expect(find.byKey(const Key('chatx_connection_banner')), findsNothing);
    });

    testWidgets('jumps to unread mentions', (tester) async {
      controller.insertAll([
        for (var i = 0; i < 40; i++)
          TextMessage(
            id: 'm$i',
            author: ana,
            createdAt: ago(200 - i),
            text: 'Message $i\nwith two lines',
          ),
      ]);
      await pump(tester, view());
      await tester.drag(
        find.byType(CustomScrollView).first,
        const Offset(0, 2000),
      );
      await tester.pumpAndSettle();
      controller.insert(
        TextMessage(
          id: 'hey',
          author: ana,
          createdAt: DateTime.now(),
          text: '@me can you check this?',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('chatx_mentions_button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('chatx_mentions_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('chatx_mentions_button')), findsNothing);
      expect(find.byKey(const Key('chatx_bubble_hey')), findsOneWidget);
    });

    testWidgets('date separators open a date picker', (tester) async {
      controller.insert(
        TextMessage(id: 'm', author: ana, createdAt: ago(1), text: 'Hi'),
      );
      await pump(tester, view());
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('hover actions and right click', (tester) async {
      controller.insert(
        TextMessage(id: 'm', author: ana, createdAt: ago(1), text: 'Hi'),
      );
      await pump(tester, view());
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(
        tester.getCenter(find.byKey(const Key('chatx_bubble_m'))),
      );
      await tester.pump();
      expect(find.byKey(const Key('chatx_hover_m')), findsOneWidget);
      await mouse.moveTo(const Offset(5, 5));
      await tester.pump();
      expect(find.byKey(const Key('chatx_hover_m')), findsNothing);

      await tester.tap(
        find.byKey(const Key('chatx_bubble_m')),
        buttons: kSecondaryMouseButton,
      );
      await tester.pumpAndSettle();
      expect(find.text('Copy text'), findsOneWidget);
    });

    testWidgets('media gallery lists media, files and links', (tester) async {
      controller.insertAll([
        ImageMessage(
          id: 'i',
          author: ana,
          createdAt: ago(3),
          images: const [ChatImage(uri: 'a'), ChatImage(uri: 'b')],
        ),
        FileMessage(id: 'f', author: ana, createdAt: ago(2), name: 'plan.pdf'),
        TextMessage(
          id: 't',
          author: ana,
          createdAt: ago(1),
          text: 'See https://dart.dev and javascript:alert(1)',
        ),
      ]);
      await pump(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => ChatMediaGallery.show(
              context,
              controller: controller,
              imageProviderBuilder: (_) => MemoryImage(_pixel),
            ),
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Media · 2'), findsOneWidget);
      expect(find.text('Files · 1'), findsOneWidget);
      expect(find.text('Links · 1'), findsOneWidget);
      await tester.tap(find.text('Links · 1'));
      await tester.pumpAndSettle();
      expect(find.text('https://dart.dev'), findsOneWidget);
    });

    testWidgets('member list sorts by role, profile actions', (tester) async {
      var blocked = false;
      await pump(
        tester,
        Builder(
          builder: (context) => Column(
            children: [
              Expanded(
                child: ChatMemberList(
                  members: const [
                    ChatUser(id: 'z', name: 'Zoe'),
                    ChatUser(id: 'o', name: 'Omar', role: ChatRole.owner),
                    ChatUser(id: 'b', name: 'Bea', role: ChatRole.moderator),
                  ],
                  onlineIds: const {'z'},
                ),
              ),
              TextButton(
                onPressed: () => ChatUserProfile.show(
                  context,
                  user: ana,
                  subtitle: 'online',
                  actions: [
                    ChatProfileAction(
                      icon: Icons.block,
                      label: 'Block',
                      onPressed: () => blocked = true,
                    ),
                  ],
                ),
                child: const Text('profile'),
              ),
            ],
          ),
        ),
      );
      final names = tester
          .widgetList<ListTile>(find.byType(ListTile))
          .map((t) => ((t.title! as Row).children.first as Flexible).child)
          .map((w) => (w as Text).data)
          .toList();
      expect(names, ['Omar', 'Bea', 'Zoe']);

      await tester.tap(find.text('profile'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('chatx_user_profile')), findsOneWidget);
      await tester.tap(find.text('Block'));
      await tester.pumpAndSettle();
      expect(blocked, isTrue);
    });
  });
}
