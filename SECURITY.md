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
- chatx never opens links, stores data, or makes network requests. Avatar
  images are the only exception: they load from `ChatUser.avatarUrl` through
  `Image.network`.
