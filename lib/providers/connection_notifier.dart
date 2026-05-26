import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ble/models/ble_device_item.dart';
import 'ble_providers.dart';

enum BleConnectionStatus { idle, connecting, connected, failure }

class BleConnectionState extends Equatable {
  const BleConnectionState({
    this.status = BleConnectionStatus.idle,
    this.device,
    this.rssi,
    this.errorMessage,
  });

  final BleConnectionStatus status;
  final BleDeviceItem? device;
  final int? rssi;
  final String? errorMessage;

  BleConnectionState copyWith({
    BleConnectionStatus? status,
    BleDeviceItem? device,
    int? rssi,
    String? errorMessage,
    bool clearDevice = false,
    bool clearError = false,
  }) {
    return BleConnectionState(
      status: status ?? this.status,
      device: clearDevice ? null : (device ?? this.device),
      rssi: rssi ?? this.rssi,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, device, rssi, errorMessage];
}

class ConnectionNotifier extends Notifier<BleConnectionState> {
  StreamSubscription<BleDeviceItem?>? _connectedSub;

  @override
  BleConnectionState build() {
    final repository = ref.read(bleRepositoryProvider);
    _connectedSub?.cancel();
    _connectedSub = repository.connectedDevice.listen((device) {
      if (device == null && state.status == BleConnectionStatus.connected) {
        state = const BleConnectionState();
      }
    });
    ref.onDispose(() => _connectedSub?.cancel());
    return const BleConnectionState();
  }

  Future<void> connect(BleDeviceItem device) async {
    state = BleConnectionState(
      status: BleConnectionStatus.connecting,
      device: device,
    );
    try {
      await ref.read(bleRepositoryProvider).connect(device);
      state = BleConnectionState(
        status: BleConnectionStatus.connected,
        device: device,
      );
    } catch (e) {
      state = BleConnectionState(
        status: BleConnectionStatus.failure,
        device: device,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> disconnect() async {
    await ref.read(bleRepositoryProvider).disconnect();
    state = const BleConnectionState();
  }

  Future<void> readRssi() async {
    final rssi = await ref.read(bleRepositoryProvider).readRssi();
    if (rssi != null) {
      state = state.copyWith(rssi: rssi);
    }
  }
}

final connectionProvider =
    NotifierProvider<ConnectionNotifier, BleConnectionState>(
  ConnectionNotifier.new,
);
