# Runner

SSH terminal client for managing remote servers from your mobile device.

## Features

- SSH connection management with password and private key auth
- ProxyJump / bastion host support
- Full terminal emulation powered by [xterm.dart](https://pub.dev/packages/xterm)
- Multiple simultaneous SSH sessions with tab switching
- Catppuccin theme with Latte, Frappé, Macchiato, and Mocha flavors
- Terminal keyboard toolbar (Esc, Tab, Ctrl, arrows, PgUp/PgDn, Home/End)
- Copy/paste support
- Secure credential storage via Android Keystore / iOS Keychain
- Connection status indicators and error recovery
- 30s keepalive to maintain connections

## Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- Android Studio or Xcode for building

### Build

```sh
flutter pub get
flutter run           # Run on connected device
flutter build apk --release --split-per-abi  # Build release APK
```

### Release builds

Tag a commit with `v*` to trigger the GitHub Actions workflow which builds and uploads split APKs:

```sh
git tag v1.0.0
git push origin v1.0.0
```

### Signing

For production releases, create `android/key.properties`:

```properties
storeFile=/path/to/keystore.jks
storePassword=your_store_password
keyAlias=your_key_alias
keyPassword=your_key_password
```

Then uncomment the signing configuration in `android/app/build.gradle.kts`.

## Tech Stack

- **Flutter** — cross-platform UI framework
- **dartssh3** — SSH client library (active fork of dartssh2)
- **xterm.dart** — terminal emulator
- **flutter_secure_storage** — encrypted credential storage
- **Catppuccin** — community-driven pastel color palette

## License

MIT
