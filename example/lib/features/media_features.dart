import 'dart:async';
import 'dart:math';

import 'package:chatx/chatx.dart';
import 'package:flutter/material.dart';

import '../fake_backend.dart';
import 'demo_chat.dart';

const _leo = ChatUser(id: 'leo', name: 'Leo');

final _random = Random(7);

List<double> _wave(int n) =>
    [for (var i = 0; i < n; i++) 0.2 + _random.nextDouble() * 0.8];

const _photos = [
  ChatImage(uri: 'asset:sunset', width: 640, height: 480),
  ChatImage(uri: 'asset:ocean', width: 640, height: 480),
  ChatImage(uri: 'asset:forest', width: 640, height: 480),
  ChatImage(uri: 'asset:dunes', width: 640, height: 480),
];

final mediaFeatures = FeatureGroup('Media', [
  FeatureDemo(
    title: 'Images',
    description: 'Grids, captions, a zoomable viewer, uploads and spoilers.',
    icon: Icons.photo_library_outlined,
    builder: (_) => _Timed(
      builder: (timers) => DemoChat(
        title: 'Images',
        hint: 'Tap a photo to open the viewer: pinch to zoom, swipe down to '
            'close. Tap the blurred one to reveal it.',
        seed: () => [
          ImageMessage(
            id: 'i1',
            author: ana,
            createdAt: ago(12),
            images: _photos,
            caption: 'Best **trip** ever 🌅',
          ),
          ImageMessage(
            id: 'i2',
            author: ana,
            createdAt: ago(8),
            images: const [
              ChatImage(uri: 'asset:forest', width: 640, height: 480),
            ],
            caption: 'No peeking until you finish the series',
            isSpoiler: true,
          ),
          ImageMessage(
            id: 'i3',
            author: me,
            createdAt: ago(1),
            images: const [
              ChatImage(uri: 'asset:card', width: 640, height: 480),
            ],
            caption: 'Uploading this one',
            uploadProgress: 0.1,
            status: MessageStatus.sending,
          ),
        ],
        onReady: (c) => timers.add(_simulateUpload(c, 'i3')),
        view: (context, c) => ChatView(
          controller: c,
          currentUser: me,
          onSend: (o) => sendText(c, o),
          builders: const ChatBuilders(imageProviderBuilder: demoImage),
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Video',
    description: 'Video messages with a poster and duration.',
    icon: Icons.movie_outlined,
    builder: (_) => DemoChat(
      title: 'Video',
      hint: 'Tap a video. A real app plays it with video_player.',
      seed: () => [
        VideoMessage(
          id: 'v1',
          author: ana,
          createdAt: ago(6),
          uri: 'clips/sunset.mp4',
          thumbnailUri: 'asset:sunset',
          duration: const Duration(minutes: 1, seconds: 12),
          width: 1920,
          height: 1080,
          caption: 'Golden hour',
        ),
        VideoMessage(
          id: 'v2',
          author: me,
          createdAt: ago(2),
          uri: 'clips/ocean.mp4',
          thumbnailUri: 'asset:ocean',
          duration: const Duration(seconds: 9),
          width: 1080,
          height: 1920,
          status: MessageStatus.read,
        ),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        builders: const ChatBuilders(imageProviderBuilder: demoImage),
        media: ChatMediaOptions(
          onVideoTap: (video) =>
              toast(context, 'Play ${video.uri} with video_player'),
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Files',
    description: 'Documents with name, size and upload progress.',
    icon: Icons.attach_file,
    builder: (_) => _Timed(
      builder: (timers) => DemoChat(
        title: 'Files',
        hint: 'Watch the spreadsheet upload finish, then tap a file to '
            'open it.',
        seed: () => [
          FileMessage(
            id: 'f1',
            author: ana,
            createdAt: ago(9),
            name: 'Itinerary.pdf',
            sizeBytes: 1843200,
          ),
          FileMessage(
            id: 'f2',
            author: ana,
            createdAt: ago(7),
            name: 'Packing list.docx',
            sizeBytes: 23552,
          ),
          FileMessage(
            id: 'f3',
            author: me,
            createdAt: ago(1),
            name: 'Budget 2026.xlsx',
            sizeBytes: 524288,
            uploadProgress: 0.1,
            status: MessageStatus.sending,
          ),
        ],
        onReady: (c) => timers.add(_simulateUpload(c, 'f3')),
        view: (context, c) => ChatView(
          controller: c,
          currentUser: me,
          onSend: (o) => sendText(c, o),
          media: ChatMediaOptions(
            onFileTap: (file) =>
                toast(context, 'Open ${file.name} with your viewer'),
          ),
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Voice notes',
    description: 'Playback, seeking, recording and transcripts.',
    icon: Icons.mic_none,
    builder: (_) => const _VoiceDemo(),
  ),
  FeatureDemo(
    title: 'Attachments tray',
    description: 'Pick files, review them above the input, then send.',
    icon: Icons.add_photo_alternate_outlined,
    builder: (_) => DemoChat(
      title: 'Attachments',
      hint: 'Tap the clip to add files to the tray, remove one if you like, '
          'add a caption and send.',
      seed: () => [text('t1', 'Send me the trip files?', minutesAgo: 2)],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        sendFeatures: const {ChatSendFeature.attachments},
        builders: const ChatBuilders(imageProviderBuilder: demoImage),
        // A real app opens a file picker here (for example `file_picker`).
        onAttach: () => c.composer.addAttachments([
          ChatAttachment(
            id: newId(),
            name: 'dunes.png',
            kind: ChatAttachmentKind.image,
            uri: 'asset:dunes',
            sizeBytes: 312000,
          ),
          ChatAttachment(
            id: newId(),
            name: 'itinerary.pdf',
            sizeBytes: 482000,
          ),
        ]),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Link previews',
    description: 'Rich cards for links with site, title and image.',
    icon: Icons.link,
    builder: (_) => DemoChat(
      title: 'Link previews',
      hint: 'Tap the card or the link. The demo copies it instead of '
          'opening a browser.',
      seed: () => [
        TextMessage(
          id: 'l1',
          author: ana,
          createdAt: ago(4),
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
        text('l2', 'Docs are at https://flutter.dev too',
            author: me, minutesAgo: 1),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        builders: const ChatBuilders(imageProviderBuilder: demoImage),
        onLinkTap: (uri) => showLink(context, uri),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Stickers',
    description: 'A sticker picker next to the input and sticker bubbles.',
    icon: Icons.emoji_emotions_outlined,
    builder: (_) => DemoChat(
      title: 'Stickers',
      hint: 'Tap the emoji button in the input, open the Faces tab and pick '
          'a sticker.',
      seed: () => [
        StickerMessage(
          id: 'k1',
          author: ana,
          createdAt: ago(2),
          uri: 'sticker:love',
          label: 'In love',
        ),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        sendFeatures: const {ChatSendFeature.stickers},
        stickerPacks: const [demoStickers],
        builders: const ChatBuilders(imageProviderBuilder: demoImage),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Location',
    description: 'Static pins and live location sharing.',
    icon: Icons.place_outlined,
    builder: (_) => DemoChat(
      title: 'Location',
      hint: 'Tap a location card. A real app opens maps here.',
      seed: () => [
        LocationMessage(
          id: 'p1',
          author: ana,
          createdAt: ago(15),
          latitude: 38.7223,
          longitude: -9.1393,
          title: 'Miradouro de Santa Luzia',
          address: 'Largo de Santa Luzia, Lisbon',
        ),
        LocationMessage(
          id: 'p2',
          author: me,
          createdAt: ago(1),
          latitude: 38.7139,
          longitude: -9.1334,
          title: 'My live location',
          liveUntil: DateTime.now().add(const Duration(hours: 1)),
          status: MessageStatus.read,
        ),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        contentCallbacks: ChatContentCallbacks(
          onLocationTap: (location) =>
              toast(context, 'Open ${location.title} in maps'),
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Contact card',
    description: 'Shared contacts with call, message and email actions.',
    icon: Icons.contact_page_outlined,
    builder: (_) => DemoChat(
      title: 'Contact card',
      hint: 'Tap an action on the card.',
      seed: () => [
        text('c1', 'Who was our guide?', author: me, minutesAgo: 4),
        ContactMessage(
          id: 'c2',
          author: ana,
          createdAt: ago(3),
          name: 'Leo Martín',
          organization: 'Tour guide',
          phone: '+351 912 345 678',
          email: 'leo@example.com',
        ),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        contentCallbacks: ChatContentCallbacks(
          onContactAction: (contact, action) =>
              toast(context, '${action.name}: ${contact.name}'),
        ),
      ),
    ),
  ),
  FeatureDemo(
    title: 'Media gallery',
    description: 'Every photo, file and link of the chat in three tabs.',
    icon: Icons.perm_media_outlined,
    builder: (_) {
      ChatController? chat;
      return DemoChat(
        title: 'Media gallery',
        hint: 'Tap the gallery button in the app bar, then an item to jump '
            'to its message.',
        actions: [
          Builder(
            builder: (context) => IconButton(
              tooltip: 'Media, files and links',
              icon: const Icon(Icons.perm_media_outlined),
              onPressed: () {
                final controller = chat;
                if (controller == null) return;
                ChatMediaGallery.show(
                  context,
                  controller: controller,
                  imageProviderBuilder: demoImage,
                );
              },
            ),
          ),
        ],
        seed: () => [
          ImageMessage(
            id: 'g1',
            author: ana,
            createdAt: ago(60),
            images: _photos,
            caption: 'Trip photos',
          ),
          FileMessage(
            id: 'g2',
            author: me,
            createdAt: ago(55),
            name: 'Itinerary.pdf',
            sizeBytes: 1843200,
            status: MessageStatus.read,
          ),
          text('g3', 'Hotel: https://example.com/hotel', minutesAgo: 50),
          VideoMessage(
            id: 'g4',
            author: _leo,
            createdAt: ago(40),
            uri: 'clips/sunset.mp4',
            thumbnailUri: 'asset:sunset',
            duration: const Duration(seconds: 42),
          ),
          for (var i = 0; i < 8; i++)
            text('g${i + 5}', 'Message $i',
                author: i.isEven ? me : ana, minutesAgo: 30 - i),
          FileMessage(
            id: 'g13',
            author: ana,
            createdAt: ago(10),
            name: 'Budget 2026.xlsx',
            sizeBytes: 524288,
          ),
          ImageMessage(
            id: 'g14',
            author: me,
            createdAt: ago(5),
            images: const [
              ChatImage(uri: 'asset:card', width: 640, height: 480),
            ],
            status: MessageStatus.read,
          ),
        ],
        view: (context, c) {
          chat = c;
          return ChatView(
            controller: c,
            currentUser: me,
            onSend: (o) => sendText(c, o),
            builders: const ChatBuilders(imageProviderBuilder: demoImage),
            onLinkTap: (uri) => showLink(context, uri),
          );
        },
      );
    },
  ),
]);

/// Advances the upload of the file or image [id] until it completes.
Timer _simulateUpload(ChatController c, String id) =>
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      final message = c.messageById(id);
      final progress = switch (message) {
        FileMessage(:final uploadProgress?) => uploadProgress,
        ImageMessage(:final uploadProgress?) => uploadProgress,
        _ => null,
      };
      if (message == null || progress == null) return timer.cancel();
      final next = progress + 0.06;
      if (next < 1) {
        c.update(switch (message) {
          FileMessage() => message.copyWith(uploadProgress: next),
          ImageMessage() => message.copyWith(uploadProgress: next),
          _ => message,
        });
        return;
      }
      timer.cancel();
      final done = switch (message) {
        FileMessage() => message.copyWith(clearUploadProgress: true),
        ImageMessage() => message.copyWith(clearUploadProgress: true),
        _ => message,
      };
      c.update(done.copyWithMeta(status: MessageStatus.delivered));
    });

/// Owns timers started by a demo and cancels them when it closes.
class _Timed extends StatefulWidget {
  const _Timed({required this.builder});

  final Widget Function(List<Timer> timers) builder;

  @override
  State<_Timed> createState() => _TimedState();
}

class _TimedState extends State<_Timed> {
  final timers = <Timer>[];

  @override
  void dispose() {
    for (final timer in timers) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(timers);
}

class _VoiceDemo extends StatefulWidget {
  const _VoiceDemo();

  @override
  State<_VoiceDemo> createState() => _VoiceDemoState();
}

class _VoiceDemoState extends State<_VoiceDemo> {
  final ValueNotifier<ChatVoicePlayback?> playback = ValueNotifier(null);
  Timer? player;

  @override
  void dispose() {
    player?.cancel();
    playback.dispose();
    super.dispose();
  }

  /// Pretends to play audio by advancing the position every 100 ms.
  void play(VoiceMessage message) {
    player?.cancel();
    final current = playback.value;
    var position =
        current?.messageId == message.id ? current!.position : Duration.zero;
    if (position >= message.duration) position = Duration.zero;
    player = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      position += const Duration(milliseconds: 100);
      final done = position >= message.duration;
      playback.value = ChatVoicePlayback(
        messageId: message.id,
        position: done ? message.duration : position,
        isPlaying: !done,
      );
      if (done) timer.cancel();
    });
  }

  void pause(VoiceMessage message) {
    player?.cancel();
    final current = playback.value;
    if (current == null) return;
    playback.value = ChatVoicePlayback(
      messageId: current.messageId,
      position: current.position,
      isPlaying: false,
    );
  }

  void seek(VoiceMessage message, Duration position) {
    final wasPlaying = playback.value?.messageId == message.id &&
        (playback.value?.isPlaying ?? false);
    player?.cancel();
    playback.value = ChatVoicePlayback(
      messageId: message.id,
      position: position,
      isPlaying: false,
    );
    if (wasPlaying) play(message);
  }

  /// Fake transcription service.
  Future<void> transcribe(ChatController c, VoiceMessage message) async {
    await latency(900);
    if (!mounted) return;
    c.update(
      message.copyWith(
        transcript: 'Hi! Landing at seven, can you pick me up at the '
            'airport? I will bring the photos.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DemoChat(
      title: 'Voice notes',
      hint: 'Play a note and drag the waveform to seek. Tap Transcribe on '
          'the second one. Hold the mic to record, release to send.',
      seed: () => [
        VoiceMessage(
          id: 'a1',
          author: ana,
          createdAt: ago(10),
          uri: 'notes/hello.m4a',
          duration: const Duration(seconds: 8),
          waveform: _wave(40),
          transcript: 'Hey, are we still on for tonight?',
        ),
        VoiceMessage(
          id: 'a2',
          author: ana,
          createdAt: ago(6),
          uri: 'notes/airport.m4a',
          duration: const Duration(seconds: 23),
          waveform: _wave(48),
        ),
      ],
      view: (context, c) => ChatView(
        controller: c,
        currentUser: me,
        onSend: (o) => sendText(c, o),
        media: ChatMediaOptions(
          voicePlayback: playback,
          onVoicePlay: play,
          onVoicePause: pause,
          onVoiceSeek: seek,
          onTranscribe: (message) => transcribe(c, message),
          onVoiceRecordStart: () => toast(context, 'Recording…'),
          onVoiceRecordEnd: (duration, {required cancelled}) {
            if (cancelled || duration < const Duration(milliseconds: 500)) {
              toast(context, 'Recording discarded');
              return;
            }
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            c.insert(
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
        ),
      ),
    );
  }
}
