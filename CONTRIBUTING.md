# Contributing to chatx

Thanks for helping! Bug reports, docs fixes and pull requests are welcome.

## Principles

- **Zero dependencies.** chatx depends only on the Flutter SDK. Pull requests
  that add a runtime dependency will not be merged.
- **Backend agnostic.** chatx renders state. It never talks to a server.
- **Every platform.** Code must work on Android, iOS, web, macOS, Windows and
  Linux. No platform channels.
- **Documented API.** Every public member has a dartdoc comment with an example
  when useful.

## Setup

```bash
git clone https://github.com/jacd007/chatx.git
cd chatx
flutter pub get
```

Run the demo app:

```bash
cd example
flutter run
```

## Checks

Run these before opening a pull request. CI runs the same commands.

```bash
dart format lib test example/lib
flutter analyze --fatal-infos
flutter test
```

### Golden tests

Golden files live in `test/goldens/goldens/`. If you change visuals on
purpose, regenerate them and review the images in your pull request:

```bash
flutter test --update-goldens --tags golden
```

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/):
`feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `chore:`.

## Releasing (maintainers)

1. Update `version` in `pubspec.yaml` and add a `CHANGELOG.md` section.
2. Commit, then tag and push: `git tag v0.2.0 && git push origin v0.2.0`.
3. The `Publish to pub.dev` workflow publishes the tag.

One-time setup for automated publishing:

1. Publish the first version manually with `flutter pub publish`.
2. On pub.dev, open the package **Admin** tab and enable
   **Automated publishing** from GitHub Actions with repository
   `jacd007/chatx`, tag pattern `v{{version}}` and environment `pub.dev`.
3. In GitHub, create an environment named `pub.dev` (Settings → Environments)
   and, optionally, require a reviewer.
