import '../chat_scope.dart';
import '../l10n/chat_localizations.dart';
import '../material.dart';
import '../models/chat_user.dart';
import '../theme/chat_theme.dart';
import 'chat_avatar.dart';

/// Small badge with the role of a user: owner, admin or moderator.
class ChatRoleBadge extends StatelessWidget {
  /// Creates a role badge.
  const ChatRoleBadge({super.key, required this.role});

  /// The role to show.
  final ChatRole role;

  @override
  Widget build(BuildContext context) {
    final l10n = ChatLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (label, background, foreground) = switch (role) {
      ChatRole.owner => (
          l10n.roleOwner,
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
        ),
      ChatRole.admin => (
          l10n.roleAdmin,
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
        ),
      ChatRole.moderator => (
          l10n.roleModerator,
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
        ),
    };
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        key: Key('chatx_role_${role.name}'),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}

/// An action button of [ChatUserProfile].
@immutable
class ChatProfileAction {
  /// Creates a profile action.
  const ChatProfileAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
  });

  /// Icon of the button.
  final IconData icon;

  /// Label under the icon.
  final String label;

  /// Called when the button is tapped. The sheet closes first.
  final VoidCallback onPressed;

  /// Whether the action is shown in the error color, for example "Block".
  final bool isDestructive;
}

/// Profile of a user: large avatar, name, role, status and actions.
///
/// `ChatView` shows it in a bottom sheet when an avatar is tapped and
/// `onAvatarTap` is not set. Open it yourself with [show].
class ChatUserProfile extends StatelessWidget {
  /// Creates a user profile.
  const ChatUserProfile({
    super.key,
    required this.user,
    this.subtitle,
    this.actions = const [],
  });

  /// The user.
  final ChatUser user;

  /// Line under the name, for example "online" or "last seen 5 min ago".
  final String? subtitle;

  /// Buttons under the name.
  final List<ChatProfileAction> actions;

  /// Shows the profile of [user] in a bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required ChatUser user,
    String? subtitle,
    List<ChatProfileAction> actions = const [],
  }) {
    final theme = ChatThemeData.of(context);
    final l10n = ChatLocalizations.of(context);
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) => ChatScope(
        theme: theme,
        localizations: l10n,
        child: ChatUserProfile(
          user: user,
          subtitle: subtitle,
          actions: [
            for (final action in actions)
              ChatProfileAction(
                icon: action.icon,
                label: action.label,
                isDestructive: action.isDestructive,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  action.onPressed();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final role = user.role;
    return SafeArea(
      child: SingleChildScrollView(
        key: const Key('chatx_user_profile'),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ChatAvatar(user: user, size: 88),
            const SizedBox(height: 12),
            Text(
              user.name ?? user.id,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (role != null) ...[
              const SizedBox(height: 6),
              ChatRoleBadge(role: role),
            ],
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final action in actions)
                    Expanded(
                      child: TextButton(
                        onPressed: action.onPressed,
                        style: TextButton.styleFrom(
                          foregroundColor: action.isDestructive
                              ? scheme.error
                              : scheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(action.icon),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(action.label, maxLines: 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// List of the members of a group, with roles and presence.
///
/// Owners come first, then admins, moderators and everyone else, each group
/// sorted by name.
class ChatMemberList extends StatelessWidget {
  /// Creates a member list.
  const ChatMemberList({
    super.key,
    required this.members,
    this.onlineIds = const {},
    this.onTap,
    this.shrinkWrap = false,
  });

  /// The members.
  final List<ChatUser> members;

  /// IDs of the members that are online. They show a green dot.
  final Set<String> onlineIds;

  /// Called when a member is tapped.
  final ValueChanged<ChatUser>? onTap;

  /// Whether the list sizes itself to its content, for example in a sheet.
  final bool shrinkWrap;

  /// Shows the members in a bottom sheet with a title.
  static Future<void> show(
    BuildContext context, {
    required List<ChatUser> members,
    Set<String> onlineIds = const {},
    ValueChanged<ChatUser>? onTap,
  }) {
    final theme = ChatThemeData.of(context);
    final l10n = ChatLocalizations.of(context);
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      builder: (sheetContext) => ChatScope(
        theme: theme,
        localizations: l10n,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                '${l10n.membersTitle} · ${members.length}',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
            ),
            Flexible(
              child: ChatMemberList(
                members: members,
                onlineIds: onlineIds,
                shrinkWrap: true,
                onTap: onTap == null
                    ? null
                    : (user) {
                        Navigator.of(sheetContext).pop();
                        onTap(user);
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static int _rank(ChatRole? role) => switch (role) {
        ChatRole.owner => 0,
        ChatRole.admin => 1,
        ChatRole.moderator => 2,
        null => 3,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = ChatLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final sorted = [...members]..sort((a, b) {
        final byRole = _rank(a.role).compareTo(_rank(b.role));
        if (byRole != 0) return byRole;
        return (a.name ?? a.id)
            .toLowerCase()
            .compareTo((b.name ?? b.id).toLowerCase());
      });
    return ListView.builder(
      key: const Key('chatx_member_list'),
      shrinkWrap: shrinkWrap,
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final user = sorted[index];
        final online = onlineIds.contains(user.id);
        final role = user.role;
        return ListTile(
          key: Key('chatx_member_${user.id}'),
          onTap: onTap == null ? null : () => onTap!(user),
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              ChatAvatar(user: user),
              if (online)
                PositionedDirectional(
                  end: -1,
                  bottom: -1,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E9E5B),
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.surface, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            children: [
              Flexible(child: Text(user.name ?? user.id)),
              if (role != null) ...[
                const SizedBox(width: 8),
                ChatRoleBadge(role: role),
              ],
            ],
          ),
          subtitle: online ? Text(l10n.online) : null,
        );
      },
    );
  }
}
