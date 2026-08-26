# Later

**Later remembers the things you do not want to.**

Later is a private, local-first Flutter application for the ordinary details
people need again: belongings, physical locations, simple IOUs, documents,
expiry dates, warranties, and maintenance.

This repository currently contains one fresh Flutter application targeting
**Android and iOS only**. Product and architecture planning is complete; feature
implementation has not started.

## Product model

Later answers four questions:

- **What?** Things and records
- **Where?** User-confirmed physical locations
- **When?** Due dates, expiry, warranty, maintenance, and reminders
- **Who?** People, money, lending, and borrowing

The core interaction is:

```text
Capture → Understand → Confirm → Save → Remind → Find later
```

## Documentation

- [Product vision](docs/PRODUCT.md)
- [Product requirements](docs/REQUIREMENTS.md)
- [Implementation plan](docs/IMPLEMENTATION_PLAN.md)
- [Application architecture](docs/ARCHITECTURE.md)
- [Conceptual data model](docs/DATA_MODEL.md)
- [Decision log](docs/DECISIONS.md)
- [Feature planning](docs/features/README.md)
- [Contributing guide](CONTRIBUTING.md)

## Project structure

```text
later/
├── android/
├── ios/
├── lib/
├── test/
├── docs/
└── pubspec.yaml
```

This is intentionally a standard single-app Flutter repository. We will not add
`apps/`, `packages/`, or workspace tooling unless a real second application or
consumer exists.

## Run

```sh
flutter pub get
flutter run
```

## Verify

```sh
dart format --output=none --set-exit-if-changed lib
flutter analyze
flutter build apk --debug
```

Run `flutter test` once the first tests are added. iOS builds require macOS with
Xcode.

## Current status

The app is at **Milestone 0: project foundation**. See the implementation plan
before adding dependencies or feature code.
