import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ble/models/ble_device_item.dart';
import 'ble_providers.dart';

enum ScanStatus { idle, scanning, failure }

class ScanState extends Equatable {
  const ScanState({
    this.status = ScanStatus.idle,
    this.devices = const [],
    this.errorMessage,
  });

  final ScanStatus status;
  final List<BleDeviceItem> devices;
  final String? errorMessage;

  bool get isScanning => status == ScanStatus.scanning;

  ScanState copyWith({
    ScanStatus? status,
    List<BleDeviceItem>? devices,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ScanState(
      status: status ?? this.status,
      devices: devices ?? this.devices,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, devices, errorMessage];
}

class ScanNotifier extends Notifier<ScanState> {
  StreamSubscription<List<BleDeviceItem>>? _subscription;

  @override
  ScanState build() {
    ref.onDispose(_cancelSubscription);
    return const ScanState();
  }

  Future<void> startScan() async {
    final repository = ref.read(bleRepositoryProvider);
    try {
      await repository.ensurePermissions();
      await _cancelSubscription();
      _subscription = repository.scanResults.listen(
        (devices) {
          state = state.copyWith(
            devices: devices,
            status: ScanStatus.scanning,
            clearError: true,
          );
        },
        onError: (Object e) {
          state = state.copyWith(
            status: ScanStatus.failure,
            errorMessage: e.toString(),
          );
        },
      );
      await repository.startScan();
      state = state.copyWith(status: ScanStatus.scanning, clearError: true);
    } catch (e) {
      state = state.copyWith(
        status: ScanStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> stopScan() async {
    await _cancelSubscription();
    await ref.read(bleRepositoryProvider).stopScan();
    state = state.copyWith(status: ScanStatus.idle);
  }

  Future<void> _cancelSubscription() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}

final scanProvider = NotifierProvider<ScanNotifier, ScanState>(ScanNotifier.new);
