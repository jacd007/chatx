import '../models/chat_user.dart';
import 'chat_text_sanitizer.dart';

/// How chatx shows user names.
extension ChatUserDisplayName on ChatUser {
  /// [ChatUser.name] through [ChatTextSanitizer.strip], or `null` when there
  /// is no name or nothing visible is left.
  String? get displayName => sanitizeName(name);
}

/// [name] through [ChatTextSanitizer.strip], or `null` when there is no name
/// or nothing visible is left.
String? sanitizeName(String? name) {
  if (name == null) return null;
  final stripped = ChatTextSanitizer.strip(name);
  return stripped.isEmpty && name.isNotEmpty ? null : stripped;
}
