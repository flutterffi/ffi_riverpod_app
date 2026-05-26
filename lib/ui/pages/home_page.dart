import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ble/models/ble_device_item.dart';
import '../../providers/connection_notifier.dart';
import '../../providers/scan_notifier.dart';
import 'device_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scan = ref.watch(scanProvider);
    final connection = ref.watch(connectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Scanner (Riverpod)'),
        actions: [
          IconButton(
            tooltip: scan.isScanning ? 'Stop scan' : 'Start scan',
            onPressed: () {
              final notifier = ref.read(scanProvider.notifier);
              if (scan.isScanning) {
                notifier.stopScan();
              } else {
                notifier.startScan();
              }
            },
            icon: Icon(
              scan.isScanning ? Icons.stop : Icons.bluetooth_searching,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _StatusBanner(scan: scan, connection: connection),
          Expanded(child: _DeviceList(devices: scan.devices, isScanning: scan.isScanning)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final notifier = ref.read(scanProvider.notifier);
          if (scan.isScanning) {
            notifier.stopScan();
          } else {
            notifier.startScan();
          }
        },
        icon: Icon(scan.isScanning ? Icons.stop : Icons.search),
        label: Text(scan.isScanning ? 'Stop' : 'Scan'),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.scan, required this.connection});

  final ScanState scan;
  final BleConnectionState connection;

  @override
  Widget build(BuildContext context) {
    late final String message;
    late final Color color;

    if (connection.status == BleConnectionStatus.connected &&
        connection.device != null) {
      message = 'Connected: ${connection.device!.name}';
      color = Colors.green.shade100;
    } else if (connection.status == BleConnectionStatus.connecting) {
      message = 'Connecting…';
      color = Colors.amber.shade100;
    } else if (scan.status == ScanStatus.failure) {
      message = scan.errorMessage ?? 'Scan failed';
      color = Colors.red.shade100;
    } else if (scan.isScanning) {
      message = 'Scanning… ${scan.devices.length} device(s)';
      color = Colors.teal.shade50;
    } else {
      message = 'Tap Scan to discover BLE devices';
      color = Colors.grey.shade200;
    }

    return Material(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(message),
      ),
    );
  }
}

class _DeviceList extends ConsumerWidget {
  const _DeviceList({required this.devices, required this.isScanning});

  final List<BleDeviceItem> devices;
  final bool isScanning;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (devices.isEmpty) {
      return Center(
        child: Text(
          isScanning ? 'Searching for peripherals…' : 'No devices yet',
        ),
      );
    }

    return ListView.separated(
      itemCount: devices.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final device = devices[index];
        return ListTile(
          leading: const Icon(Icons.bluetooth),
          title: Text(device.name),
          subtitle: Text(device.id),
          trailing: Text('${device.rssi} dBm'),
          onTap: () {
            ref.read(scanProvider.notifier).stopScan();
            ref.read(connectionProvider.notifier).connect(device);
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => DevicePage(device: device),
              ),
            );
          },
        );
      },
    );
  }
}
