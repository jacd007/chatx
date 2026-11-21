# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project uses
[Semantic Versioning](https://semver.org/).

## 0.1.0

Initial release.

- `ChatView`: complete conversation screen with message list and input bar.
- `ChatController`: sorted message store with per-message updates, so status
  changes and streamed text rebuild only one bubble.
- Message types: `TextMessage`, `SystemMessage` and `CustomMessage`.
- Built-in markdown subset with safe, policy-filtered links (`ChatLinkPolicy`).
- Streaming messages with `appendText` and `completeStream`.
- Delivery status (`sending`, `sent`, `delivered`, `read`, `failed`) with retry.
- Typing indicator, day separators, author grouping and avatars.
- Infinite history with `onLoadMore`, including error and retry state.
- Scroll-to-bottom button with unread counter.
- Long-press actions menu with `ChatMessageAction`.
- Theming through `ChatTheme`, derived from Material 3 by default, with
  automatic dark mode.
- Builders to replace bubbles, avatars, input, separators, typing indicator,
  scroll button, loader and empty state.
- English and Spanish strings, overridable through `ChatLocalizations`.
- Works in apps built on `material_ui` through `MaterialUiCompatibilityBridge`.
- Zero dependencies besides the Flutter SDK. Supports Android, iOS, web,
  macOS, Windows and Linux.
