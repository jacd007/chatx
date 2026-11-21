# chatx example

Runnable demos of every chatx feature:

| Demo | Shows |
| --- | --- |
| Basic chat | Optimistic sending, delivery status, typing indicator, retry |
| AI streaming | Token-by-token responses with `appendText` |
| Custom look | `ChatTheme`, builders, custom messages, long-press actions |
| Infinite history | `onLoadMore` pagination |

```bash
cd example
flutter run          # any device
flutter run -d chrome
```

The "backend" in `lib/fake_backend.dart` is simulated in memory, so the demos
work offline.
