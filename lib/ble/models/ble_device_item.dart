import 'package:equatable/equatable.dart';

class BleDeviceItem extends Equatable {
  const BleDeviceItem({
    required this.id,
    required this.name,
    required this.rssi,
  });

  final String id;
  final String name;
  final int rssi;

  @override
  List<Object?> get props => [id, name, rssi];
}
