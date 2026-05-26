import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ffi_riverpod_app/ble/ble_repository.dart';
import 'package:ffi_riverpod_app/ble/models/ble_device_item.dart';
import 'package:ffi_riverpod_app/providers/ble_providers.dart';
import 'package:ffi_riverpod_app/providers/scan_notifier.dart';

class _FakeBleRepository implements BleRepository {
  final _results = StreamController<List<BleDeviceItem>>.broadcast();

  @override
  Stream<List<BleDeviceItem>> get scanResults => _results.stream;

  @override
  Stream<bool> get isScanning => const Stream.empty();

  @override
  Stream<BleDeviceItem?> get connectedDevice => const Stream.empty();

  @override
  Future<void> ensurePermissions() async {}

  @override
  Future<void> startScan() async {
    _results.add(const [
      BleDeviceItem(id: 'aa:bb', name: 'Demo', rssi: -55),
    ]);
  }

  @override
  Future<void> stopScan() async {}

  @override
  Future<void> connect(BleDeviceItem device) async {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<int?> readRssi() async => -60;
}

void main() {
  test('scanNotifier emits devices after startScan', () async {
    final fake = _FakeBleRepository();
    final container = ProviderContainer(
      overrides: [
        bleRepositoryProvider.overrideWithValue(fake),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(scanProvider.notifier);
    await notifier.startScan();
    await Future<void>.delayed(Duration.zero);

    final state = container.read(scanProvider);
    expect(state.status, ScanStatus.scanning);
    expect(state.devices, hasLength(1));
    expect(state.devices.first.name, 'Demo');
  });
}
