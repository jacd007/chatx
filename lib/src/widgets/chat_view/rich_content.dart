part of '../chat_view.dart';

/// Loads [uri] through `ChatView.imageProviderBuilder`, decoded at the size
/// it is displayed to save memory.
ImageProvider _imageProvider(
  BuildContext context,
  ChatView view,
  String uri, {
  double? displayWidth,
}) {
  final provider =
      view.builders.imageProviderBuilder?.call(uri) ?? NetworkImage(uri);
  if (displayWidth == null || !displayWidth.isFinite) return provider;
  final pixels =
      (displayWidth * MediaQuery.devicePixelRatioOf(context)).round();
  return ResizeImage.resizeIfNeeded(pixels, null, provider);
}

/// Grid of one to four images with an upload overlay and spoiler blur.
class _ImageGrid extends StatefulWidget {
  const _ImageGrid({
    required this.state,
    required this.message,
    required this.width,
    required this.radius,
  });

  final _ChatViewState state;
  final ImageMessage message;
  final double width;
  final double radius;

  @override
  State<_ImageGrid> createState() => _ImageGridState();
}

class _ImageGridState extends State<_ImageGrid> {
  bool _revealed = false;

  ImageMessage get message => widget.message;

  void _open(int index) {
    final view = widget.state.widget;
    final onImageTap = view.media.onImageTap;
    if (onImageTap != null) {
      onImageTap(message, index);
      return;
    }
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, _) => FadeTransition(
          opacity: animation,
          child: _ImageViewer(
            view: view,
            message: message,
            initialIndex: index,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = message.images;
    final shown = images.length > 4 ? 4 : images.length;
    final extra = images.length - shown;
    const gap = 2.0;
    final width = widget.width;

    Widget tile(int index, double w, double h) {
      final image = images[index];
      Widget child = Image(
        key: Key('chatx_image_${message.id}_$index'),
        image: _imageProvider(
          context,
          widget.state.widget,
          image.uri,
          displayWidth: w,
        ),
        width: w,
        height: h,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        frameBuilder: (context, child, frame, wasSync) => AnimatedOpacity(
          opacity: frame == null && !wasSync ? 0 : 1,
          duration: const Duration(milliseconds: 250),
          child: child,
        ),
        errorBuilder: (context, _, __) => const Center(
          child: Icon(Icons.broken_image_outlined),
        ),
      );
      if (index == shown - 1 && extra > 0) {
        child = Stack(
          fit: StackFit.expand,
          children: [
            child,
            ColoredBox(
              color: Colors.black45,
              child: Center(
                child: Text(
                  '+$extra',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        );
      }
      final hidden = message.isSpoiler && !_revealed;
      return SizedBox(
        width: w,
        height: h,
        child: Hero(
          tag: 'chatx_image_${message.id}_$index',
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: InkWell(
              onTap: hidden || message.uploadProgress != null
                  ? null
                  : () => _open(index),
              child: child,
            ),
          ),
        ),
      );
    }

    final ratio = (images.first.aspectRatio ?? 4 / 3).clamp(0.6, 1.8);
    final Widget grid = switch (shown) {
      1 => tile(0, width, width / ratio),
      2 => Row(
          children: [
            tile(0, (width - gap) / 2, (width - gap) / 2),
            const SizedBox(width: gap),
            tile(1, (width - gap) / 2, (width - gap) / 2),
          ],
        ),
      3 => Row(
          children: [
            tile(0, (width - gap) * 0.6, width * 0.8),
            const SizedBox(width: gap),
            Column(
              children: [
                tile(1, (width - gap) * 0.4, (width * 0.8 - gap) / 2),
                const SizedBox(height: gap),
                tile(2, (width - gap) * 0.4, (width * 0.8 - gap) / 2),
              ],
            ),
          ],
        ),
      _ => Column(
          children: [
            for (var row = 0; row < 2; row++) ...[
              if (row > 0) const SizedBox(height: gap),
              Row(
                children: [
                  tile(row * 2, (width - gap) / 2, (width - gap) / 2 * 0.8),
                  const SizedBox(width: gap),
                  tile(
                    row * 2 + 1,
                    (width - gap) / 2,
                    (width - gap) / 2 * 0.8,
                  ),
                ],
              ),
            ],
          ],
        ),
    };

    final l10n = ChatLocalizations.of(context);
    final progress = message.uploadProgress;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ImageFiltered(
            enabled: message.isSpoiler && !_revealed,
            imageFilter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: grid,
          ),
          if (message.isSpoiler && !_revealed)
            Positioned.fill(
              child: Semantics(
                button: true,
                label: l10n.spoiler,
                excludeSemantics: true,
                child: GestureDetector(
                  key: Key('chatx_spoiler_${message.id}'),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _revealed = true);
                  },
                  child: ColoredBox(
                    color: Colors.black26,
                    child: Center(
                      child: _Pill(
                        icon: Icons.visibility_off_outlined,
                        label: 'Spoiler',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (progress != null)
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color: Colors.black38,
                  child: Center(
                    child: Semantics(
                      label: l10n.uploading,
                      value: '${(progress * 100).round()}%',
                      child: SizedBox.square(
                        dimension: 48,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(end: progress.clamp(0.0, 1.0)),
                          duration: reduceMotion
                              ? Duration.zero
                              : const Duration(milliseconds: 300),
                          builder: (context, value, _) =>
                              CircularProgressIndicator(
                            value: value,
                            strokeWidth: 3,
                            color: Colors.white,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Small translucent label used over media.
class _Pill extends StatelessWidget {
  const _Pill({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen, zoomable image viewer. Swipe down to close.
class _ImageViewer extends StatefulWidget {
  const _ImageViewer({
    required this.view,
    required this.message,
    required this.initialIndex,
  });

  final ChatView view;
  final ImageMessage message;
  final int initialIndex;

  @override
  State<_ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<_ImageViewer> {
  late final PageController _pages =
      PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;
  final TransformationController _zoom = TransformationController();
  double _dragOffset = 0;
  bool _zoomed = false;

  @override
  void initState() {
    super.initState();
    _zoom.addListener(() {
      final zoomed = _zoom.value.getMaxScaleOnAxis() > 1.01;
      if (zoomed != _zoomed) setState(() => _zoomed = zoomed);
    });
  }

  @override
  void dispose() {
    _pages.dispose();
    _zoom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ChatLocalizations.of(context);
    final images = widget.message.images;
    final opacity = (1 - _dragOffset.abs() / 400).clamp(0.3, 1.0);
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: opacity),
      body: GestureDetector(
        onVerticalDragUpdate: _zoomed
            ? null
            : (d) => setState(() => _dragOffset += d.primaryDelta ?? 0),
        onVerticalDragEnd: _zoomed
            ? null
            : (d) {
                if (_dragOffset.abs() > 120 ||
                    (d.primaryVelocity ?? 0).abs() > 900) {
                  Navigator.of(context).pop();
                } else {
                  setState(() => _dragOffset = 0);
                }
              },
        child: Stack(
          children: [
            Transform.translate(
              offset: Offset(0, _dragOffset),
              child: PageView.builder(
                controller: _pages,
                physics: _zoomed
                    ? const NeverScrollableScrollPhysics()
                    : const PageScrollPhysics(),
                itemCount: images.length,
                onPageChanged: (i) {
                  _zoom.value = Matrix4.identity();
                  setState(() => _index = i);
                },
                itemBuilder: (context, i) => InteractiveViewer(
                  transformationController: i == _index ? _zoom : null,
                  maxScale: 5,
                  panEnabled: _zoomed,
                  child: Center(
                    child: Hero(
                      tag: 'chatx_image_${widget.message.id}_$i',
                      child: Image(
                        image: _imageProvider(
                          context,
                          widget.view,
                          images[i].uri,
                        ),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Row(
                children: [
                  IconButton(
                    key: const Key('chatx_viewer_close'),
                    tooltip: l10n.close,
                    color: Colors.white,
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  if (images.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text(
                        '${_index + 1} / ${images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Human-readable size, for example "2.4 MB".
String _formatBytes(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  final digits = unit == 0 || value >= 10 ? 0 : 1;
  return '${value.toStringAsFixed(digits)} ${units[unit]}';
}

/// Icon and color for a file, based on its extension or MIME type.
(IconData, Color) _fileVisual(FileMessage message, ColorScheme scheme) {
  final ext = message.extension;
  final mime = message.mimeType ?? '';
  if (ext == 'pdf' || mime == 'application/pdf') {
    return (Icons.picture_as_pdf_outlined, const Color(0xFFD93025));
  }
  if (const {'doc', 'docx', 'odt', 'rtf', 'txt', 'md'}.contains(ext)) {
    return (Icons.description_outlined, const Color(0xFF1A73E8));
  }
  if (const {'xls', 'xlsx', 'csv', 'ods'}.contains(ext)) {
    return (Icons.table_chart_outlined, const Color(0xFF188038));
  }
  if (const {'ppt', 'pptx', 'key', 'odp'}.contains(ext)) {
    return (Icons.slideshow_outlined, const Color(0xFFE8710A));
  }
  if (const {'zip', 'rar', '7z', 'tar', 'gz'}.contains(ext)) {
    return (Icons.folder_zip_outlined, const Color(0xFF8E6E00));
  }
  if (mime.startsWith('audio/') ||
      const {'mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac'}.contains(ext)) {
    return (Icons.audio_file_outlined, const Color(0xFF9334E6));
  }
  if (mime.startsWith('video/') ||
      const {'mp4', 'mov', 'avi', 'mkv', 'webm'}.contains(ext)) {
    return (Icons.video_file_outlined, const Color(0xFFC5221F));
  }
  if (mime.startsWith('image/') ||
      const {'png', 'jpg', 'jpeg', 'gif', 'webp', 'heic'}.contains(ext)) {
    return (Icons.image_outlined, const Color(0xFF12857A));
  }
  return (Icons.insert_drive_file_outlined, scheme.primary);
}

class _FileContent extends StatelessWidget {
  const _FileContent({required this.message, required this.textColor});

  final FileMessage message;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = ChatLocalizations.of(context);
    final (icon, color) = _fileVisual(message, scheme);
    final progress = message.uploadProgress;
    final size = message.sizeBytes;
    final details = [
      if (message.extension.isNotEmpty) message.extension.toUpperCase(),
      if (size != null) _formatBytes(size),
    ].join(' · ');
    final small = Theme.of(context).textTheme.bodySmall;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // A light tile keeps the colored icon readable on any bubble.
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Color.alphaBlend(
                    color.withValues(alpha: 0.12),
                    scheme.surface,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SizedBox.square(
                  dimension: 48,
                  child: Icon(icon, color: color),
                ),
              ),
              if (progress != null)
                Semantics(
                  label: l10n.uploading,
                  value: '${(progress * 100).round()}%',
                  child: SizedBox.square(
                    dimension: 44,
                    child: CircularProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      strokeWidth: 2.5,
                      color: color,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (details.isNotEmpty)
                Text(
                  progress == null
                      ? details
                      : '${l10n.uploading} ${(progress * 100).round()}%',
                  style: small?.copyWith(
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

String _formatDuration(Duration d) {
  final minutes = d.inMinutes;
  final seconds = d.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

class _VoiceContent extends StatelessWidget {
  const _VoiceContent({
    required this.state,
    required this.message,
    required this.textColor,
    required this.accent,
  });

  final _ChatViewState state;
  final VoiceMessage message;
  final Color textColor;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final view = state.widget;
    final l10n = ChatLocalizations.of(context);
    final playback = view.media.voicePlayback ?? const _NoPlayback();
    return ValueListenableBuilder<ChatVoicePlayback?>(
      valueListenable: playback,
      builder: (context, value, _) {
        final current = value?.messageId == message.id ? value : null;
        final playing = current?.isPlaying ?? false;
        final position = current?.position ?? Duration.zero;
        final total = message.duration.inMilliseconds;
        final progress = total == 0
            ? 0.0
            : (position.inMilliseconds / total).clamp(0.0, 1.0);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              button: true,
              label: playing ? l10n.pause : l10n.play,
              excludeSemantics: true,
              child: Material(
                key: Key('chatx_voice_play_${message.id}'),
                color: accent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => playing
                      ? view.media.onVoicePause?.call(message)
                      : view.media.onVoicePlay?.call(message),
                  child: SizedBox.square(
                    dimension: 44,
                    child: Icon(
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: _onColor(accent),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: view.media.onVoiceSeek == null
                          ? null
                          : (d) => view.media.onVoiceSeek!(
                                message,
                                message.duration *
                                    (d.localPosition.dx / constraints.maxWidth)
                                        .clamp(0.0, 1.0),
                              ),
                      child: CustomPaint(
                        size: Size(constraints.maxWidth, 28),
                        painter: _WaveformPainter(
                          samples: message.waveform,
                          progress: progress,
                          played: accent,
                          remaining: textColor.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    current == null
                        ? _formatDuration(message.duration)
                        : _formatDuration(position),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: textColor.withValues(alpha: 0.72),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static Color _onColor(Color color) =>
      color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}

/// Stand-in when the app does not report playback.
class _NoPlayback extends ValueListenable<ChatVoicePlayback?> {
  const _NoPlayback();

  @override
  ChatVoicePlayback? get value => null;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.samples,
    required this.progress,
    required this.played,
    required this.remaining,
  });

  final List<double> samples;
  final double progress;
  final Color played;
  final Color remaining;

  @override
  void paint(Canvas canvas, Size size) {
    const barWidth = 3.0;
    const gap = 2.0;
    final count = math.max(1, (size.width / (barWidth + gap)).floor());
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;
    for (var i = 0; i < count; i++) {
      final amplitude = _sample(i, count);
      final height = math.max(3.0, amplitude * size.height);
      final x = i * (barWidth + gap) + barWidth / 2;
      paint.color = (i + 0.5) / count <= progress ? played : remaining;
      canvas.drawLine(
        Offset(x, (size.height - height) / 2),
        Offset(x, (size.height + height) / 2),
        paint,
      );
    }
  }

  // Averages the samples that fall into bar [i] of [count].
  double _sample(int i, int count) {
    if (samples.isEmpty) return 0.15;
    final start = (i * samples.length / count).floor();
    final end = math.max(start + 1, ((i + 1) * samples.length / count).floor());
    var sum = 0.0;
    for (var j = start; j < end && j < samples.length; j++) {
      sum += samples[j];
    }
    return (sum / (end - start)).clamp(0.0, 1.0);
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.progress != progress ||
      old.played != played ||
      old.remaining != remaining ||
      !identical(old.samples, samples);
}

class _PollContent extends StatelessWidget {
  const _PollContent({
    required this.state,
    required this.message,
    required this.textColor,
    required this.accent,
  });

  final _ChatViewState state;
  final PollMessage message;
  final Color textColor;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final view = state.widget;
    final l10n = ChatLocalizations.of(context);
    final me = view.currentUser.id;
    final showResults = message.isClosed || message.hasVoted(me);
    final total = message.totalVotes;
    final canVote =
        !message.isClosed && view.contentCallbacks.onPollVote != null;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final textTheme = Theme.of(context).textTheme;
    final hint = message.isClosed
        ? l10n.pollClosed
        : message.allowsMultipleAnswers
            ? l10n.pollSelectMany
            : l10n.pollSelectOne;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.poll_outlined, size: 18, color: accent),
            const SizedBox(width: 6),
            Text(
              l10n.poll.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          message.question,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(
          hint,
          style: textTheme.bodySmall?.copyWith(
            color: textColor.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        for (final option in message.options)
          _PollOptionTile(
            key: Key('chatx_poll_${message.id}_${option.id}'),
            option: option,
            fraction: total == 0 ? 0 : option.votes / total,
            selected: option.voterIds.contains(me),
            multiple: message.allowsMultipleAnswers,
            showResults: showResults,
            textColor: textColor,
            accent: accent,
            animate: !reduceMotion,
            onTap: canVote
                ? () {
                    HapticFeedback.selectionClick();
                    view.contentCallbacks.onPollVote!(message, option.id);
                  }
                : null,
          ),
        const SizedBox(height: 4),
        Text(
          l10n.pollVotes(total),
          style: textTheme.labelSmall?.copyWith(
            color: textColor.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _PollOptionTile extends StatelessWidget {
  const _PollOptionTile({
    super.key,
    required this.option,
    required this.fraction,
    required this.selected,
    required this.multiple,
    required this.showResults,
    required this.textColor,
    required this.accent,
    required this.animate,
    required this.onTap,
  });

  final PollOption option;
  final double fraction;
  final bool selected;
  final bool multiple;
  final bool showResults;
  final Color textColor;
  final Color accent;
  final bool animate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final percent = (fraction * 100).round();
    final IconData icon;
    if (multiple) {
      icon = selected ? Icons.check_box_rounded : Icons.check_box_outline_blank;
    } else {
      icon = selected
          ? Icons.radio_button_checked_rounded
          : Icons.radio_button_unchecked_rounded;
    }
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: option.text,
      value: showResults ? '$percent%' : null,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color:
                          selected ? accent : textColor.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(option.text)),
                    if (showResults) ...[
                      const SizedBox(width: 8),
                      Text(
                        '$percent%',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: showResults ? fraction : 0),
                    duration: animate
                        ? const Duration(milliseconds: 600)
                        : Duration.zero,
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 6,
                      color:
                          selected ? accent : textColor.withValues(alpha: 0.45),
                      backgroundColor: textColor.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Live countdown to a [CountdownMessage.endsAt].
class _CountdownContent extends StatefulWidget {
  const _CountdownContent({
    required this.message,
    required this.textColor,
    required this.accent,
    required this.textStyle,
    required this.richText,
  });

  final CountdownMessage message;
  final Color textColor;
  final Color accent;
  final TextStyle textStyle;

  /// Renders the description like any message text (search, mentions).
  final Widget Function(String text) richText;

  @override
  State<_CountdownContent> createState() => _CountdownContentState();
}

class _CountdownContentState extends State<_CountdownContent> {
  Timer? _timer;
  Duration _left = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  @override
  void didUpdateWidget(_CountdownContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.endsAt != widget.message.endsAt) _tick();
  }

  void _tick() {
    final left = widget.message.endsAt.difference(DateTime.now());
    _left = left.isNegative ? Duration.zero : left;
    _timer?.cancel();
    if (_left > Duration.zero) {
      // Fire right after the next whole second so the display stays in step.
      final delay = Duration(milliseconds: _left.inMilliseconds % 1000 + 5);
      _timer = Timer(delay, () {
        if (mounted) setState(_tick);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ChatLocalizations.of(context);
    final message = widget.message;
    final done = _left == Duration.zero;
    final seconds = (_left.inMilliseconds / 1000).ceil();
    final units = [
      (seconds ~/ 86400, l10n.countdownDays),
      (seconds % 86400 ~/ 3600, l10n.countdownHours),
      (seconds % 3600 ~/ 60, l10n.countdownMinutes),
      (seconds % 60, l10n.countdownSeconds),
    ];
    final textTheme = Theme.of(context).textTheme;
    final localizations = MaterialLocalizations.of(context);
    final local = message.endsAt.toLocal();
    final when = '${localizations.formatMediumDate(local)} · '
        '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(local), alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context))}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.campaign_outlined, size: 18, color: widget.accent),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                when,
                style: textTheme.labelSmall?.copyWith(
                  color: widget.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          message.title,
          style: widget.textStyle.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: (widget.textStyle.fontSize ?? 16) * 1.15,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: done
              ? Row(
                  key: const ValueKey('done'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        message.completedLabel ?? l10n.countdownCompleted,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: widget.accent,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                )
              : Semantics(
                  key: const ValueKey('ticking'),
                  label: [
                    for (final (value, unit) in units) '$value $unit',
                  ].join(', '),
                  excludeSemantics: true,
                  // Shrinks in narrow bubbles and with large text instead of
                  // overflowing.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final (i, (value, unit)) in units.indexed) ...[
                          if (i > 0) const SizedBox(width: 6),
                          _CountdownUnit(
                            value: value,
                            unit: unit,
                            textColor: widget.textColor,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
        ),
        if (message.description != null) ...[
          const SizedBox(height: 10),
          widget.richText(message.description!),
        ],
      ],
    );
  }
}

class _CountdownUnit extends StatelessWidget {
  const _CountdownUnit({
    required this.value,
    required this.unit,
    required this.textColor,
  });

  final int value;
  final String unit;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 52),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => SlideTransition(
              position: Tween(
                begin: const Offset(0, -0.4),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Text(
              value.toString().padLeft(2, '0'),
              key: ValueKey(value),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: textColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 11,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card with title, description and image of a link.
class _LinkPreviewCard extends StatelessWidget {
  const _LinkPreviewCard({
    required this.state,
    required this.preview,
    required this.textColor,
    required this.accent,
    required this.maxWidth,
  });

  final _ChatViewState state;
  final ChatLinkPreview preview;
  final Color textColor;
  final Color accent;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final view = state.widget;
    final uri = view.linkPolicy.resolve(preview.url);
    final onLinkTap = view.onLinkTap;
    final site = preview.siteName ?? uri?.host ?? preview.url;
    final textTheme = Theme.of(context).textTheme;
    final image = preview.imageUri;
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: math.min(240, maxWidth)),
      child: Material(
        key: const Key('chatx_link_preview'),
        color: textColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: uri == null || onLinkTap == null ? null : () => onLinkTap(uri),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 3, color: accent),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          site,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelMedium?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (preview.title != null)
                          Text(
                            preview.title!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        if (preview.description != null)
                          Text(
                            preview.description!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: textColor.withValues(alpha: 0.8),
                            ),
                          ),
                        if (image != null) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: AspectRatio(
                              aspectRatio: 1.91,
                              child: Image(
                                image: _imageProvider(
                                  context,
                                  view,
                                  image,
                                  displayWidth: maxWidth,
                                ),
                                fit: BoxFit.cover,
                                errorBuilder: (context, _, __) =>
                                    const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
