# ffi_riverpod_app

Bluetooth LE sample app for **flutterffi**, built with **Riverpod** and **flutter_blue_plus**.

Paired with [ffi_bloc_app](https://github.com/flutterffi/ffi_bloc_app) for the same BLE features using **flutter_bloc** — see the [Bloc vs Riverpod BLE topic](https://github.com/flutterffi/flutter_interview/blob/main/topics/bloc-riverpod-ble.md).

## Features

- Scan nearby BLE peripherals (15s timeout, deduped, sorted by RSSI)
- Connect / disconnect with live connection state
- Read RSSI while connected
- Runtime permissions (Android 12+ / iOS)

## Architecture

```text
lib/
├── ble/                         # Data layer (shared pattern with bloc demo)
│   ├── ble_repository.dart
│   └── flutter_blue_ble_repository.dart
├── providers/
│   ├── ble_providers.dart       # bleRepositoryProvider
│   ├── scan_notifier.dart       # scanProvider (Notifier)
│   └── connection_notifier.dart # connectionProvider (Notifier)
├── ui/pages/
├── app.dart
└── main.dart                    # ProviderScope root
```

| Layer | Riverpod construct | Role |
|-------|-------------------|------|
| Data | `Provider<BleRepository>` | DI + test overrides |
| Scan | `NotifierProvider<ScanNotifier, ScanState>` | Scan lifecycle & device list |
| Connection | `NotifierProvider<ConnectionNotifier, BleConnectionState>` | Connect / RSSI |
| UI | `ConsumerWidget` + `ref.watch` / `ref.listen` | Rebuild on state |

## Getting started

```bash
flutter pub get
flutter run
```

Use a **physical device** with BLE; emulators have limited Bluetooth support.

## Tests

```bash
flutter test
flutter analyze
```

Override `bleRepositoryProvider` in tests — no `BlocProvider` tree required.

## License

MIT — see [LICENSE](LICENSE).
