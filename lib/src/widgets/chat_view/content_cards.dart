part of '../chat_view.dart';

String _clock(BuildContext context, DateTime time) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(time.toLocal()),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

/// Location card: map (image, custom widget or painted placeholder), place
/// and address, and a live badge.
class _LocationContent extends StatelessWidget {
  const _LocationContent({
    required this.state,
    required this.message,
    required this.width,
    required this.textColor,
    required this.accent,
  });

  final _ChatViewState state;
  final LocationMessage message;
  final double width;
  final Color textColor;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final view = state.widget;
    final l10n = ChatLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final live = message.liveUntil;
    final isLive = live != null && live.isAfter(DateTime.now());
    final mapHeight = width * 9 / 16;

    final Widget map;
    final custom = view.builders.locationMapBuilder;
    final image = message.mapImageUri;
    if (custom != null) {
      map = custom(context, message);
    } else if (image != null) {
      map = Image(
        image: _imageProvider(context, view, image, displayWidth: width),
        fit: BoxFit.cover,
        errorBuilder: (context, _, __) => _MapPlaceholder(accent: accent),
      );
    } else {
      map = _MapPlaceholder(accent: accent);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: width,
            height: mapHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                map,
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _LivePin(accent: accent, live: isLive),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (isLive)
          Row(
            children: [
              const Icon(Icons.circle, size: 10, color: Color(0xFFE5484D)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${l10n.liveLocation} · ${l10n.liveUntil(_clock(context, live))}',
                  style: textTheme.labelMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        Text(
          message.title ?? l10n.location,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        if (message.address != null)
          Text(
            message.address!,
            style: textTheme.bodySmall?.copyWith(
              color: textColor.withValues(alpha: 0.75),
            ),
          ),
      ],
    );
  }
}

/// Map-like drawing used when the app provides no map.
class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CustomPaint(
      painter: _MapPainter(
        land: Color.alphaBlend(
          accent.withValues(alpha: 0.08),
          scheme.surfaceContainerHigh,
        ),
        road: scheme.surface,
        park: const Color(0xFF8BC48A).withValues(alpha: 0.45),
        water: const Color(0xFF7FB8E6).withValues(alpha: 0.55),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({
    required this.land,
    required this.road,
    required this.park,
    required this.water,
  });

  final Color land;
  final Color road;
  final Color park;
  final Color water;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = land);
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.75)
        ..quadraticBezierTo(w * 0.3, h * 0.6, w * 0.55, h * 0.85)
        ..quadraticBezierTo(w * 0.75, h, w, h * 0.9)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      Paint()..color = water,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.62, h * 0.12, w * 0.24, h * 0.3),
        const Radius.circular(8),
      ),
      Paint()..color = park,
    );
    final roads = Paint()
      ..color = road
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(Offset(0, h * 0.45), Offset(w, h * 0.35), roads)
      ..drawLine(Offset(w * 0.3, 0), Offset(w * 0.42, h), roads);
    roads.strokeWidth = 3;
    canvas
      ..drawLine(Offset(0, h * 0.15), Offset(w * 0.55, h * 0.25), roads)
      ..drawLine(Offset(w * 0.7, h * 0.45), Offset(w * 0.8, h), roads);
  }

  @override
  bool shouldRepaint(_MapPainter old) => old.land != land || old.road != road;
}

/// Location pin. Pulses while the location is live.
class _LivePin extends StatefulWidget {
  const _LivePin({required this.accent, required this.live});

  final Color accent;
  final bool live;

  @override
  State<_LivePin> createState() => _LivePinState();
}

class _LivePinState extends State<_LivePin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.live && !MediaQuery.disableAnimationsOf(context)) {
      if (!_pulse.isAnimating) unawaited(_pulse.repeat());
    } else {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        if (widget.live)
          Positioned(
            bottom: -10,
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (context, _) => Container(
                width: 20 + 40 * _pulse.value,
                height: 20 + 40 * _pulse.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.accent.withValues(
                    alpha: 0.35 * (1 - _pulse.value),
                  ),
                ),
              ),
            ),
          ),
        Icon(Icons.location_on, size: 40, color: widget.accent),
      ],
    );
  }
}

/// Event invitation with date tile, details and RSVP buttons.
class _EventContent extends StatelessWidget {
  const _EventContent({
    required this.state,
    required this.message,
    required this.textColor,
    required this.accent,
    required this.textStyle,
  });

  final _ChatViewState state;
  final EventMessage message;
  final Color textColor;
  final Color accent;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final view = state.widget;
    final l10n = ChatLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final start = message.startsAt.toLocal();
    final end = message.endsAt?.toLocal();
    final me = view.currentUser.id;
    final mine = message.rsvps[me];
    final going = message.usersWith(ChatRsvp.going);
    final maybe = message.usersWith(ChatRsvp.maybe);
    final month = material.formatShortMonthDay(start).split(' ').first;
    final time = end == null
        ? _clock(context, start)
        : '${_clock(context, start)} – ${_clock(context, end)}';
    final subtle = textColor.withValues(alpha: 0.75);

    Widget rsvpButton(ChatRsvp rsvp, String label, IconData icon) {
      final selected = mine == rsvp;
      final onRsvp = view.contentCallbacks.onRsvp;
      return Expanded(
        child: Semantics(
          button: true,
          selected: selected,
          child: Material(
            key: Key('chatx_rsvp_${message.id}_${rsvp.name}'),
            color: selected ? accent : textColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onRsvp == null
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      onRsvp(message, selected ? null : rsvp);
                    },
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: selected
                          ? (accent.computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white)
                          : accent,
                    ),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelSmall?.copyWith(
                        color: selected
                            ? (accent.computeLuminance() > 0.5
                                ? Colors.black
                                : Colors.white)
                            : textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    month.toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${start.day}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.title,
                    style: textStyle.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '${material.formatMediumDate(start)} · $time',
                    style: textTheme.bodySmall?.copyWith(color: subtle),
                  ),
                  if (message.location != null)
                    Row(
                      children: [
                        Icon(Icons.place_outlined, size: 14, color: subtle),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            message.location!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(color: subtle),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
        if (message.description != null) ...[
          const SizedBox(height: 8),
          ChatText(message.description!, style: textStyle),
        ],
        const SizedBox(height: 8),
        Text(
          l10n.rsvpSummary(going.length, maybe.length),
          style: textTheme.labelMedium?.copyWith(color: subtle),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            rsvpButton(ChatRsvp.going, l10n.rsvpGoing, Icons.check_rounded),
            const SizedBox(width: 6),
            rsvpButton(ChatRsvp.maybe, l10n.rsvpMaybe, Icons.help_outline),
            const SizedBox(width: 6),
            rsvpButton(
              ChatRsvp.notGoing,
              l10n.rsvpNotGoing,
              Icons.close_rounded,
            ),
          ],
        ),
      ],
    );
  }
}

/// Shared contact card.
class _ContactContent extends StatelessWidget {
  const _ContactContent({
    required this.state,
    required this.message,
    required this.textColor,
    required this.accent,
  });

  final _ChatViewState state;
  final ContactMessage message;
  final Color textColor;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final view = state.widget;
    final l10n = ChatLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final subtle = textColor.withValues(alpha: 0.75);
    final onAction = view.contentCallbacks.onContactAction;
    final actions = [
      if (message.phone != null)
        (ChatContactAction.call, Icons.call_outlined, l10n.call),
      if (message.email != null)
        (ChatContactAction.email, Icons.mail_outline, l10n.sendEmail),
      (
        ChatContactAction.save,
        Icons.person_add_alt_1_outlined,
        l10n.addContact
      ),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            ChatAvatar(
              user: ChatUser(
                id: message.id,
                name: message.name,
                avatarUrl: message.avatarUrl,
              ),
              size: 48,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (message.organization != null)
                    Text(
                      message.organization!,
                      style: textTheme.bodySmall?.copyWith(color: subtle),
                    ),
                  if (message.phone != null)
                    Text(
                      message.phone!,
                      style: textTheme.bodySmall?.copyWith(color: subtle),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(height: 1, color: textColor.withValues(alpha: 0.15)),
        Row(
          children: [
            for (final (action, icon, label) in actions)
              Expanded(
                child: TextButton(
                  key: Key('chatx_contact_${message.id}_${action.name}'),
                  onPressed:
                      onAction == null ? null : () => onAction(message, action),
                  style: TextButton.styleFrom(
                    foregroundColor: accent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 6,
                    ),
                  ),
                  // Icon above the label, so three actions fit side by side
                  // even with long translations or large text.
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 20),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(label, maxLines: 1),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
