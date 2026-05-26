import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ble/models/ble_device_item.dart';
import '../../providers/connection_notifier.dart';

class DevicePage extends ConsumerWidget {
  const DevicePage({required this.device, super.key});

  final BleDeviceItem device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(connectionProvider);
    final notifier = ref.read(connectionProvider.notifier);

    ref.listen(connectionProvider, (previous, next) {
      if (next.status == BleConnectionStatus.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? 'Connection failed')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(device.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _InfoRow(label: 'ID', value: device.id),
            _InfoRow(label: 'Name', value: device.name),
            _InfoRow(label: 'Status', value: _statusLabel(connection.status)),
            if (connection.rssi != null)
              _InfoRow(label: 'RSSI', value: '${connection.rssi} dBm'),
            const SizedBox(height: 24),
            if (connection.status == BleConnectionStatus.connected) ...[
              FilledButton.icon(
                onPressed: notifier.readRssi,
                icon: const Icon(Icons.signal_cellular_alt),
                label: const Text('Read RSSI'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  await notifier.disconnect();
                  if (context.mounted) Navigator.of(context).pop();
                },
                icon: const Icon(Icons.link_off),
                label: const Text('Disconnect'),
              ),
            ] else if (connection.status == BleConnectionStatus.connecting)
              const Center(child: CircularProgressIndicator())
            else
              FilledButton(
                onPressed: () => notifier.connect(device),
                child: const Text('Connect'),
              ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(BleConnectionStatus status) {
    return switch (status) {
      BleConnectionStatus.idle => 'Idle',
      BleConnectionStatus.connecting => 'Connecting',
      BleConnectionStatus.connected => 'Connected',
      BleConnectionStatus.failure => 'Failed',
    };
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
