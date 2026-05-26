import 'models/ble_device_item.dart';

abstract class BleRepository {
  Stream<List<BleDeviceItem>> get scanResults;

  Stream<bool> get isScanning;

  Stream<BleDeviceItem?> get connectedDevice;

  Future<void> ensurePermissions();

  Future<void> startScan();

  Future<void> stopScan();

  Future<void> connect(BleDeviceItem device);

  Future<void> disconnect();

  Future<int?> readRssi();
}
