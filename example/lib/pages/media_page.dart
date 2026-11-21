import 'dart:async';
import 'dart:math';

import 'package:chatx/chatx.dart';
import 'package:flutter/material.dart';

import '../fake_backend.dart';

/// Images, files, voice notes, link previews and spoilers.
///
/// Images use `asset:` URIs resolved by `imageProviderBuilder`, so the demo
/// works offline. In a real app they would be network URLs.
class MediaPage extends StatefulWidget {
  const MediaPage({super.key});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  static final DateTime _start =
      DateTime.now().subtract(const Duration(minutes: 20));
  static final _random = Random(7);

  static List<double> _wave(int n) =>
      [for (var i = 0; i < n; i++) 0.2 + _random.nextDouble() * 0.8];

  late final ChatController _controller = ChatController(
    messages: [
      ImageMessage(
        id: 'trip',
        author: ana,
        createdAt: _start,
        images: const [
          ChatImage(uri: 'asset:sunset', width: 640, height: 480),
          ChatImage(uri: 'asset:ocean', width: 640, height: 480),
          ChatImage(uri: 'asset:forest', width: 640, height: 480),
          ChatImage(uri: 'asset:dunes', width: 640, height: 480),
          ChatImage(uri: 'asset:card', width: 640, height: 480),
        ],
        caption: 'Best **trip** ever 🌅',
        reactions: const [
          ChatReaction(emoji: '😍', userIds: ['me']),
        ],
      ),
      VoiceMessage(
        id: 'voice1',
        author: ana,
        createdAt: _start.add(const Duration(minutes: 1)),
        uri: 'demo.m4a',
        duration: const Duration(seconds: 23),
        waveform: _wave(48),
      ),
      FileMessage(
        id: 'pdf',
        author: me,
        createdAt: _start.add(const Duration(minutes: 3)),
        name: 'Itinerary.pdf',
        sizeBytes: 1843200,
        status: MessageStatus.read,
      ),
      FileMessage(
        id: 'xlsx',
        author: me,
        createdAt: _start.add(const Duration(minutes: 4)),
        name: 'Budget 2026.xlsx',
        sizeBytes: 524288,
        uploadProgress: 0.35,
        status: MessageStatus.sending,
      ),
      TextMessage(
        id: 'link',
        author: ana,
        createdAt: _start.add(const Duration(minutes: 6)),
        text: 'This is the package we use: https://pub.dev/packages/chatx',
        linkPreview: const ChatLinkPreview(
          url: 'https://pub.dev/packages/chatx',
          siteName: 'pub.dev',
          title: 'chatx | Flutter package',
          description: 'Backend-agnostic, zero-dependency chat UI for '
              'Flutter.',
          imageUri: 'asset:card',
        ),
      ),
      TextMessage(
        id: 'spoiler',
        author: ana,
        createdAt: _start.add(const Duration(minutes: 8)),
        text: 'Finished the series! The killer was ||the gardener|| 😱',
      ),
      LocationMessage(
        id: 'location',
        author: ana,
        createdAt: _start.add(const Duration(minutes: 10)),
        latitude: 38.7223,
        longitude: -9.1393,
        title: 'Miradouro de Santa Luzia',
        address: 'Largo de Santa Luzia, Lisbon',
        liveUntil: DateTime.now().add(const Duration(hours: 1)),
      ),
      ContactMessage(
        id: 'contact',
        author: me,
        createdAt: _start.add(const Duration(minutes: 11)),
        name: 'Leo Martín',
        organization: 'Tour guide',
        phone: '+351 912 345 678',
        email: 'leo@example.com',
        status: MessageStatus.read,
      ),
      VideoMessage(
        id: 'video',
        author: me,
        createdAt: _start.add(const Duration(minutes: 9, seconds: 30)),
        uri: 'clips/sunset.mp4',
        thumbnailUri: 'asset:sunset',
        duration: const Duration(minutes: 1, seconds: 12),
        width: 1920,
        height: 1080,
        status: MessageStatus.read,
      ),
      StickerMessage(
        id: 'sticker',
        author: ana,
        createdAt: _start.add(const Duration(minutes: 12)),
        uri: 'sticker:love',
        label: 'In love',
      ),
      ImageMessage(
        id: 'spoilerImg',
        author: ana,
        createdAt: _start.add(const Duration(minutes: 9)),
        images: const [ChatImage(uri: 'asset:forest', width: 640, height: 480)],
        isSpoiler: true,
      ),
    ],
  );

  final ValueNotifier<ChatVoicePlayback?> _playback = ValueNotifier(null);
  Timer? _player;
  Timer? _upload;

  @override
  void initState() {
    super.initState();
    _simulateUpload();
  }

  @override
  void dispose() {
    _player?.cancel();
    _upload?.cancel();
    _playback.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Advances the upload of the spreadsheet until it completes.
  void _simulateUpload() {
    _upload = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      final file = _controller.messageById('xlsx');
      if (file is! FileMessage) return timer.cancel();
      final progress = (file.uploadProgress ?? 1) + 0.05;
      if (progress >= 1) {
        timer.cancel();
        _controller.update(
          file.copyWith(
            clearUploadProgress: true,
            status: MessageStatus.delivered,
          ),
        );
      } else {
        _controller.update(file.copyWith(uploadProgress: progress));
      }
    });
  }

  /// Pretends to play audio by advancing the position every 100 ms.
  void _play(VoiceMessage message) {
    _player?.cancel();
    final current = _playback.value;
    var position =
        current?.messageId == message.id ? current!.position : Duration.zero;
    if (position >= message.duration) position = Duration.zero;
    _player = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      position += const Duration(milliseconds: 100);
      final done = position >= message.duration;
      _playback.value = ChatVoicePlayback(
        messageId: message.id,
        position: done ? message.duration : position,
        isPlaying: !done,
      );
      if (done) timer.cancel();
    });
  }

  void _pause(VoiceMessage message) {
    _player?.cancel();
    final current = _playback.value;
    if (current == null) return;
    _playback.value = ChatVoicePlayback(
      messageId: current.messageId,
      position: current.position,
      isPlaying: false,
    );
  }

  /// Fake transcription service.
  Future<void> _transcribe(VoiceMessage message) async {
    await latency(900);
    if (!mounted) return;
    _controller.update(
      message.copyWith(
        transcript: 'Hi! Landing at seven, can you pick me up at the '
            'airport? I will bring the photos.',
      ),
    );
  }

  /// A real app opens a file picker here (for example `file_picker`).
  void _attach() {
    _controller.composer.addAttachments(const [
      ChatAttachment(
        id: 'dunes',
        name: 'dunes.png',
        kind: ChatAttachmentKind.image,
        uri: 'asset:dunes',
      ),
      ChatAttachment(
        id: 'ocean',
        name: 'ocean.png',
        kind: ChatAttachmentKind.image,
        uri: 'asset:ocean',
      ),
      ChatAttachment(
        id: 'itinerary',
        name: 'itinerary.pdf',
        sizeBytes: 482000,
      ),
    ]);
  }

  void _sendAttachments(
    List<ChatAttachment> attachments,
    String caption,
    ChatMessage? replyTo,
  ) {
    final images = [
      for (final a in attachments)
        if (a.kind == ChatAttachmentKind.image && a.uri != null)
          ChatImage(uri: a.uri!),
    ];
    if (images.isNotEmpty) {
      _controller.insert(
        ImageMessage(
          id: newId(),
          author: me,
          createdAt: DateTime.now(),
          images: images,
          caption: caption.isEmpty ? null : caption,
          replyToId: replyTo?.id,
          status: MessageStatus.sent,
        ),
      );
    }
    for (final file in attachments) {
      if (file.kind == ChatAttachmentKind.image) continue;
      _controller.insert(
        FileMessage(
          id: newId(),
          author: me,
          createdAt: DateTime.now(),
          name: file.name,
          sizeBytes: file.sizeBytes,
          status: MessageStatus.sent,
        ),
      );
    }
  }

  void _send(String text, ChatMessage? replyTo) {
    _controller.insert(
      TextMessage(
        id: newId(),
        author: me,
        createdAt: DateTime.now(),
        text: text,
        replyToId: replyTo?.id,
        status: MessageStatus.sent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media & files')),
      body: ChatView(
        controller: _controller,
        currentUser: me,
        onSendMessage: _send,
        imageProviderBuilder: demoImage,
        onAttach: _attach,
        onSendAttachments: _sendAttachments,
        onTranscribe: _transcribe,
        onVideoTap: (video) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Play ${video.uri} with video_player')),
        ),
        stickerPacks: const [demoStickers],
        onSendSticker: (sticker) => _controller.insert(
          StickerMessage(
            id: newId(),
            author: me,
            createdAt: DateTime.now(),
            uri: sticker.uri,
            label: sticker.label,
            status: MessageStatus.sent,
          ),
        ),
        onLocationTap: (location) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Open ${location.title} in maps'))),
        onContactAction: (contact, action) => ScaffoldMessenger.of(context)
            .showSnackBar(
                SnackBar(content: Text('${action.name}: ${contact.name}'))),
        onLinkTap: (uri) => showLink(context, uri),
        onFileTap: (file) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Open ${file.name} with your viewer')),
        ),
        voicePlayback: _playback,
        onVoicePlay: _play,
        onVoicePause: _pause,
        onVoiceSeek: (message, position) => _playback.value = ChatVoicePlayback(
          messageId: message.id,
          position: position,
          isPlaying: false,
        ),
        // Hold the mic to "record"; releasing sends a fake voice note.
        onVoiceRecordStart: () {},
        onVoiceRecordEnd: (duration, {required cancelled}) {
          if (cancelled || duration < const Duration(milliseconds: 500)) return;
          _controller.insert(
            VoiceMessage(
              id: newId(),
              author: me,
              createdAt: DateTime.now(),
              uri: 'recording.m4a',
              duration: duration,
              waveform: _wave(40),
              status: MessageStatus.sent,
            ),
          );
        },
        onReactionSelected: (m, emoji) =>
            _controller.toggleReaction(m.id, emoji, me.id),
      ),
    );
  }
}
