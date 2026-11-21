/// Backend-agnostic, zero-dependency chat UI for Flutter.
///
/// chatx renders conversations; your app owns the data. Messages live in a
/// [ChatController] and [ChatView] draws them, with the input bar, menus,
/// reactions and everything else.
///
/// ```dart
/// final controller = ChatController();
///
/// ChatView(
///   controller: controller,
///   currentUser: const ChatUser(id: 'me', name: 'Me'),
///   onSend: (outgoing) {
///     if (outgoing case OutgoingText(:final text, :final replyTo)) {
///       controller.insert(TextMessage(
///         id: uuid(),
///         author: const ChatUser(id: 'me', name: 'Me'),
///         createdAt: DateTime.now(),
///         text: text,
///         replyToId: replyTo?.id,
///         status: MessageStatus.sending,
///       ));
///       myBackend.send(text, replyTo);
///     }
///   },
/// )
/// ```
///
/// ## Main pieces
///
/// * [ChatController]: the messages, typing users, replies, edits,
///   selection, pins and attachments. Update it from your backend.
/// * [ChatView]: the complete conversation screen. Everything the user
///   sends reaches `ChatView.onSend` as a [ChatOutgoing].
/// * [ChatMessage]: a sealed hierarchy. [TextMessage] for text and AI
///   answers; [ImageMessage], [VideoMessage], [FileMessage] and
///   [VoiceMessage] for media; [PollMessage], [SurveyMessage],
///   [EventMessage], [ChecklistMessage], [ProductMessage],
///   [PaymentMessage], [LocationMessage], [ContactMessage], [CallMessage],
///   [CountdownMessage] and [StickerMessage] for rich content;
///   [SystemMessage] for notices; [CustomMessage] for your own types.
/// * [ChatTheme]: colors, text styles and bubble shapes, derived from your
///   Material theme by default.
/// * [ChatLocalizations]: every string, in English, Spanish, Portuguese,
///   French and German.
/// * Standalone widgets: [ChatInput], [ChatHeader], [ChatSearchBar],
///   [ChatEmojiPicker], [ChatText], [ChatMediaGallery], [ChatMemberList] and
///   [ChatUserProfile].
///
/// The README has a guide for every feature, recipes for Firebase,
/// Supabase, WebSockets and LLM streaming, and a testing guide:
/// https://pub.dev/packages/chatx
library;

export 'src/controller/chat_controller.dart';
export 'src/controller/chat_search_controller.dart';
export 'src/emoji/chat_emoji_picker.dart';
export 'src/l10n/chat_localizations.dart';
export 'src/markdown/chat_link_policy.dart';
export 'src/markdown/chat_text.dart';
export 'src/models/chat_message.dart';
export 'src/models/chat_outgoing.dart';
export 'src/models/chat_reaction.dart';
export 'src/models/chat_user.dart';
export 'src/models/message_status.dart';
export 'src/models/voice_playback.dart';
export 'src/theme/chat_bubble_border.dart';
export 'src/theme/chat_theme.dart';
export 'src/widgets/chat_avatar.dart';
export 'src/widgets/chat_builders.dart';
export 'src/widgets/chat_header.dart';
export 'src/widgets/chat_input.dart';
export 'src/widgets/chat_media_gallery.dart';
export 'src/widgets/chat_people.dart';
export 'src/widgets/chat_search_bar.dart';
export 'src/widgets/chat_view.dart';
export 'src/widgets/chat_view_options.dart';
export 'src/widgets/message_status_icon.dart';
export 'src/widgets/typing_indicator.dart';

// The library comment links to exported classes. dartdoc resolves them;
// the analyzer only sees imports.
// ignore_for_file: comment_references
