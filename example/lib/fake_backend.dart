import 'dart:math';

import 'package:chatx/chatx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const me = ChatUser(id: 'me', name: 'You');
const ana = ChatUser(id: 'ana', name: 'Ana');
const bot = ChatUser(id: 'bot', name: 'Assistant', isBot: true);

final _random = Random();
var _counter = 0;

/// Unique enough IDs for a demo. Use UUIDs or server IDs in real apps.
String newId() => '${DateTime.now().microsecondsSinceEpoch}-${_counter++}';

/// Resolves `asset:` URIs of the demo to bundled images.
ImageProvider demoImage(String uri) {
  if (uri.startsWith('asset:')) {
    return AssetImage('assets/images/${uri.substring(6)}.png');
  }
  if (uri.startsWith('sticker:')) {
    return AssetImage('assets/stickers/${uri.substring(8)}.png');
  }
  return NetworkImage(uri);
}

const demoStickers = ChatStickerPack(
  id: 'faces',
  name: 'Faces',
  stickers: [
    ChatSticker(id: 'smile', uri: 'sticker:smile', label: 'Smiling face'),
    ChatSticker(id: 'love', uri: 'sticker:love', label: 'In love'),
    ChatSticker(id: 'wow', uri: 'sticker:wow', label: 'Surprised'),
    ChatSticker(id: 'cool', uri: 'sticker:cool', label: 'Cool'),
    ChatSticker(id: 'heart', uri: 'sticker:heart', label: 'Heart'),
    ChatSticker(id: 'star', uri: 'sticker:star', label: 'Star'),
  ],
);

/// Simulates network latency.
Future<void> latency([int ms = 600]) =>
    Future<void>.delayed(Duration(milliseconds: ms + _random.nextInt(300)));

/// chatx has no dependencies, so it never opens links itself. A real app
/// would call `launchUrl(uri)` from the url_launcher package here.
void showLink(BuildContext context, Uri uri) {
  Clipboard.setData(ClipboardData(text: uri.toString()));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Link copied: $uri')),
  );
}
