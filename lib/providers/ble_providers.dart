import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ble/ble_repository.dart';
import '../ble/flutter_blue_ble_repository.dart';

/// Injectable BLE data source; override in tests with a fake implementation.
final bleRepositoryProvider = Provider<BleRepository>(
  (ref) => FlutterBlueBleRepository(),
);
