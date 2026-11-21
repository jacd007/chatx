# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/).

## 0.2.1 - 2026-11-21

### Changed

- Reactions under a bubble are grouped in one pill with the three most used
  emoji and the total. Tapping it opens a sheet with every reaction, where
  the user adds or removes theirs.
- The message menu keeps the bubble that opened it in view. The chat behind
  blurs and the bubble stays sharp on top. A popup sits next to the bubble
  with a pointer toward it, and the bubble moves when the menu fits neither
  above nor below. With the bottom sheet, the bubble rises above the sheet.
  Bubbles taller than 40% of the screen stay in place and the menu shows a
  preview of the message instead.

### Added

- `ChatLocalizations.reactions`, the title of the reactions sheet.
- Example app: "All features", one conversation with every feature on, and
  a catalog of 60 small working demos, one per feature.

### Fixed

- Thread summaries and countdowns no longer overflow on narrow screens or
  with large text.

## 0.2.0 - 2026-11-21

Architecture review before 1.0. This release breaks the API on purpose;
see "Migrating from 0.1" below.

### Breaking changes

- `ChatView.onSend` replaces `onSendMessage`, `onEditMessage`,
  `onSendAttachments`, `onSendSticker`, `onScheduleMessage` and
  `onSendScheduledNow`. It receives a sealed `ChatOutgoing`: `OutgoingText`
  (text, prompts, quick replies and scheduled messages), `OutgoingAttachments`,
  `OutgoingSticker`, `OutgoingEdit` and `OutgoingScheduledNow`.
  `sendFeatures` turns on the UI of each feature beyond plain text.
- `ChatView` options moved into five groups: `builders` (`ChatBuilders`), `ai`
  (`ChatAiOptions`), `moderation` (`ChatModerationOptions`), `media`
  (`ChatMediaOptions`) and `contentCallbacks` (`ChatContentCallbacks`).
- The draft, reply, edit and attachments moved from `ChatController` to
  `ChatController.composer` (`ChatComposerController`).
- The `copyWith` of each message type no longer takes the shared fields
  (`status`, `replyToId`, `reactions`, `thread`, `receipts`, `forwardedFrom`,
  `expiresAt`, `deletedAt`, `scheduledFor`, `metadata`). Pass a `meta`, or use
  `copyWithMeta` or `withMeta`. `copyWithMeta` now returns a `ChatMessage`.
- `TextMessage.versions` is a `List<ChatAnswerVersion>` instead of a
  `List<String>`.
- `ChatRole` is defined in `chat_user.dart`. Code that imports
  `package:chatx/chatx.dart` is not affected.
- Removed `ChatSendCallback`, `ChatEditCallback`, `ChatScheduleCallback` and
  `ChatAttachmentsCallback`.

### Added

- `ChatMessageMeta`: the shared fields of a message as one value
  (`message.meta`), with `withMeta` to apply it and keep the message type.
- `ChatBuilders.customMessageBuilders`: a builder per `CustomMessage.type`.
  The set of built-in message types is fixed from 1.0, so new kinds of
  content arrive as custom messages and your `switch`es keep compiling.
- `ChatAnswerVersion`: earlier answers keep their reasoning, tool calls and
  sources, and are shown with them.
- Partial languages: every `ChatLocalizations` string defaults to English,
  so a custom language only sets what it translates.
- `ChatController.setMessages(messages, newConversation: true)` also clears
  the reply, edit, typing users, attachments and draft.
- `ChatController.contentChanges` notifies when a message changes without a
  structural change.
- `clearReplyToId`, `clearForwardedFrom` and `clearMetadata` flags.

### Fixed

- `setMessages` cancels a reply or edit whose message is gone, and the input
  shows a draft changed from outside.
- Reply quotes and the pinned banner follow edits and deletion of the
  original message.
- Calling the controller after `dispose` (for example from a late backend
  callback) no longer throws.
- `onSendQueued` fires once per reconnection when several views share a
  controller.
- Search results follow edited and streamed messages.
- A regenerated answer no longer inherits the reasoning of the previous one.
- Stickers sent while replying carry the message being replied to.

### Performance

- Messages are indexed by ID: lookups are O(1) and positions are found by
  binary search instead of scanning the conversation.
- Pages of history are merged in one pass instead of one insert per message.
- Search parses the markdown of each message version once.
- Rebuilding the parent of `ChatView` no longer walks every message.

### Migrating from 0.1

```dart
// 0.1
ChatView(
  onSendMessage: (text, replyTo) => send(text, replyTo),
  onEditMessage: (message, text) => edit(message, text),
  onRegenerate: regenerate,
  readOnly: !isAdmin,
  imageProviderBuilder: provider,
);
controller.startReply(message);
message.copyWith(status: MessageStatus.sent);

// 0.2
ChatView(
  onSend: (outgoing) => switch (outgoing) {
    OutgoingText(:final text, :final replyTo) => send(text, replyTo),
    OutgoingEdit(:final message, :final text) => edit(message, text),
    _ => null,
  },
  sendFeatures: const {ChatSendFeature.edit},
  ai: ChatAiOptions(onRegenerate: regenerate),
  moderation: ChatModerationOptions(readOnly: !isAdmin),
  builders: ChatBuilders(imageProviderBuilder: provider),
);
controller.composer.startReply(message);
message.copyWithMeta(status: MessageStatus.sent);
```

## 0.1.1 - 2026-11-21

Documentation only. No code changes.

- Recipes for Firebase Cloud Firestore, Supabase, WebSockets and LLM
  streaming with server-sent events.
- New "Testing your chat" and "Performance" sections.
- More FAQ answers.
- Library overview in the API reference listing the main classes.

## 0.1.0 - 2026-11-21

Initial release.

- `ChatView`: complete conversation screen with message list and input bar.
- `ChatController`: sorted message store with per-message updates, so status
  changes and streamed text rebuild only one bubble.
- Message types: `TextMessage`, `SystemMessage` and `CustomMessage`.
- Built-in markdown subset with safe, policy-filtered links (`ChatLinkPolicy`).
- Streaming messages with `appendText` and `completeStream`.
- Delivery status (`sending`, `sent`, `delivered`, `read`, `failed`) with retry.
- Replies: swipe a bubble to reply (`ChatSwipeAction`), reply banner above the
  input, quotes inside bubbles that jump to the original message.
- Message menu as a bottom sheet or popup (`ChatMessageMenuStyle`), opened by
  long press or tap (`ChatMessageMenuTrigger`), with built-in Reply, Copy,
  Edit and Delete entries.
- Emoji reactions (`ChatReaction`, `ChatController.toggleReaction`) with
  quick picker and tappable chips.
- Editing (`onEditMessage`, `ChatController.editText`) with an edit banner.
- Bubble shape with tail (`ChatBubbleTail`, `ChatBubbleBorder`), elevation and
  outline.
- "New messages" separator (`firstUnreadMessageId`) and large emoji-only
  messages.
- `ImageMessage` with grid layout, full-screen zoomable viewer, upload
  progress and spoiler blur; `imageProviderBuilder` for custom loading.
- `FileMessage` with type icons, size and upload progress.
- `VoiceMessage` with waveform and playback driven by `ChatVoicePlayback`,
  and press-and-hold recording with slide to cancel in `ChatInput`.
- `PollMessage` with animated results and `ChatController.votePoll`.
- `CountdownMessage` for announcements with a live countdown.
- Link preview cards (`ChatLinkPreview`) and inline `||spoilers||`.
- Mentions with suggestions in the input (`mentionableUsers`).
- Search (`ChatSearchController`, `ChatSearchBar`) with highlighted matches.
- Multi-selection with a selection bar (`ChatSelectionAction`).
- Pinned messages banner (`ChatController.pin`) and a floating date while
  scrolling.
- `ChatController.scrollToMessage`.
- `SurveyMessage`: multi-question surveys (choice, rating, NPS, text)
  answered step by step, with `onSurveySubmit` and `recordSurveyResponse`.
- Bot `buttons` and `quickReplies` on `TextMessage`.
- Threads (`ChatThreadSummary`, `onThreadTap`, `ChatView.threadRoot`).
- Read receipts (`ChatReadReceipt`) with "Seen by" and a message info sheet.
- Forwarding (`forwardedFrom`, `onForwardMessages`).
- Disappearing messages (`expiresAt`).
- Drafts kept by `ChatController.draft`.
- `ChatHeader` with presence, last seen, members and typing.
- `ChatEmojiPicker` in the input and for reactions.
- Typing indicator, day separators, author grouping and avatars.
- Infinite history with `onLoadMore`, including error and retry state.
- Scroll-to-bottom button with unread counter.
- Long-press actions menu with `ChatMessageAction`.
- Theming through `ChatTheme`, derived from Material 3 by default, with
  automatic dark mode.
- Builders to replace bubbles, avatars, input, separators, typing indicator,
  scroll button, loader and empty state.
- AI controls: `ChatUser.isBot`, copy, 👍/👎 (`onFeedback`), regenerate,
  stop button while streaming (`onStopGenerating`).
- Syntax-highlighted code blocks with a copy button, and markdown tables.
- Message translation (`onTranslate`) with a toggle to the original.
- `LocationMessage` (live location), `EventMessage` with RSVP
  (`ChatController.setRsvp`), `ContactMessage` and `StickerMessage` with
  sticker packs in the emoji picker.
- Delete for everyone (`markDeleted`), edit history (`editHistory`) and
  scheduled messages (`scheduledFor`, long press on send).
- Read-only channels, slow mode, report, block, saved messages
  (`toggleSaved`) and `ChatWordFilter`.
- Strings in English, Spanish, Portuguese, French and German, overridable
  through `ChatLocalizations`. Emoji search in English and Spanish.
- AI transparency: `ChatReasoning`, `ChatToolCall`, `ChatSource`, answer
  versions (`ChatController.startRegeneration`) and `suggestedPrompts`.
- Attachment tray (`onAttach`, `onSendAttachments`,
  `ChatController.addAttachments`), keyboard images, markdown formatting
  from the selection menu and shortcuts, ↑ to edit, Esc to cancel.
- Hover actions and right-click menu for mouse users.
- Offline support: `connectionState`, `MessageStatus.queued` and
  `onSendQueued`.
- `VideoMessage`, voice transcripts (`onTranscribe`), `ChecklistMessage`,
  `ProductMessage`, `PaymentMessage` and `CallMessage`.
- `ChatUser.role` badges, `ChatMemberList`, `ChatUserProfile` and
  `ChatMediaGallery`.
- Unread mention jumps and jump to date (`ChatController.scrollToDate`).
- Accessibility guideline tests at 1x and 2x text size.
- Works in apps built on `material_ui` through `MaterialUiCompatibilityBridge`.
- Zero dependencies besides the Flutter SDK. Supports Android, iOS, web,
  macOS, Windows and Linux.
