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

| AI answer with code and table | Stop while streaming | Location, contact and sticker |
| :---: | :---: | :---: |
| <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/23_ai_code_table.png" width="240" alt="Assistant answer with highlighted code, a table and rating buttons"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/24_ai_stop.png" width="240" alt="Stop button while the answer streams"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/26_location_contact_sticker.png" width="240" alt="Location card with live badge, contact card and a sticker"> |

| Event with RSVP | Translation | Moderation menu |
| :---: | :---: | :---: |
| <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/28_event_rsvp.png" width="240" alt="Event card with RSVP buttons"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/25_translate_deleted_scheduled.png" width="240" alt="Translated message with a toggle to the original"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/29_moderation_menu.png" width="240" alt="Menu with translate, save, report and block"> |

| Edit history | Deleted and scheduled | Read-only channel |
| :---: | :---: | :---: |
| <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/30_edit_history.png" width="240" alt="Sheet with previous versions of a message"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/33_german.png" width="240" alt="Deleted placeholder and scheduled message, in German"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/31_read_only_channel.png" width="240" alt="Read-only announcements channel"> |

| Slow mode | Sticker packs | Text at 200% |
| :---: | :---: | :---: |
| <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/34_slow_mode.png" width="240" alt="Input disabled by slow mode with a countdown"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/27_sticker_picker.png" width="240" alt="Emoji picker with a sticker pack tab"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/32_large_text.png" width="240" alt="Conversation with text at 200%"> |

| Suggested prompts | Reasoning while thinking | Versions and sources |
| :---: | :---: | :---: |
| <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/36_ai_prompts.png" width="240" alt="Empty AI chat with suggested prompt cards"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/35_ai_reasoning.png" width="240" alt="Thinking block streaming the reasoning"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/37_ai_versions_sources.png" width="240" alt="Answer with source chips and a 2/2 version switcher"> |

| Video and attachments | Voice transcript | Unread mentions |
| :---: | :---: | :---: |
| <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/39_video_attachments.png" width="240" alt="Video message and the attachment tray above the input"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/40_voice_transcript.png" width="240" alt="Voice note with its transcript"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/41_workspace_mentions.png" width="240" alt="Role badges and the unread mentions button"> |

| Checklist and calls | Members | Profile |
| :---: | :---: | :---: |
| <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/42_checklist_call.png" width="240" alt="Shared checklist with progress and a video call entry"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/43_members.png" width="240" alt="Member list sorted by role with presence"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/44_profile.png" width="240" alt="Profile sheet with actions"> |

| Media gallery | Offline queue | Products |
| :---: | :---: | :---: |
| <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/45_gallery.png" width="240" alt="Gallery with media, files and links tabs"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/46_offline_queue.png" width="240" alt="Offline banner and a queued message"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/47_products.png" width="240" alt="Product carousel"> |

| Payment request | Hover actions (mouse) | |
| :---: | :---: | :---: |
| <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/48_payment.png" width="240" alt="Payment request with Pay and Decline"> | <img src="https://raw.githubusercontent.com/jacd007/chatx/main/doc/screenshots/49_hover_actions.png" width="240" alt="Reply, react and more buttons shown on hover"> |  |

## Features

- **Drop-in screen.** `ChatView` gives you a message list and input bar.
- **Any backend.** A plain `ChatController` holds the state. No streams or
  state-management package required.
- **Markdown.** Bold, italic, strike, code, quotes, lists, headings, links,
  tables and code blocks with syntax highlighting and a copy button.
- **AI chats.** Stream answers token by token (only the streaming bubble
  rebuilds), stop them, regenerate them, rate them with 👍/👎 and copy them.
- **AI transparency.** Collapsible reasoning ("Thought for 12s"), tool
  cards, numbered sources, versions of regenerated answers ("‹ 2/3 ›") and
  suggested prompts in the empty state.
- **Translation.** Translate any message with your own service and switch
  back to the original.
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
- **Location, events, contacts and stickers.** Map cards with live
  location, events with RSVP, contact cards and sticker packs in the picker.
- **Composer.** Attachment tray with captions, markdown formatting from the
  selection menu and Ctrl/Cmd+B, I, E, K, images from keyboards like Gboard.
- **Desktop and web.** Enter sends, ↑ edits your last message, Esc cancels,
  right-click opens the menu and hovering shows Reply, React and More.
- **Offline.** Connection banner and a queue that sends when the network
  comes back.
- **More content.** Video with thumbnail and duration, voice transcripts,
  shared checklists, product carousels, payment requests and a call log.
- **Teams.** Role badges, member list, profile sheet, media gallery
  (photos, files, links), unread mention jumps and jump to date.
- **Moderation.** Delete for everyone, edit history, scheduled messages,
  read-only channels, slow mode, report, block, saved messages and a word
  filter.
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
- **Accessible.** Screen reader labels, 48dp touch targets, contrast and text
  scaling to 200%, checked by automated tests. Reduced-motion support.
- **Five languages.** English, Spanish, Portuguese, French and German.
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
  - [AI answer controls](#ai-answer-controls)
  - [Reasoning, tools and sources](#reasoning-tools-and-sources)
  - [Answer versions](#answer-versions)
  - [Suggested prompts](#suggested-prompts)
  - [Translation](#translation)
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
  - [Location](#location)
  - [Events and RSVP](#events-and-rsvp)
  - [Contacts](#contacts)
  - [Stickers](#stickers)
  - [Delete for everyone and edit history](#delete-for-everyone-and-edit-history)
  - [Scheduled messages](#scheduled-messages)
  - [Channels and slow mode](#channels-and-slow-mode)
  - [Report, block and save](#report-block-and-save)
  - [Word filter](#word-filter)
  - [Attachments](#attachments)
  - [Formatting and keyboard](#formatting-and-keyboard)
  - [Offline queue](#offline-queue)
  - [Video](#video)
  - [Voice transcripts](#voice-transcripts)
  - [Checklists](#checklists)
  - [Products and payments](#products-and-payments)
  - [Call log](#call-log)
  - [Roles, members and profiles](#roles-members-and-profiles)
  - [Media gallery](#media-gallery)
  - [Unread mentions and jump to date](#unread-mentions-and-jump-to-date)
  - [Custom message types](#custom-message-types)
  - [Theming](#theming)
  - [Bubble shape](#bubble-shape)
  - [Builders](#builders)
  - [Localization](#localization)
- [Recipes](#recipes)
  - [Firebase Cloud Firestore](#firebase-cloud-firestore)
  - [Supabase](#supabase)
  - [WebSocket](#websocket)
  - [LLM streaming (server-sent events)](#llm-streaming-server-sent-events)
- [Testing your chat](#testing-your-chat)
- [Performance](#performance)
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
| `setMessages(messages, newConversation: true)` | Replaces everything. With `newConversation`, also clears the reply, edit, typing users, attachments and draft, for example when switching chats. |
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

### AI answer controls

Mark the assistant with `isBot: true`. Its answers then get a row of
actions: copy, 👍/👎 and regenerate (only on the newest answer). While an
answer streams, the send button becomes a stop button.

```dart
const assistant = ChatUser(id: 'bot', name: 'Assistant', isBot: true);

ChatView(
  // ...
  onStopGenerating: (message) {
    subscription.cancel();
    controller.completeStream(message.id);
  },
  onRegenerate: (message) {
    controller.update(message.copyWith(text: '', isStreaming: true));
    streamAnswer(message.id);
  },
  onFeedback: (message, feedback) {
    // feedback is ChatFeedback.positive, .negative or null (removed).
    controller.update(
      message.copyWith(feedback: feedback, clearFeedback: feedback == null),
    );
    api.rate(message.id, feedback);
  },
)
```

Code blocks are highlighted for Dart, JavaScript, TypeScript, Python, JSON,
SQL, Kotlin, Swift, Java, Go, Rust, shell and YAML, and have a "Copy code"
button. Tables use the GitHub syntax (see the
[Markdown reference](#markdown-reference)).

### Reasoning, tools and sources

Show what a model does before and while it answers. Update the message as
your API streams events:

```dart
// While the model thinks: an open "Thinking…" block.
controller.update(answer.copyWith(
  reasoning: ChatReasoning(text: thoughts, isActive: true),
));

// When it starts answering: the block collapses to "Thought for 12s".
controller.update(answer.copyWith(
  reasoning: ChatReasoning(text: thoughts, duration: elapsed),
  toolCalls: const [
    ChatToolCall(id: 'web', name: 'Searched the web', detail: '3 results'),
  ],
));

// At the end: numbered source chips under the answer.
controller.update(answer.copyWith(sources: const [
  ChatSource(title: 'Flutter docs', url: 'https://docs.flutter.dev'),
]));
```

A tool call shows a spinner while `status` is `ChatToolStatus.running`.
Source chips open the link through `onLinkTap`, or call `onSourceTap`.

### Answer versions

`ChatController.startRegeneration` keeps the current answer in
`TextMessage.versions` and clears the text for a new stream. The actions row
then shows "‹ 2/2 ›" to browse the versions; Copy copies the one on screen.

```dart
onRegenerate: (message) {
  controller.startRegeneration(message.id);
  streamAnswer(message.id); // appendText + completeStream
},
```

### Suggested prompts

Cards in the empty conversation. Tapping one sends its text through
`onSendMessage`. For follow-up suggestions after an answer, use
`TextMessage.quickReplies`.

```dart
ChatView(
  // ...
  suggestedPrompts: const [
    ChatPrompt(title: 'Plan a trip', subtitle: 'to Lisbon in spring',
        icon: Icons.flight_outlined),
    ChatPrompt(title: 'Explain', subtitle: 'how streaming works'),
  ],
)
```

### Translation

Give chatx a function that translates a message. The menu then offers
"Translate", and a label under the bubble switches between the translation
and the original. chatx keeps the translation in memory only.

```dart
ChatView(
  // ...
  onTranslate: (message) => myTranslator.translate(
    message.text,
    to: Localizations.localeOf(context).languageCode,
  ),
)
```

If the function throws, the bubble shows "Couldn't translate · Retry".

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

### Location

```dart
LocationMessage(
  id: 'loc1',
  author: ana,
  createdAt: DateTime.now(),
  latitude: 38.7223,
  longitude: -9.1393,
  title: 'Miradouro de Santa Luzia',
  address: 'Largo de Santa Luzia, Lisbon',
  mapImageUri: 'https://…/static-map.png', // optional
  liveUntil: DateTime.now().add(const Duration(hours: 1)), // live location
)
```

chatx has no maps dependency. It shows `mapImageUri` (loaded through
`imageProviderBuilder`), your own widget from `locationMapBuilder`, or a
drawn placeholder map. Live locations show a pulsing pin and "Live location ·
until …". Open a maps app in `onLocationTap`.

### Events and RSVP

```dart
EventMessage(
  id: 'e1',
  author: leo,
  createdAt: DateTime.now(),
  title: 'Rooftop meetup',
  startsAt: DateTime(2026, 11, 24, 19),
  endsAt: DateTime(2026, 11, 24, 22),
  location: 'Calle Mayor 12',
  rsvps: const {'ana': ChatRsvp.going, 'sam': ChatRsvp.maybe},
)

ChatView(
  // ...
  onRsvp: (event, rsvp) => controller.setRsvp(event.id, me.id, rsvp),
)
```

Tapping the selected answer again removes it (`rsvp` is `null`).

### Contacts

`ContactMessage` shows a card with Call, Email and Add contact buttons.
Buttons appear only when the data exists.

```dart
ChatView(
  // ...
  onContactAction: (contact, action) => switch (action) {
    ChatContactAction.call => launchUrl(Uri.parse('tel:${contact.phone}')),
    ChatContactAction.email => launchUrl(Uri.parse('mailto:${contact.email}')),
    ChatContactAction.save => saveToAddressBook(contact),
  },
)
```

### Stickers

Stickers come from your app: chatx renders them, it does not ship any.
`StickerMessage` is shown at 150 dp without a bubble. Add packs to the emoji
picker as extra tabs:

```dart
ChatView(
  // ...
  stickerPacks: const [
    ChatStickerPack(
      id: 'faces',
      name: 'Faces',
      stickers: [ChatSticker(id: 'smile', uri: 'asset:smile', label: 'Smile')],
    ),
  ],
  imageProviderBuilder: (uri) => uri.startsWith('asset:')
      ? AssetImage('assets/stickers/${uri.substring(6)}.png')
      : NetworkImage(uri),
  onSendSticker: (sticker) => controller.insert(
    StickerMessage(
      id: uuid(),
      author: me,
      createdAt: DateTime.now(),
      uri: sticker.uri,
      label: sticker.label,
    ),
  ),
)
```

Animated GIFs work the same way: `Image` plays them.

### Delete for everyone and edit history

`onDeleteForEveryone` adds "Delete for everyone" to the menu of your
messages. Mark the message as deleted to show a placeholder instead of the
content:

```dart
ChatView(
  // ...
  onDeleteForEveryone: (message) {
    controller.markDeleted(message.id);
    api.deleteForEveryone(message.id);
  },
)
```

`ChatController.editText` keeps the previous text in
`TextMessage.editHistory`. Tapping "edited" opens a sheet with every version.

### Scheduled messages

With `onScheduleMessage`, a long press on the send button opens quick
options (in 1 hour, tonight, tomorrow morning, pick a date and time):

```dart
ChatView(
  // ...
  onScheduleMessage: (text, at, replyTo) => controller.insert(
    TextMessage(
      id: uuid(),
      author: me,
      createdAt: DateTime.now(),
      text: text,
      scheduledFor: at,
    ),
  ),
  onSendScheduledNow: (message) => controller.update(
    message.copyWithMeta(clearScheduledFor: true),
  ),
)
```

Messages with `scheduledFor` are drawn faded with "Scheduled for …". Their
menu offers Send now, Edit and Delete. Your backend sends them at the right
time.

### Channels and slow mode

```dart
ChatView(
  // ...
  readOnly: !isAdmin, // hides the input, shows "Only admins can send messages"
  readOnlyMessage: 'Only moderators can post here', // optional
  slowMode: const Duration(seconds: 30), // one message every 30 seconds
)
```

In slow mode the input shows a countdown until the user can send again.
Enforce both rules on your server too.

### Report, block and save

Each callback adds an entry to the message menu:

```dart
ChatView(
  // ...
  onReportMessage: (message) => api.report(message.id),
  onBlockUser: (user) => api.block(user.id),
  onSaveMessage: (message, saved) => controller.toggleSaved(message.id),
)
```

Saved messages show a bookmark icon. Read them with
`controller.savedIds` or `controller.isSaved(id)`.

### Word filter

```dart
ChatView(
  // ...
  wordFilter: ChatWordFilter({'darn', 'heck'}), // "darn it" -> "d*** it"
)
```

Whole words only, case-insensitive. The filter changes what is shown, not
the message. Filter on the server as well for real moderation.

### Attachments

chatx has no file picker. Open yours from the attach button, add the files
to the tray, and send them with the caption the user types:

```dart
ChatView(
  // ...
  onAttach: () async {
    final files = await pickFiles(); // file_picker, image_picker…
    controller.addAttachments([
      for (final f in files)
        ChatAttachment(
          id: f.path,
          name: f.name,
          uri: f.path,
          kind: f.isImage ? ChatAttachmentKind.image : ChatAttachmentKind.file,
        ),
    ]);
  },
  onSendAttachments: (attachments, caption, replyTo) {
    upload(attachments, caption); // then insert ImageMessage / FileMessage
  },
)
```

Images from keyboards such as Gboard arrive in the tray with their `bytes`.
Esc empties the tray.

### Formatting and keyboard

Select text in the input to get Bold, Italic, Strikethrough, Code and Link
in the selection menu. On keyboards:

| Keys | Action |
| --- | --- |
| Enter | Send (web and desktop; mobile inserts a line) |
| Shift+Enter | New line |
| Ctrl/Cmd+B, I, E, K | Bold, italic, code, link |
| Ctrl/Cmd+Shift+X | Strikethrough |
| ↑ in an empty field | Edit your last message |
| Esc | Cancel the edit, the reply or the attachments |

With a mouse, right-click opens the message menu and hovering a message
shows Reply, React and More (`showHoverActions`).

### Offline queue

Insert messages with `MessageStatus.queued` while offline, show the state
with `connectionState`, and send the queue when the network is back:

```dart
ChatView(
  // ...
  connectionState: isOnline
      ? ChatConnectionState.online
      : ChatConnectionState.offline, // or .connecting
  onSendQueued: (messages) {
    for (final m in messages) api.send(m);
  },
)
```

Queued messages show a cloud icon. `controller.queuedMessages` lists them.

### Video

```dart
VideoMessage(
  id: 'v1',
  author: ana,
  createdAt: DateTime.now(),
  uri: 'https://…/clip.mp4',
  thumbnailUri: 'https://…/clip.jpg',
  duration: const Duration(minutes: 1, seconds: 12),
  width: 1920,
  height: 1080,
)
```

chatx shows the thumbnail, a play button and the duration. Play the video
in `onVideoTap`, for example with `video_player`.

### Voice transcripts

Set `VoiceMessage.transcript` to show the text under the waveform. With
`onTranscribe`, notes without a transcript get a "Transcribe" button:

```dart
onTranscribe: (voice) async {
  final text = await speechToText(voice.uri);
  controller.update(voice.copyWith(transcript: text));
},
```

### Checklists

```dart
ChecklistMessage(
  id: 'c1',
  author: bea,
  createdAt: DateTime.now(),
  title: 'Launch checklist',
  items: const [
    ChecklistItem(id: 'a', text: 'Freeze the API', doneBy: 'kai'),
    ChecklistItem(id: 'b', text: 'Ship to TestFlight'),
  ],
)

ChatView(
  // ...
  onChecklistToggle: (list, item) =>
      controller.toggleChecklistItem(list.id, item.id, me.id),
)
```

### Products and payments

`ProductMessage` shows one card, or a carousel for several products.
`PaymentMessage` shows a request (with Pay and Decline for the other
people) or a sent payment. chatx never handles money: prices and amounts are
strings your app formats.

```dart
ProductMessage(
  id: 'p1',
  author: shop,
  createdAt: DateTime.now(),
  products: const [
    ChatProduct(id: 'mug', title: 'Ocean mug', price: '€14.90',
        imageUri: 'https://…/mug.jpg', actionLabel: 'Add to cart'),
  ],
)

PaymentMessage(
  id: 'pay1',
  author: shop,
  createdAt: DateTime.now(),
  amount: '€38.90',
  note: 'Order #4821',
)

ChatView(
  // ...
  onProductTap: (message, product) => cart.add(product.id),
  onPaymentAction: (message, action) => action == ChatPaymentAction.pay
      ? checkout(message)
      : controller.update(
          message.copyWith(paymentStatus: ChatPaymentStatus.declined)),
)
```

### Call log

```dart
CallMessage(
  id: 'call1',
  author: bea,
  createdAt: DateTime.now(),
  kind: ChatCallKind.video,
  outcome: ChatCallOutcome.missed, // completed, missed or declined
)
```

Completed calls show their `duration`. `onCallBack` adds a call button.

### Roles, members and profiles

Give users a `role` (`ChatRole.owner`, `admin` or `moderator`) to show a
badge next to their name. Show the members and a profile with ready-made
sheets:

```dart
ChatHeader(
  user: group,
  memberCount: members.length,
  onTap: () => ChatMemberList.show(
    context,
    members: members, // sorted by role, then name
    onlineIds: online,
    onTap: (user) => ChatUserProfile.show(
      context,
      user: user,
      subtitle: 'online',
      actions: [
        ChatProfileAction(icon: Icons.call_outlined, label: 'Call',
            onPressed: () => call(user)),
      ],
    ),
  ),
)
```

Open the same profile from `ChatView.onAvatarTap`.

### Media gallery

```dart
IconButton(
  icon: const Icon(Icons.perm_media_outlined),
  onPressed: () => ChatMediaGallery.show(context, controller: controller),
)
```

Three tabs: photos and videos, files, and links (only those allowed by the
link policy). Tapping an item jumps to its message.

### Unread mentions and jump to date

When messages that mention the current user (`@Name`) arrive while the
user reads older messages, or are after `firstUnreadMessageId`, an "@"
button with a counter appears above the scroll button. Each tap jumps to
the next mention.

Tap a date separator or the floating date to pick a day and jump to it.
From code, call `controller.scrollToDate(date)`.

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

chatx ships English, Spanish, Portuguese, French and German strings and picks
them from the app locale. Emoji search also understands Spanish words, with
or without accents (`corazon`, `cumpleaños`).
Dates and times use your app's `MaterialLocalizations`, so add
`flutter_localizations` to get them in every language:

```dart
MaterialApp(
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  supportedLocales: const [
    Locale('en'),
    Locale('es'),
    Locale('pt'),
    Locale('fr'),
    Locale('de'),
  ],
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

## Recipes

Complete integrations with popular backends. The packages named here belong
to your app, not to chatx. Each recipe maps backend data to chatx messages
in one place, so the rest of your UI code stays the same.

### Firebase Cloud Firestore

```dart
// pubspec.yaml of your app: cloud_firestore
final messages = FirebaseFirestore.instance
    .collection('rooms').doc(roomId).collection('messages');

ChatMessage fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data()!;
  return TextMessage(
    id: doc.id,
    author: ChatUser(id: data['authorId'], name: data['authorName']),
    createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    text: data['text'],
    status: MessageStatus.sent,
  );
}

// Live updates: newest 50 messages.
final subscription = messages
    .orderBy('createdAt', descending: true)
    .limit(50)
    .snapshots()
    .listen((snapshot) {
  for (final change in snapshot.docChanges) {
    switch (change.type) {
      case DocumentChangeType.added:
      case DocumentChangeType.modified:
        controller.upsert(fromDoc(change.doc));
      case DocumentChangeType.removed:
        controller.remove(change.doc.id);
    }
  }
});

// Sending: optimistic insert, then the snapshot confirms it.
Future<void> send(String text, ChatMessage? replyTo) async {
  final doc = messages.doc(); // ID known before the write
  controller.insert(TextMessage(
    id: doc.id,
    author: me,
    createdAt: DateTime.now(),
    text: text,
    replyToId: replyTo?.id,
    status: MessageStatus.sending,
  ));
  try {
    await doc.set({
      'authorId': me.id,
      'authorName': me.name,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  } catch (_) {
    controller.updateStatus(doc.id, MessageStatus.failed);
  }
}
```

Load older pages in `onLoadMore` with `startAfterDocument` and
`controller.insertAll`. Return `false` when a page comes back empty.

### Supabase

```dart
// pubspec.yaml of your app: supabase_flutter
final db = Supabase.instance.client;

ChatMessage fromRow(Map<String, dynamic> row) => TextMessage(
      id: row['id'],
      author: ChatUser(id: row['author_id'], name: row['author_name']),
      createdAt: DateTime.parse(row['created_at']),
      text: row['text'],
      status: MessageStatus.sent,
    );

// Initial page.
final rows = await db
    .from('messages')
    .select()
    .eq('room_id', roomId)
    .order('created_at', ascending: false)
    .limit(50);
controller.setMessages(rows.map(fromRow));

// Realtime.
final channel = db
    .channel('room:$roomId')
    .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'messages',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'room_id',
        value: roomId,
      ),
      callback: (payload) => switch (payload.eventType) {
        PostgresChangeEvent.delete =>
          controller.remove(payload.oldRecord['id'] as String),
        _ => controller.upsert(fromRow(payload.newRecord)),
      },
    )
    .subscribe();
```

Call `channel.unsubscribe()` and `controller.dispose()` when the screen
closes.

### WebSocket

```dart
// pubspec.yaml of your app: web_socket_channel
final socket = WebSocketChannel.connect(Uri.parse('wss://chat.example.com'));

socket.stream.listen((raw) {
  final event = jsonDecode(raw as String) as Map<String, dynamic>;
  switch (event['type']) {
    case 'message':
      controller.upsert(TextMessage(
        id: event['id'],
        author: ChatUser(id: event['from'], name: event['name']),
        createdAt: DateTime.parse(event['at']),
        text: event['text'],
        status: MessageStatus.sent,
      ));
    case 'typing':
      controller.setTyping(
        ChatUser(id: event['from'], name: event['name']),
        isTyping: event['active'] as bool,
      );
    case 'read':
      controller.updateStatus(event['id'], MessageStatus.read);
  }
});

ChatView(
  controller: controller,
  currentUser: me,
  onTypingChanged: (typing) => socket.sink.add(
    jsonEncode({'type': 'typing', 'active': typing}),
  ),
  onSendMessage: (text, replyTo) {
    final id = uuid();
    controller.insert(TextMessage(
      id: id,
      author: me,
      createdAt: DateTime.now(),
      text: text,
      status: MessageStatus.sending,
    ));
    socket.sink.add(jsonEncode({'type': 'message', 'id': id, 'text': text}));
  },
)
```

### LLM streaming (server-sent events)

Most LLM APIs stream tokens as server-sent events. Decode the lines and
append each token to the answer:

```dart
// pubspec.yaml of your app: http
Future<void> ask(String prompt) async {
  final id = uuid();
  controller.insert(TextMessage(
    id: id,
    author: assistant, // ChatUser(..., isBot: true)
    createdAt: DateTime.now(),
    text: '',
    isStreaming: true,
  ));

  final request = http.Request('POST', Uri.parse('https://api.example.com/chat'))
    ..headers['content-type'] = 'application/json'
    ..body = jsonEncode({'prompt': prompt, 'stream': true});
  final response = await http.Client().send(request);

  await for (final line in response.stream
      .transform(utf8.decoder)
      .transform(const LineSplitter())) {
    if (!line.startsWith('data: ')) continue;
    final data = line.substring(6);
    if (data == '[DONE]') break;
    final token = jsonDecode(data)['token'] as String? ?? '';
    controller.appendText(id, token);
  }
  controller.completeStream(id);
}
```

Keep API keys on your server. Call your own endpoint from the app, never
the LLM provider directly.

## Testing your chat

Every interactive widget has a stable key (see
[Accessibility](#accessibility)), so widget tests stay short and do not
depend on texts or layout:

```dart
testWidgets('sends a message', (tester) async {
  final controller = ChatController();
  final sent = <String>[];
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: ChatView(
        controller: controller,
        currentUser: const ChatUser(id: 'me'),
        onSendMessage: (text, _) => sent.add(text),
      ),
    ),
  ));

  await tester.enterText(find.byKey(const Key('chatx_input_field')), 'Hi');
  await tester.pump();
  await tester.tap(find.byKey(const Key('chatx_send_button')));

  expect(sent, ['Hi']);
});

testWidgets('shows incoming messages', (tester) async {
  final controller = ChatController(messages: [
    TextMessage(
      id: 'm1',
      author: const ChatUser(id: 'ana', name: 'Ana'),
      createdAt: DateTime.now(),
      text: 'Hello **there**',
    ),
  ]);
  // ... pump ChatView as above
  expect(find.byKey(const Key('chatx_bubble_m1')), findsOneWidget);
  expect(find.text('Hello there', findRichText: true), findsOneWidget);
});
```

The same keys work in integration tests, Patrol and Appium (they become
accessibility identifiers through `Semantics`).

Test the `ChatController` without widgets: it is a plain `ChangeNotifier`.

## Performance

chatx is built for long conversations and fast streams:

- **One bubble per update.** `update`, `updateStatus` and `appendText`
  rebuild only the affected bubble through `ChatController.watch`, not the
  list.
- **Anchored list.** New messages and loaded history do not move the message
  the user is reading.
- **Cheap appends.** Adding a message costs the same with 100 or 10,000
  messages in the history (checked by `test/controller/perf_test.dart`).
- **Measured.** In profile mode on macOS, scrolling 10,000 messages averages
  2.4 ms per frame build with no missed frames
  (`example/integration_test/perf_test.dart`).
- **Images.** Thumbnails are decoded at their display size
  (`ResizeImage`), not at full resolution.
- **Markdown cache.** Parsed messages are cached, so scrolling back does not
  parse again.

Tips for your app:

- Load history in pages with `onLoadMore` instead of passing every message
  at once.
- Use `appendText` for streams; do not replace the whole message for each
  token.
- Keep the `ChatController` outside `build` (for example in `State`, a
  provider or a bloc) so it is not recreated.

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
| `\| a \| b \|` + `\|:--\|--:\|` + rows | table, with column alignment |
| `\*` | a literal `*` |

Rules that keep chats readable: `snake_case` words stay intact, single line
breaks are kept, and `#hashtags` are not headings. Turn markdown off with
`enableMarkdown: false`; links are still detected.

Use `ChatText` to render the same markdown anywhere in your app.

## Accessibility

- Bubbles announce the author and time, and status icons have labels.
- The typing indicator is a live region.
- Interactive elements are at least 48×48 dp, including reaction chips and
  RSVP, contact and bot buttons.
- Automated tests check touch targets, labels and text contrast (WCAG AA) at
  normal and 200% text size.
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
  `chatx_emoji_search`, `chatx_react_more`, `chatx_header`,
  `chatx_stop_button`, `chatx_ai_copy_<id>`, `chatx_ai_good_<id>`,
  `chatx_ai_bad_<id>`, `chatx_ai_regenerate_<id>`, `chatx_copy_code`,
  `chatx_translation_toggle`, `chatx_rsvp_<id>_<going|maybe|notGoing>`,
  `chatx_contact_<id>_<call|email|save>`, `chatx_sticker_pack_<id>`,
  `chatx_sticker_<id>`, `chatx_sticker_message_<id>`, `chatx_deleted`,
  `chatx_edited_<id>`, `chatx_edit_history`, `chatx_schedule_sheet`,
  `chatx_scheduled`, `chatx_read_only`, `chatx_saved_icon`,
  `chatx_reasoning_<id>`, `chatx_tool_<id>`, `chatx_source_<id>_<index>`,
  `chatx_versions_<id>`, `chatx_version_previous_<id>`,
  `chatx_version_next_<id>`, `chatx_prompt_<index>`, `chatx_video_<id>`,
  `chatx_transcribe_<id>`, `chatx_transcript_<id>`,
  `chatx_check_<id>_<item>`, `chatx_products_<id>`,
  `chatx_product_<id>_<product>`, `chatx_pay_<id>`, `chatx_decline_<id>`,
  `chatx_call_back_<id>`, `chatx_role_<role>`, `chatx_attach_button`,
  `chatx_attachment_tray`, `chatx_remove_attachment_<id>`,
  `chatx_connection_banner`, `chatx_mentions_button`, `chatx_hover_<id>`,
  `chatx_media_gallery`, `chatx_member_list`, `chatx_member_<id>` and
  `chatx_user_profile`.

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

**Does it work with go_router, auto_route or Navigator 2.0?** Yes. `ChatView`
is a normal widget; put it in any page.

**How do I keep the conversation when the user leaves the screen?** Keep the
`ChatController` alive longer than the page (for example in a provider), or
save `controller.messages` and `controller.draft` and restore them.

**Can I use my own bubble design?** Yes. Change colors and shapes with
`ChatTheme`, or replace bubbles, avatars, input and separators with
builders. See [Builders](#builders).

**Can I show messages from several authors on my side?** `currentUser`
decides which messages are outgoing. Everything else is shown on the left
with avatar and name.

**How do I right-align messages in an RTL language?** Nothing to do: chatx
mirrors its layout automatically in right-to-left locales.

**Which Flutter versions are supported?** Flutter 3.27 and newer, on Android,
iOS, web, macOS, Windows and Linux. CI tests the oldest supported version
and the latest stable.

**Where do I report a bug or ask for a feature?** Open an issue at
https://github.com/jacd007/chatx/issues. For security problems, see
[SECURITY.md](SECURITY.md).

## Example app

The [`example`](example) folder contains demos for every feature: basic chat
(replies, reactions, popup menu, editing), media and files (images, voice
notes, links, spoilers, location, contact, stickers), community (survey,
poll, event, thread, read receipts, translation, edit history, scheduled and
deleted messages, report, block, save, word filter), announcements
(read-only channel), workspace (roles, members, profiles, gallery,
checklist, calls, mentions, offline queue), support bot (buttons, quick
replies, products, payment, slow mode), AI streaming (prompts, reasoning,
tools, sources, versions, stop, rating, code, tables), bubble styles, custom
look and infinite history. Media and files also shows video, transcripts and
the attachment tray. Its
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
