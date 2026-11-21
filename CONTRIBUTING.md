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

### material_ui interop

`test_apps/material_ui_interop` checks that chatx works inside apps built on
the `material_ui` package. It needs Flutter 3.47 or newer:

```bash
cd test_apps/material_ui_interop
flutter pub get && flutter test
```

### Golden tests

Golden files live in `test/goldens/goldens/`. They are rendered on CI
(Linux, latest stable Flutter), because pixels differ slightly between
Flutter versions and operating systems. Locally, skip them:

```bash
flutter test --exclude-tags golden
```

If you change visuals on purpose:

1. Push your branch.
2. Run the **Update goldens** workflow from the Actions tab on that branch.
3. Download the `goldens` artifact, copy the images into
   `test/goldens/goldens/`, review them and commit.

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
