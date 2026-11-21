# chatx

[![pub package](https://img.shields.io/pub/v/chatx.svg)](https://pub.dev/packages/chatx)
[![CI](https://github.com/jacd007/chatx/actions/workflows/ci.yml/badge.svg)](https://github.com/jacd007/chatx/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/jacd007/chatx/branch/main/graph/badge.svg)](https://codecov.io/gh/jacd007/chatx)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A complete chat UI for Flutter that works with **any backend** and has
**zero dependencies**.

You bring the messages (from Firebase, Supabase, WebSockets, REST, a local
database or an LLM). chatx renders a polished, accessible conversation that
follows your app's theme.

| Conversation | Popup menu | Swipe to reply |
| :---: | :---: | :---: |
| <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/01_conversation.png" width="240" alt="Conversation with replies, reactions and a new messages separator"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/02_popup_menu.png" width="240" alt="Popup menu with quick reactions"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/03_reply.png" width="240" alt="Reply banner after swiping a message"> |
| **Survey** | **Survey steps** | **Poll & countdown** |
| <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/16_survey_seen_forward.png" width="240" alt="Survey card, read receipts and a forwarded message"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/17_survey_nps.png" width="240" alt="Step-by-step survey with an NPS question"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/11_poll_countdown_pinned.png" width="240" alt="Poll results, countdown announcement and pinned banner"> |
| **Bot buttons** | **Disappearing code** | **Thread** |
| <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/18_bot_buttons.png" width="240" alt="Bot message with buttons and quick replies"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/20_bot_disappearing.png" width="240" alt="Disappearing message with a countdown"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/19_thread.png" width="240" alt="Thread view with the root message on top"> |
| **Images, voice, files** | **Image viewer** | **Recording** |
| <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/08_images_voice.png" width="240" alt="Image grid, playing voice note and files"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/09_image_viewer.png" width="240" alt="Full-screen image viewer"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/10_voice_recording.png" width="240" alt="Recording a voice note with slide to cancel"> |
| **Links & spoilers** | **Emoji picker** | **Header typing** |
| <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/07_files_links_spoilers.png" width="240" alt="Link preview card, hidden spoiler text and blurred spoiler image"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/21_emoji_picker.png" width="240" alt="Built-in emoji picker with categories"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/22_header_typing.png" width="240" alt="Chat header showing typing"> |
| **Mentions** | **Search** | **Selection** |
| <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/12_mentions.png" width="240" alt="Mention suggestions above the input"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/13_search.png" width="240" alt="Search bar with highlighted matches"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/14_selection.png" width="240" alt="Multi-selection with the selection bar"> |
| **Floating date** | **AI answers** | **Dark mode** |
| <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/15_floating_date.png" width="240" alt="Date chip floating while scrolling"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/04_ai_markdown.png" width="240" alt="Assistant answer with markdown"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/06_dark_custom_look.png" width="240" alt="Dark theme with custom colors"> |

## Features

- **Drop-in screen.** `ChatView` gives you a message list and input bar.
- **Any backend.** A plain `ChatController` holds the state. No streams or
  state-management package required.
- **Markdown.** Bold, italic, strike, code, code blocks, quotes, lists,
  headings and links.
- **Streaming.** Show LLM answers token by token. Only the streaming bubble
  rebuilds.
- **Replies.** Swipe a bubble to reply. Quotes jump to the original message.
- **Reactions, editing and deleting** from a menu that opens as a bottom
  sheet or as a popup, on long press or on tap.
- **Delivery status.** Sending, sent, delivered, read and failed, with retry.
- **Rich content.** Image grids with a zoomable viewer, files, voice notes
  with waveform and press-and-hold recording, polls, countdown
  announcements and link previews. Upload progress on images and files.
- **Surveys and polls.** Quick votes with live results, and multi-question
  surveys (choice, star rating, NPS, free text) answered step by step.
- **Bots and threads.** Buttons inside messages, quick-reply chips, threads
  with reply counts, "Seen by" receipts, forwarding and disappearing
  messages.
- **Built-in emoji picker** with categories and search, a `ChatHeader` with
  presence and typing, and drafts that survive leaving the chat.
- **Spoilers.** `||hidden text||` and blurred images, revealed on tap.
- **Group features.** `@mentions` with suggestions, pinned messages, search
  with highlighted results, multi-selection and a floating date while
  scrolling.
- **Bubbles with character.** Tail at the bottom (iMessage style), nip at the
  top (WhatsApp style) or none, plus radius, shadow and outline.
- **Conversation UX.** Typing indicator, day separators, author grouping,
  avatars, "new messages" separator, large emoji-only messages, infinite
  history and a scroll-to-bottom button with unread count.
- **Your design.** Derived from Material 3 with automatic dark mode. Override
  any color or style, or replace any piece with a builder.
- **Accessible.** Screen reader labels, 48dp touch targets, text scaling and
  reduced-motion support.
- **Safe by default.** HTML is never interpreted and only `http`, `https` and
  `mailto` links are tappable.
- **Everywhere.** Android, iOS, web, macOS, Windows and Linux.
- **Zero dependencies.** Only the Flutter SDK.

## Contents

- [Installation](#installation)
  - [Material and `material_ui`](#material-and-material_ui)
- [Quick start](#quick-start)
- [Core concepts](#core-concepts)
- [Guides](#guides)
  - [Connect your backend](#connect-your-backend)
  - [Delivery status and retry](#delivery-status-and-retry)
  - [Streaming answers (AI chats)](#streaming-answers-ai-chats)
  - [Infinite history](#infinite-history)
  - [Typing indicator](#typing-indicator)
  - [Opening links](#opening-links)
  - [Replies and swipe actions](#replies-and-swipe-actions)
  - [Message menu](#message-menu)
  - [Reactions](#reactions)
  - [Editing and deleting](#editing-and-deleting)
  - [Unread messages](#unread-messages)
  - [Images and files](#images-and-files)
  - [Voice notes](#voice-notes)
  - [Polls](#polls)
  - [Surveys](#surveys)
  - [Bot buttons and quick replies](#bot-buttons-and-quick-replies)
  - [Threads](#threads)
  - [Read receipts](#read-receipts)
  - [Forwarding](#forwarding)
  - [Disappearing messages](#disappearing-messages)
  - [Drafts](#drafts)
  - [Chat header](#chat-header)
  - [Emoji picker](#emoji-picker)
  - [Countdowns](#countdowns)
  - [Link previews](#link-previews)
  - [Spoilers](#spoilers)
  - [Mentions](#mentions)
  - [Search](#search)
  - [Selection](#selection)
  - [Pinned messages](#pinned-messages)
  - [Custom message types](#custom-message-types)
  - [Theming](#theming)
  - [Bubble shape](#bubble-shape)
  - [Builders](#builders)
  - [Localization](#localization)
- [Markdown reference](#markdown-reference)
- [Accessibility](#accessibility)
- [Security](#security)
- [FAQ](#faq)

## Installation

```bash
flutter pub add chatx
```

Requires Flutter 3.27 or newer.

### Material and `material_ui`

Flutter 3.50 moved the Material library to the
[`material_ui`](https://pub.dev/packages/material_ui) package and deprecated
`package:flutter/material.dart`. The two libraries use separate types, so
chatx keeps using `flutter/material.dart` to work in every app today:

- **Your app imports `package:flutter/material.dart`:** nothing to do.
- **Your app uses `material_ui`:** wrap your app once with the official
  bridge, so chatx receives your theme and localizations:

  ```dart
  MaterialApp(
    builder: (context, child) => MaterialUiCompatibilityBridge(child: child!),
    // ...
  )
  ```

chatx will move to `material_ui` in a future major version, once most apps
have migrated. The bridge setup is tested in CI on every change.

## Quick start

This is a complete, runnable chat with an echo bot:

```dart
import 'package:chatx/chatx.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: ChatPage()));

const me = ChatUser(id: 'me', name: 'Me');
const bot = ChatUser(id: 'bot', name: 'Echo bot');

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final controller = ChatController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void send(String text, ChatMessage? replyTo) {
    controller.insert(TextMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      author: me,
      createdAt: DateTime.now(),
      text: text,
      replyToId: replyTo?.id,
    ));
    controller.insert(TextMessage(
      id: '${DateTime.now().microsecondsSinceEpoch}-reply',
      author: bot,
      createdAt: DateTime.now(),
      text: 'You said: **$text**',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Echo bot')),
      body: ChatView(
        controller: controller,
        currentUser: me,
        onSendMessage: send,
      ),
    );
  }
}
```

Place `ChatView` inside a `Scaffold` (or any widget with a bounded height) so
the input bar moves above the keyboard.

## Core concepts

### Users

```dart
const ana = ChatUser(
  id: 'user-42',                         // required, stable and unique
  name: 'Ana Ruiz',                      // optional, shown above her messages
  avatarUrl: 'https://example.com/a.png' // optional, falls back to initials
);
```

`ChatView.currentUser` decides which messages are outgoing (right side).

### Messages

`ChatMessage` is a sealed class with three kinds:

| Type | Use it for |
| --- | --- |
| `TextMessage` | Text with markdown. Supports streaming and an "edited" label. |
| `SystemMessage` | Centered notices like "Ana joined the chat". |
| `ImageMessage` | One or more images with an optional caption. |
| `FileMessage` | A file with icon, name, size and upload progress. |
| `VoiceMessage` | A voice note with waveform and playback. |
| `PollMessage` | A quick vote: one question, closed options. |
| `SurveyMessage` | A questionnaire with several questions. |
| `CountdownMessage` | An announcement with a live countdown. |
| `CustomMessage` | Anything else: images, polls, locations… Rendered by your builder. |

Every message has an `id`, an `author`, a `createdAt` date, and optionally a
`status`, a `replyToId`, `reactions` and `metadata` for your own data.

### The controller

`ChatController` stores messages sorted by `createdAt`. You change it, and
the view updates.

| Method | What it does |
| --- | --- |
| `insert(message)` | Adds a message. Throws if the ID exists. |
| `insertAll(messages)` | Adds many messages with one rebuild. |
| `upsert(message)` | Inserts, or replaces the message with the same ID. |
| `update(message)` | Replaces the message with the same ID. |
| `updateStatus(id, status)` | Changes the delivery status. |
| `appendText(id, delta)` | Appends streamed text. |
| `completeStream(id)` | Marks a streamed message as finished. |
| `remove(id)` | Deletes a message. |
| `setMessages(messages)` | Replaces everything, for example when switching chats. |
| `editText(id, text)` | Replaces the text and shows the "edited" label. |
| `toggleReaction(id, emoji, userId)` | Adds or removes a user's reaction. |
| `setTyping(user, isTyping: true)` | Shows or hides the typing indicator. |
| `startReply(message)` / `cancelReply()` | Shows or hides the reply banner. |
| `startEditing(message)` / `cancelEditing()` | Starts or stops editing in the input bar. |
| `votePoll(id, optionId, userId)` | Records or removes a vote. |
| `pin(id)` / `unpin(id)` | Pins or unpins a message. |
| `toggleSelection(id)` / `clearSelection()` | Controls selection mode. |
| `search(query)` | Returns matching message IDs, newest first. |
| `recordSurveyResponse(id, userId)` | Marks a survey as answered by a user. |
| `setDraft(text)` / `draft` | The unsent text of the input. |
| `scrollToMessage(id)` | Scrolls the view to a message and highlights it. |

Always call `controller.dispose()` when the screen goes away.

> **Performance note.** Changes to a single message (status, text, metadata)
> rebuild only that bubble. Listeners added with `addListener` run only for
> structural changes: insertions, removals and reordering. Use
> `controller.watch(id)` to follow one message.

## Guides

### Connect your backend

chatx does not know about your server. The pattern is always the same:

1. Listen to your backend and copy its messages into the controller.
2. In `onSendMessage`, show the message right away and send it to the backend.

```dart
// 1. Incoming messages (WebSocket, Firestore snapshot, SSE, ...).
subscription = api.messages(roomId).listen((dto) {
  controller.upsert(TextMessage(
    id: dto.id,
    author: ChatUser(id: dto.senderId, name: dto.senderName),
    createdAt: dto.sentAt,
    text: dto.body,
    status: MessageStatus.sent,
  ));
});

// 2. Outgoing messages.
ChatView(
  controller: controller,
  currentUser: me,
  onSendMessage: (text, replyTo) async {
    final id = uuid();
    controller.insert(TextMessage(
      id: id,
      author: me,
      createdAt: DateTime.now(),
      text: text,
      replyToId: replyTo?.id,
      status: MessageStatus.sending,
    ));
    try {
      await api.send(roomId, id: id, text: text);
      controller.updateStatus(id, MessageStatus.sent);
    } catch (_) {
      controller.updateStatus(id, MessageStatus.failed);
    }
  },
)
```

Use `upsert` for incoming messages: when the server echoes back a message you
already inserted, it is replaced instead of duplicated.

### Delivery status and retry

Set `status` on outgoing messages and update it as your backend reports
progress:

```dart
controller.updateStatus(id, MessageStatus.delivered);
controller.updateStatus(id, MessageStatus.read);
```

Messages with `MessageStatus.failed` show a retry button when you provide
`onRetry`:

```dart
ChatView(
  onRetry: (message) {
    controller.updateStatus(message.id, MessageStatus.sending);
    resend(message);
  },
  // ...
)
```

### Streaming answers (AI chats)

Insert an empty message with `isStreaming: true`. It shows animated dots, then
the text with a blinking caret as tokens arrive.

```dart
final id = uuid();
controller.insert(TextMessage(
  id: id,
  author: assistant,
  createdAt: DateTime.now(),
  text: '',
  isStreaming: true,
));

await for (final token in llm.stream(prompt)) {
  controller.appendText(id, token);
}
controller.completeStream(id);
```

Markdown is re-parsed safely on every chunk, so an unfinished code block
renders correctly while it streams.

### Infinite history

Provide `onLoadMore`. chatx calls it when the user scrolls near the oldest
message, and when the first page does not fill the screen. Insert the page and
return whether older messages remain:

```dart
ChatView(
  onLoadMore: () async {
    final page = await api.history(roomId, before: oldestCursor, limit: 30);
    controller.insertAll(page.map(toMessage));
    oldestCursor = page.isEmpty ? oldestCursor : page.last.cursor;
    return page.length == 30; // false stops further calls
  },
  // ...
)
```

If `onLoadMore` throws, chatx shows a retry button at the top and reports the
error to `FlutterError.onError` (so Crashlytics or Sentry receive it).

### Typing indicator

Show other users typing:

```dart
controller.setTyping(ana, isTyping: true);
controller.setTyping(ana, isTyping: false);
```

Report the current user typing to your backend:

```dart
ChatView(
  onTypingChanged: (isTyping) => api.sendTyping(roomId, isTyping),
  // ...
)
```

`onTypingChanged(false)` fires after 3 seconds without keystrokes and when the
message is sent.

### Opening links

chatx has no dependencies, so it does not open links itself. It gives you the
tapped `Uri`. With [`url_launcher`](https://pub.dev/packages/url_launcher):

```dart
ChatView(
  onLinkTap: (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
  // ...
)
```

Only links allowed by `linkPolicy` are tappable. To allow your own deep links:

```dart
ChatView(
  linkPolicy: const ChatLinkPolicy(
    allowedSchemes: {'https', 'mailto', 'myapp'},
  ),
  // ...
)
```

### Replies and swipe actions

Swiping a bubble toward the center starts a reply: a banner appears above the
input, and `onSendMessage` receives the message being replied to. Store its
ID in `replyToId` and the new bubble shows a quote. Tapping the quote scrolls
to the original message and highlights it.

```dart
ChatView(
  onSendMessage: (text, replyTo) => controller.insert(TextMessage(
    id: uuid(),
    author: me,
    createdAt: DateTime.now(),
    text: text,
    replyToId: replyTo?.id,
  )),
  // ...
)
```

Swipe to reply is on by default. Change what the swipe does, or turn it off:

```dart
ChatView(
  swipeAction: ChatSwipeAction(
    icon: Icons.star_outline,
    label: 'Star',
    onTriggered: (message) => star(message),
  ),
  // swipeAction: null, // disables swiping
  // ...
)
```

The bubble follows the finger with a spring, and a haptic tick marks the
point where releasing triggers the action. Screen reader users get the same
action in their actions menu.

### Message menu

A long press opens a bottom sheet by default. Open a popup anchored to the
bubble instead, and on a simple tap:

```dart
ChatView(
  messageMenuStyle: ChatMessageMenuStyle.popup,
  messageMenuTrigger: ChatMessageMenuTrigger.tap,
  // ...
)
```

The menu includes the built-in entries that apply to each message: Reply,
Copy text, Edit and Delete (the last two only for the current user's messages
and only when you provide `onEditMessage` and `onDeleteMessage`). Add, remove
or reorder entries with `messageActionsBuilder`, which receives those
defaults:

```dart
ChatView(
  messageActionsBuilder: (context, message, defaults) => [
    ...defaults,
    ChatMessageAction(
      label: 'Forward',
      icon: Icons.forward,
      onSelected: (message) => forward(message),
    ),
  ],
  // ...
)
```

Use `onMessageLongPress` to show your own UI instead.

### Reactions

Provide `onReactionSelected` to show a row of quick reactions in the menu and
make the reaction chips under bubbles tappable:

```dart
ChatView(
  onReactionSelected: (message, emoji) {
    controller.toggleReaction(message.id, emoji, me.id);
    api.react(message.id, emoji);
  },
  reactionEmojis: const ['👍', '❤️', '😂', '🎉'], // optional
  // ...
)
```

Reactions live in `ChatMessage.reactions`, so messages from your backend can
carry them:

```dart
TextMessage(
  // ...
  reactions: const [ChatReaction(emoji: '👍', userIds: ['ana', 'me'])],
)
```

### Editing and deleting

```dart
ChatView(
  onEditMessage: (message, newText) {
    controller.editText(message.id, newText);
    api.edit(message.id, newText);
  },
  onDeleteMessage: (message) {
    controller.remove(message.id);
    api.delete(message.id);
  },
  // ...
)
```

"Edit" fills the input with the message text and shows an edit banner; the
send button becomes a check mark. Edited messages show an "edited" label.

### Unread messages

Pass the ID of the oldest unread message. chatx shows a "New messages"
separator above it and scrolls there when the view opens:

```dart
ChatView(
  firstUnreadMessageId: conversation.firstUnreadId,
  // ...
)
```

Messages with only one to three emoji are shown large and without a bubble.
Turn this off with `enableJumboEmoji: false`.

### Images and files

```dart
controller.insert(ImageMessage(
  id: uuid(),
  author: ana,
  createdAt: DateTime.now(),
  images: const [
    ChatImage(uri: 'https://example.com/1.jpg', width: 1200, height: 800),
    ChatImage(uri: 'https://example.com/2.jpg'),
  ],
  caption: 'Our **trip**',
));

controller.insert(FileMessage(
  id: uuid(),
  author: me,
  createdAt: DateTime.now(),
  name: 'Report.pdf',
  sizeBytes: 1843200,
  uploadProgress: 0, // update while uploading, then copyWith(clearUploadProgress: true)
));
```

The grid shows up to four images and a "+N" counter. Give `width` and
`height` when you know them so the list does not jump while images load.
Tapping an image opens a full-screen viewer with zoom and swipe-down to
close; replace it with `onImageTap`. Images are decoded at the size they are
displayed to save memory.

Images load with `Image.network` by default. Use `imageProviderBuilder` for
assets, files, caching or authenticated URLs:

```dart
ChatView(
  imageProviderBuilder: (uri) => NetworkImage(uri, headers: authHeaders),
  onFileTap: (file) => openFile(file.uri),
  // ...
)
```

### Voice notes

chatx draws voice notes and the recording UI, and never touches audio. Your
app plays and records with the plugin of its choice.

```dart
final playback = ValueNotifier<ChatVoicePlayback?>(null);

ChatView(
  voicePlayback: playback, // update from your player
  onVoicePlay: (message) => player.play(message.uri),
  onVoicePause: (message) => player.pause(),
  onVoiceSeek: (message, position) => player.seek(position),
  // Show the microphone button and record while it is held.
  onVoiceRecordStart: recorder.start,
  onVoiceRecordEnd: (duration, {required cancelled}) async {
    final file = await recorder.stop();
    if (!cancelled) sendVoiceNote(file, duration);
  },
  // ...
)
```

`VoiceMessage.waveform` takes amplitude samples between 0 and 1; chatx
resamples them to fit the bubble. While recording, sliding left cancels.
Screen reader users tap once to start and again to send.

### Polls

A poll is a quick vote: one question with closed options to decide
something now. For questionnaires, see [Surveys](#surveys).

```dart
controller.insert(PollMessage(
  id: uuid(),
  author: leo,
  createdAt: DateTime.now(),
  question: 'What should we eat?',
  options: const [
    PollOption(id: 'pizza', text: 'Pizza'),
    PollOption(id: 'tacos', text: 'Tacos'),
  ],
  allowsMultipleAnswers: false,
));

ChatView(
  onPollVote: (poll, optionId) {
    controller.votePoll(poll.id, optionId, me.id);
    api.vote(poll.id, optionId);
  },
  // ...
)
```

Results appear with animated bars after the user votes, or for everyone
once `isClosed` is `true`.

### Surveys

A survey is a questionnaire with several questions, for example to learn
what your users need. The bubble shows a card; answering opens a
step-by-step form with progress, back and next, and required questions.

```dart
controller.insert(SurveyMessage(
  id: uuid(),
  author: team,
  createdAt: DateTime.now(),
  title: 'How was our last meetup?',
  description: 'Takes 1 minute.',
  questions: const [
    RatingQuestion(id: 'overall', title: 'How did you like it?'),
    ChoiceQuestion(
      id: 'best',
      title: 'What did you enjoy most?',
      allowsMultipleAnswers: true,
      choices: [
        SurveyChoice(id: 'food', text: 'Food'),
        SurveyChoice(id: 'music', text: 'Music'),
      ],
    ),
    NpsQuestion(id: 'nps', title: 'How likely are you to recommend us?'),
    TextQuestion(id: 'ideas', title: 'Ideas?', isRequired: false),
  ],
));

ChatView(
  onSurveySubmit: (survey, response) {
    controller.recordSurveyResponse(survey.id, me.id);
    api.saveAnswers(survey.id, response.answers);
  },
  // ...
)
```

| Question | Answer type in `response.answers` |
| --- | --- |
| `ChoiceQuestion` | `List<String>` of choice IDs (`response.choices(id)`) |
| `RatingQuestion` | `int` from 1 to `max`, stars or faces (`response.rating(id)`) |
| `NpsQuestion` | `int` from 0 to 10 (`response.rating(id)`) |
| `TextQuestion` | `String` (`response.text(id)`) |

### Bot buttons and quick replies

```dart
controller.insert(TextMessage(
  id: uuid(),
  author: bot,
  createdAt: DateTime.now(),
  text: 'How can I help?',
  buttons: const [
    ChatMessageButton(
      id: 'track',
      label: 'Track my order',
      style: ChatButtonStyle.primary,
    ),
  ],
  quickReplies: const [
    ChatQuickReply(label: 'Billing'),
    ChatQuickReply(label: 'Talk to a human'),
  ],
));

ChatView(
  onMessageButton: (message, button) => bot.handle(button.id),
  // Optional: by default a quick reply sends its text.
  onQuickReply: (reply, message) => bot.send(reply.text),
  // ...
)
```

Quick replies appear above the input while that message is the newest one.

### Threads

```dart
TextMessage(
  // ...
  thread: ChatThreadSummary(
    replyCount: 3,
    participants: [sam, leo],
    lastReplyAt: lastReply,
  ),
)

ChatView(
  onThreadTap: (message) => Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Thread')),
      body: ChatView(
        controller: threadControllerFor(message),
        threadRoot: message, // shown on top, followed by the reply count
        currentUser: me,
        onSendMessage: sendToThread,
      ),
    ),
  )),
  // ...
)
```

### Read receipts

Fill `receipts` with who read a message. In group chats, small avatars
appear under the newest outgoing message, and "Info" in the menu lists every
reader with the time. Turn it off with `showReadReceipts: false`.

```dart
TextMessage(
  // ...
  receipts: [ChatReadReceipt(user: ana, readAt: readTime)],
)
```

### Forwarding

Messages with `forwardedFrom` show a "Forwarded from …" label. Provide
`onForwardMessages` to offer "Forward" in the menu and the selection bar;
let the user pick the destination there.

### Disappearing messages

Set `expiresAt` and the bubble shows the time left. The controller removes
the message when it expires (pass `removeExpiredMessages: false` to the
controller to handle it yourself).

```dart
TextMessage(
  // ...
  text: 'Your code is **739 102**',
  expiresAt: DateTime.now().add(const Duration(minutes: 2)),
)
```

### Drafts

The controller keeps the unsent text in `draft`. Keep the controller alive
(for example one per conversation in your state management) and the draft is
there when the user comes back, together with any reply in progress.
Persist it across restarts by listening to `controller.draft` and passing
`initialDraft` when you create the controller.

### Chat header

```dart
AppBar(
  title: ChatHeader(
    user: ana,
    isOnline: presence.online,
    lastSeenAt: presence.lastSeen,
    controller: controller, // shows "typing…"
    onTap: openProfile,
  ),
)
```

For groups, pass `memberCount`. `ChatHeader.relativeTime` formats times like
"5 min ago" or "yesterday at 18:03".

### Emoji picker

The input has an emoji button that swaps the keyboard for `ChatEmojiPicker`
(categories, search and recently used), and the reaction row has a "+"
button that opens it. Turn both off with `enableEmojiPicker: false`, or use
the picker anywhere:

```dart
ChatEmojiPicker(onSelected: (emoji) => insert(emoji))
```

### Countdowns

Announce something that is coming. The countdown updates every second and
shows a celebration label when it reaches zero:

```dart
controller.insert(CountdownMessage(
  id: uuid(),
  author: ana,
  createdAt: DateTime.now(),
  title: 'Community meetup',
  endsAt: DateTime(2026, 12, 24, 18),
  description: 'Rooftop at **Calle Mayor 12**',
));
```

### Link previews

chatx makes no network requests, so your backend (or app) provides the
preview data, for example from Open Graph tags:

```dart
TextMessage(
  // ...
  text: 'Look at this: https://pub.dev/packages/chatx',
  linkPreview: const ChatLinkPreview(
    url: 'https://pub.dev/packages/chatx',
    title: 'chatx | Flutter package',
    description: 'Zero-dependency chat UI for Flutter.',
    imageUri: 'https://example.com/card.png',
  ),
)
```

Tapping the card calls `onLinkTap`, subject to the same `linkPolicy` as
links in text.

### Spoilers

Wrap text in double pipes to hide it until the reader taps:

```dart
TextMessage(text: 'The killer was ||the gardener||', /* ... */)
```

Set `isSpoiler: true` on an `ImageMessage` to blur its images. Spoilers stay
hidden in reply quotes, banners and search previews.

### Mentions

```dart
ChatView(
  mentionableUsers: const [ana, leo, sam],
  onMentionTap: (user) => openProfile(user),
  // ...
)
```

Typing `@` suggests matching users above the input; picking one inserts
`@Name`. In messages, `@Name` of a known user is shown in bold and is
tappable, and mentions of the current user are highlighted.

### Search

```dart
final search = ChatSearchController(chatController: controller);

Scaffold(
  appBar: AppBar(
    title: searching
        ? ChatSearchBar(controller: search, onClose: stopSearching)
        : const Text('Chat'),
  ),
  body: ChatView(controller: controller, searchController: search, ...),
)
```

Matches are highlighted in every message, the bar shows "2/7", and the
arrows jump between results. Search looks at text, captions, file names,
polls and countdowns, ignoring case and markdown.

### Selection

"Select" in the message menu starts selection mode: rows show check marks
and the input is replaced by a bar with the count and actions. Built-in
actions copy the selected texts and, when `onDeleteMessage` is set and all
selected messages are yours, delete them. Add your own:

```dart
ChatView(
  selectionActionsBuilder: (context, selected, defaults) => [
    ...defaults,
    ChatSelectionAction(
      label: 'Forward',
      icon: Icons.forward,
      onSelected: (messages) => forward(messages),
    ),
  ],
  // ...
)
```

Set `enableSelection: false` to hide "Select".

### Pinned messages

```dart
ChatView(
  onPinMessage: (message, pinned) {
    pinned ? controller.pin(message.id) : controller.unpin(message.id);
    api.setPinned(message.id, pinned);
  },
  // ...
)
```

Pinned messages appear in a banner above the list. Tapping it jumps to the
message and, when there are several pins, cycles through them.

While scrolling, a date chip floats at the top of the list. Turn it off with
`showFloatingDate: false`.

### Custom message types

Use `CustomMessage` with a `type` and a `payload`, and render it with
`customMessageBuilder`. The result is placed inside a regular bubble, with
time and status.

```dart
controller.insert(CustomMessage(
  id: 'img-1',
  author: ana,
  createdAt: DateTime.now(),
  type: 'image',
  payload: 'https://example.com/photo.jpg',
));

ChatView(
  customMessageBuilder: (context, message, details) => switch (message.type) {
    'image' => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(message.payload! as String, width: 240),
      ),
    _ => const Text('Unsupported message'),
  },
  // ...
)
```

### Theming

With no configuration, chatx uses your app's `ColorScheme` and `TextTheme`,
including dark mode.

Override values for the whole app with a theme extension:

```dart
MaterialApp(
  theme: ThemeData(
    colorSchemeSeed: Colors.teal,
    extensions: const [
      ChatTheme(
        bubbleRadius: 12,
        outgoingBubbleColor: Color(0xFF0F766E),
      ),
    ],
  ),
)
```

Or for one chat with `ChatView.theme`. Unset values keep their defaults, and
text styles are merged (so `TextStyle(fontSize: 18)` only changes the size):

```dart
ChatView(
  theme: const ChatTheme(
    incomingTextStyle: TextStyle(fontSize: 18),
    maxBubbleWidthFactor: 0.9,
  ),
  // ...
)
```

Main `ChatTheme` values:

| Group | Values |
| --- | --- |
| Bubbles | `outgoingBubbleColor`, `incomingBubbleColor`, `bubbleRadius`, `bubbleGroupedRadius`, `bubblePadding`, `maxBubbleWidth`, `maxBubbleWidthFactor` |
| Bubble shape | `bubbleTail`, `bubbleTailWidth`, `bubbleTailHeight`, `bubbleElevation`, `bubbleShadowColor`, `outgoingBubbleBorderSide`, `incomingBubbleBorderSide` |
| Reactions and replies | `reactionChipColor`, `reactionChipSelectedColor`, `highlightColor`, `unreadSeparatorColor` |
| Text | `outgoingTextStyle`, `incomingTextStyle`, `linkStyle`, `codeTextStyle`, `timestampTextStyle`, `userNameTextStyle` |
| List | `backgroundColor`, `dateSeparatorTextStyle`, `dateSeparatorColor`, `systemMessageTextStyle`, `avatarSize`, `typingIndicatorColor` |
| Input | `inputBackgroundColor`, `inputFieldColor`, `inputTextStyle`, `inputHintStyle`, `sendButtonColor`, `sendButtonIconColor` |
| Status | `readStatusColor`, `errorColor` |
| Scroll button | `scrollButtonColor`, `scrollButtonIconColor`, `unreadBadgeColor`, `unreadBadgeTextColor` |

Inside your own builders, read the resolved values with
`ChatThemeData.of(context)`.

### Bubble shape

Bubbles draw a tail on the author's side. Choose its style in the theme:

| `bubbleTail` | Look |
| --- | --- |
| `ChatBubbleTail.bottom` (default) | Curved tail on the last bubble of a group, like iMessage. |
| `ChatBubbleTail.top` | Pointed nip on the first bubble of a group, like WhatsApp. |
| `ChatBubbleTail.none` | Rounded rectangles. |

```dart
ChatView(
  theme: ChatTheme(
    bubbleTail: ChatBubbleTail.top,
    bubbleRadius: 12,
    bubbleElevation: 1,
    incomingBubbleBorderSide: BorderSide(color: Colors.black12),
  ),
  // ...
)
```

Every bubble of a group reserves the tail space, so bubbles with and without
a tail stay aligned. The shape is also available as `ChatBubbleBorder` for
your own widgets.

### Builders

Replace any part of the UI:

| Builder | Replaces |
| --- | --- |
| `bubbleBuilder` | Message bubbles. Receives the default bubble, so you can wrap it. |
| `customMessageBuilder` | Content of `CustomMessage`s. |
| `systemMessageBuilder` | `SystemMessage`s. |
| `avatarBuilder` | Avatars. |
| `inputBuilder` | The input bar. Reuse `ChatInput` to add buttons. |
| `dateSeparatorBuilder` | Day labels. |
| `typingIndicatorBuilder` | The typing indicator. |
| `scrollToBottomBuilder` | The scroll-to-bottom button. |
| `loadMoreIndicatorBuilder` | The spinner shown while loading history. |
| `emptyStateBuilder` | The empty conversation placeholder. |

Example: add an attachment button to the input bar.

```dart
ChatView(
  inputBuilder: (context, send, textController) => ChatInput(
    onSend: send,
    controller: textController, // lets "Edit" fill the field
    leading: IconButton(
      icon: const Icon(Icons.attach_file),
      onPressed: pickFile,
    ),
  ),
  // ...
)
```

Other `ChatView` options: `showAvatars`, `showUserNames`,
`showDateSeparators`, `enableMarkdown`, `enableJumboEmoji`,
`groupingInterval`, `inputEnabled`, `onMessageTap`, `onAvatarTap` and
`scrollController`.

### Localization

chatx ships English and Spanish strings and picks them from the app locale.
Dates and times use your app's `MaterialLocalizations`, so add
`flutter_localizations` to get them in every language:

```dart
MaterialApp(
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  supportedLocales: const [Locale('en'), Locale('es')],
)
```

Change some strings:

```dart
ChatView(
  localizations: ChatLocalizations.en.copyWith(inputHint: 'Say hi'),
  // ...
)
```

Add a language by creating a full `ChatLocalizations` instance and passing it
to `ChatView.localizations`.

## Markdown reference

| You type | You get |
| --- | --- |
| `**bold**` or `__bold__` | **bold** |
| `*italic*` or `_italic_` | _italic_ |
| `~~strike~~` | ~~strike~~ |
| `` `code` `` | `code` |
| ```` ```lang ```` … ```` ``` ```` | code block, scrolls horizontally |
| `> quote` | block quote |
| `- item` or `1. item` | lists |
| `# Title` | heading (`#` to `######`) |
| `[label](https://…)` | link |
| `https://…` or `www.…` | automatic link |
| `\*` | a literal `*` |

Rules that keep chats readable: `snake_case` words stay intact, single line
breaks are kept, and `#hashtags` are not headings. Turn markdown off with
`enableMarkdown: false`; links are still detected.

Use `ChatText` to render the same markdown anywhere in your app.

## Accessibility

- Bubbles announce the author and time, and status icons have labels.
- The typing indicator is a live region.
- Interactive elements are at least 48×48 dp, except the small reaction chips
  (the same reactions are available in the message menu).
- Swipe actions are also available as screen reader custom actions.
- Spoiler text is announced as a spoiler, never read aloud until revealed.
- Voice recording works with a screen reader: tap to start, tap to send.
- Layouts adapt to large text sizes.
- Animations stop when the system asks to reduce motion.
- Layouts mirror correctly in right-to-left languages.
- Widgets used in tests have stable keys: `chatx_input_field`,
  `chatx_send_button`, `chatx_scroll_to_bottom`, `chatx_bubble_<id>`,
  `chatx_quote_<id>`, `chatx_reaction_<id>_<emoji>`, `chatx_react_<emoji>`,
  `chatx_reply_banner`, `chatx_cancel_reply`, `chatx_edit_banner`,
  `chatx_cancel_edit`, `chatx_unread_separator`, `chatx_retry_<id>`,
  `chatx_load_more_retry`, `chatx_image_<id>_<index>`, `chatx_viewer_close`,
  `chatx_voice_play_<id>`, `chatx_record_button`, `chatx_poll_<id>_<option>`,
  `chatx_link_preview`, `chatx_spoiler_<id>`, `chatx_mention_<userId>`,
  `chatx_pinned_banner`, `chatx_selection_bar`, `chatx_selection_close`,
  `chatx_selection_action_<index>`, `chatx_search_field`,
  `chatx_search_older`, `chatx_search_newer`, `chatx_floating_date`,
  `chatx_survey_<id>`, `chatx_survey_next`, `chatx_survey_back`,
  `chatx_survey_choice_<id>`, `chatx_survey_rating_<n>`,
  `chatx_survey_nps_<n>`, `chatx_survey_text`, `chatx_button_<id>_<button>`,
  `chatx_quick_reply_<index>`, `chatx_thread_<id>`, `chatx_seen_by`,
  `chatx_expiry`, `chatx_emoji_button`, `chatx_emoji_<emoji>`,
  `chatx_emoji_search`, `chatx_react_more` and `chatx_header`.

## Security

Message text usually comes from other people, so chatx treats it as untrusted:

- HTML is shown as text, never interpreted.
- Only links allowed by `ChatLinkPolicy` are tappable. `javascript:`, `file:`,
  `intent:` and other schemes stay plain text.
- chatx stores nothing and makes no network requests, except loading avatar
  images from `ChatUser.avatarUrl`.

See [SECURITY.md](SECURITY.md) to report a vulnerability.

## FAQ

**Does chatx send or store messages?** No. It only renders the state in your
`ChatController`. Persistence and networking stay in your code.

**How do I show images, voice notes or files?** Use `ImageMessage`,
`VoiceMessage` and `FileMessage`. Your app chooses the picker, recorder,
player and storage; chatx draws everything else. For other content, use
`CustomMessage` and `customMessageBuilder`.

**Why are links not opening?** Provide `onLinkTap`. See
[Opening links](#opening-links).

**Can I use Riverpod, Bloc or Provider?** Yes. Create the `ChatController`
wherever you keep state and feed it from your providers or blocs.

## Example app

The [`example`](example) folder contains demos for every feature: basic chat
(replies, reactions, popup menu, editing), media and files (images, voice
notes, links, spoilers), community (survey, poll, thread, read receipts,
forwarding, countdown, pins, mentions, search, selection), support bot
(buttons, quick replies, disappearing code), AI streaming, bubble styles, custom look and infinite
history. Its
[integration test](example/integration_test/screenshots_test.dart) walks
through the app on a device and produces the screenshots above.

```bash
cd example
flutter run
```

## Contributing

Contributions are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) first.

## License

[MIT](LICENSE) © Jesus Castillo
