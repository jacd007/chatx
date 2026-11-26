# Security policy

## Supported versions

Security fixes are released for the latest minor version of chatx.

## Reporting a vulnerability

Please do not open a public issue. Report it privately through
[GitHub Security Advisories](https://github.com/jacd007/chatx/security/advisories/new).
You will get an answer within 7 days.

## Security model

chatx renders text that usually comes from other users, so it treats all
message content as untrusted:

- HTML in messages is never interpreted.
- Only links allowed by `ChatLinkPolicy` (by default `http`, `https` and
  `mailto`) are tappable. `javascript:`, `file:`, `intent:` and other schemes
  are rendered as plain text.
- A markdown link whose label looks like an address with a different host
  shows the real host after the label (`bank.com (evil.com)`).
  `ChatLinkPolicy.isDeceptive` exposes the same check.
- Bidirectional controls (U+202A–U+202E, U+2066–U+2069, U+200E, U+200F,
  U+061C), invisible characters (U+200B, U+2060, U+FEFF) and Unicode tag
  characters outside flag emoji are removed from user names. Message bodies are only cleaned when the app passes
  `ChatView.textSanitizer`, for example `ChatTextSanitizer.strip`.
- Apps control copying through `ChatView.onCopyText` and the composer
  length through `ChatView.inputMaxLength`.
- Parsed message text is kept in a shared cache of up to 512 entries.
  `ChatText.clearCache()` empties it.
- chatx never opens links, stores data, or makes network requests. Avatar
  images are the only exception: they load from `ChatUser.avatarUrl` through
  `Image.network`.
