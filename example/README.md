# chatx example

Runnable demos of every chatx feature:

| Demo | Shows |
| --- | --- |
| Basic chat | Swipe to reply, popup menu, reactions, editing, unread separator, retry, hover actions |
| Bubble styles | Tail, radius, shadow and outline |
| Media & files | Images, files, voice notes and transcripts, video, attachments tray, location, contact, stickers, spoilers |
| Community | Survey, poll, event RSVP, thread, read receipts, translation, edit history, scheduled and deleted messages, moderation, search, selection |
| Workspace | Roles, member list, profiles, media gallery, checklist, call log, unread mentions, offline queue |
| Announcements | Read-only channel and saved messages |
| Support bot | Buttons, quick replies, products, payment request, slow mode, disappearing code |
| AI streaming | Suggested prompts, reasoning, tool calls, sources, versions, stop, rating, code and tables |
| Custom look | `ChatTheme`, builders, custom messages, dark mode |
| Infinite history | `onLoadMore` pagination |

```bash
cd example
flutter run          # any device
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
