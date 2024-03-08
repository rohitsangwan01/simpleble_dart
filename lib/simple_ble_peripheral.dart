import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:simpleble_dart/generated/generated_bindings.dart';

class SimpleBlePeripheral {
  final simpleble_peripheral_t peripheral;
  final NativeLibrary nativeLibrary;
  SimpleBlePeripheral(this.peripheral, this.nativeLibrary);

  NativeCallable<PeripheralConnectedCallback>? _onConnectedCallback;
  NativeCallable<PeripheralDisconnectedCallback>? _onDisconnectedCallback;

  // Dispose the handle
  void dispose() {
    nativeLibrary.simpleble_peripheral_release_handle(peripheral);
    _onConnectedCallback?.close();
    _onDisconnectedCallback?.close();
  }

  String get identifier {
    final result = nativeLibrary.simpleble_peripheral_identifier(peripheral);
    return result.cast<Utf8>().toDartString();
  }

  String get address {
    final result = nativeLibrary.simpleble_peripheral_address(peripheral);
    return result.cast<Utf8>().toDartString();
  }

  int get rssi {
    return nativeLibrary.simpleble_peripheral_rssi(peripheral);
  }

  int get power {
    return nativeLibrary.simpleble_peripheral_tx_power(peripheral);
  }

  int get addressType {
    return nativeLibrary.simpleble_peripheral_address_type(peripheral);
  }

  void connect() {
    nativeLibrary.simpleble_peripheral_connect(peripheral);
  }

  void disconnect() {
    nativeLibrary.simpleble_peripheral_disconnect(peripheral);
  }

  bool isConnected() {
    final connected = calloc<Bool>();
    nativeLibrary.simpleble_peripheral_is_connected(peripheral, connected);
    return connected.value;
  }

  void setCallbackOnConnected( Function() callback) {
    void connectedCallback(simpleble_peripheral_t _, Pointer<Void> __) {
      callback();
    }

    _onConnectedCallback ??=
        NativeCallable<PeripheralConnectedCallback>.listener(
      connectedCallback,
    );

    nativeLibrary.simpleble_peripheral_set_callback_on_connected(
        peripheral, _onConnectedCallback!.nativeFunction, nullptr);
  }

  void removeCallbackOnConnected() {
    _onConnectedCallback?.close();
  }

  void setCallbackOnDisconnected( Function() callback) {
    void disconnectedCallback(simpleble_peripheral_t _, Pointer<Void> __) {
      callback();
    }

    _onDisconnectedCallback ??=
        NativeCallable<PeripheralDisconnectedCallback>.listener(
      disconnectedCallback,
    );

    nativeLibrary.simpleble_peripheral_set_callback_on_disconnected(
        peripheral, _onDisconnectedCallback!.nativeFunction, nullptr);
  }

  void removeCallbackOnDisconnected() {
    _onDisconnectedCallback?.close();
  }
}

typedef PeripheralConnectedCallback = Void Function(
    simpleble_peripheral_t peripheral, Pointer<Void> userdata);
typedef PeripheralDisconnectedCallback = Void Function(
    simpleble_peripheral_t peripheral, Pointer<Void> userdata);
