import 'package:simpleble_dart/simple_ble.dart';
import 'package:simpleble_dart/simple_ble_adapter.dart';
import 'package:simpleble_dart/simple_ble_peripheral.dart';

void main(List<String> args) async {
  SimpleBle simpleBle = SimpleBle();
  simpleBle.init();

  SimpleBleAdapter adapter = simpleBle.getAdapter(0);

  adapter.setStartScanCallback(() {
    print("Scan Started");
  });

  adapter.setScanFoundCallback((SimpleBlePeripheral scanResult) {
    print(
      'Scan Found : ${scanResult.identifier} - ${scanResult.address} - ${scanResult.rssi}',
    );
    if (scanResult.identifier.contains('iPhone')) {
      adapter.stopScan();
      adapter.removeScanFoundCallback();
      onPeripheralFound(scanResult);
    }
  });

  adapter.startScan();
}

void onPeripheralFound(SimpleBlePeripheral peripheral) async {
  print('Peripheral Found : ${peripheral.identifier}');

  peripheral.setCallbackOnConnected(() {
    print('Connected');
  });

  peripheral.setCallbackOnDisconnected(() {
    print('Disconnected');
  });

  peripheral.connect();
  await Future.delayed(Duration(seconds: 2));

  print('Connected : ${peripheral.isConnected()}');

  peripheral.disconnect();

  await Future.delayed(Duration(seconds: 5));
  peripheral.dispose();
}
