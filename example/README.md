# chatx example

Runnable demos of every chatx feature:

| Demo | Shows |
| --- | --- |
| Basic chat | Swipe to reply, tap for the popup menu, reactions, editing, unread separator, retry |
| Bubble styles | Tail, radius, shadow and outline |
| AI streaming | Token-by-token responses with `appendText` |
| Custom look | `ChatTheme`, builders, custom messages, long-press actions |
| Infinite history | `onLoadMore` pagination |

```bash
cd example
flutter run          # any device
flutter run -d chrome
```

Regenerate the README screenshots on an iOS simulator:

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/screenshots_test.dart \
  -d "iPhone 17"
```

The "backend" in `lib/fake_backend.dart` is simulated in memory, so the demos
work offline.
