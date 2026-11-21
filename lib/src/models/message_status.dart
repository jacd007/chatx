/// Delivery state of a message sent by the current user.
///
/// chatx only renders the status. Your backend integration decides when a
/// message moves from one state to the next, typically through
/// `ChatController.updateStatus`.
enum MessageStatus {
  /// The message is shown optimistically and is still being sent.
  sending,

  /// The server accepted the message.
  sent,

  /// The message reached at least one recipient device.
  delivered,

  /// At least one recipient read the message.
  read,

  /// Sending failed. The UI shows a retry affordance.
  failed,
}
