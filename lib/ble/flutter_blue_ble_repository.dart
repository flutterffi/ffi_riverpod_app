import 'dart:async';
import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ble_repository.dart';
import 'models/ble_device_item.dart';

class FlutterBlueBleRepository implements BleRepository {
  final _connectedController = StreamController<BleDeviceItem?>.broadcast();
  BluetoothDevice? _device;

  @override
  Stream<BleDeviceItem?> get connectedDevice => _connectedController.stream;

  @override
  Stream<bool> get isScanning => FlutterBluePlus.isScanning;

  @override
  Stream<List<BleDeviceItem>> get scanResults =>
      FlutterBluePlus.scanResults.map(_mapResults);

  @override
  Future<void> ensurePermissions() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    if (Platform.isAndroid) {
      await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();
      return;
    }

    await Permission.bluetooth.request();
  }

  @override
  Future<void> startScan() async {
    if (FlutterBluePlus.isScanningNow) return;
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15),
      androidUsesFineLocation: false,
    );
  }

  @override
  Future<void> stopScan() => FlutterBluePlus.stopScan();

  @override
  Future<void> connect(BleDeviceItem item) async {
    await stopScan();
    final device = BluetoothDevice.fromId(item.id);
    await device.connect(timeout: const Duration(seconds: 12));
    _device = device;
    _connectedController.add(item);
    device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        _device = null;
        _connectedController.add(null);
      }
    });
  }

  @override
  Future<void> disconnect() async {
    final device = _device;
    _device = null;
    _connectedController.add(null);
    if (device != null) {
      await device.disconnect();
    }
  }

  @override
  Future<int?> readRssi() async {
    final device = _device;
    if (device == null) return null;
    return device.readRssi();
  }

  List<BleDeviceItem> _mapResults(List<ScanResult> results) {
    final byId = <String, BleDeviceItem>{};
    for (final result in results) {
      final id = result.device.remoteId.str;
      final name = result.device.platformName.isNotEmpty
          ? result.device.platformName
          : 'Unknown';
      byId[id] = BleDeviceItem(id: id, name: name, rssi: result.rssi);
    }
    return byId.values.toList()..sort((a, b) => b.rssi.compareTo(a.rssi));
  }
}
