import 'package:flutter/foundation.dart';

/// What your audio player is doing, reported to `ChatView.voicePlayback`.
///
/// chatx draws play buttons and progress for voice notes but never plays
/// audio. Keep a `ValueNotifier<ChatVoicePlayback?>` updated from your player
/// and pass it to the view.
@immutable
class ChatVoicePlayback {
  /// Creates a playback state.
  const ChatVoicePlayback({
    required this.messageId,
    required this.position,
    required this.isPlaying,
  });

  /// The voice message being played or paused.
  final String messageId;

  /// Current position in the recording.
  final Duration position;

  /// Whether audio is playing right now.
  final bool isPlaying;

  @override
  bool operator ==(Object other) =>
      other is ChatVoicePlayback &&
      other.messageId == messageId &&
      other.position == position &&
      other.isPlaying == isPlaying;

  @override
  int get hashCode => Object.hash(messageId, position, isPlaying);
}
