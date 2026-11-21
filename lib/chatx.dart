/// Backend-agnostic, zero-dependency chat UI for Flutter.
///
/// Start with a `ChatController` that holds the messages and a `ChatView`
/// that renders them:
///
/// ```dart
/// ChatView(
///   controller: controller,
///   currentUser: const ChatUser(id: 'me'),
///   onSendMessage: (text, replyTo) => myBackend.send(text, replyTo),
/// )
/// ```
///
/// See the package README for guides on theming, builders, pagination and
/// streaming.
library;

export 'src/controller/chat_controller.dart';
export 'src/controller/chat_search_controller.dart';
export 'src/l10n/chat_localizations.dart';
export 'src/markdown/chat_link_policy.dart';
export 'src/markdown/chat_text.dart';
export 'src/models/chat_message.dart';
export 'src/models/chat_reaction.dart';
export 'src/models/chat_user.dart';
export 'src/models/message_status.dart';
export 'src/models/voice_playback.dart';
export 'src/theme/chat_bubble_border.dart';
export 'src/theme/chat_theme.dart';
export 'src/widgets/chat_avatar.dart';
export 'src/widgets/chat_builders.dart';
export 'src/widgets/chat_input.dart';
export 'src/widgets/chat_search_bar.dart';
export 'src/widgets/chat_view.dart';
export 'src/widgets/message_status_icon.dart';
export 'src/widgets/typing_indicator.dart';
