# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/).

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
