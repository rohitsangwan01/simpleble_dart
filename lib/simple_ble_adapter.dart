import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:simpleble_dart/generated/generated_bindings.dart';
import 'package:simpleble_dart/simple_ble_peripheral.dart';

class SimpleBleAdapter {
  final simpleble_adapter_t handle;
  final NativeLibrary nativeLibrary;
  SimpleBleAdapter(this.handle, this.nativeLibrary);

  NativeCallable<ScanFoundCallbackNative>? _scanFoundCallback;

  static Function()? _scanStartCallback;
  static Function()? _scanStopCallback;

  // To release the handle
  void dispose() {
    nativeLibrary.simpleble_adapter_release_handle(handle);
  }

  String getIdentifier() {
    final result = nativeLibrary.simpleble_adapter_identifier(handle);
    return result.cast<Utf8>().toDartString();
  }

  String getAddress() {
    final result = nativeLibrary.simpleble_adapter_address(handle);
    return result.cast<Utf8>().toDartString();
  }

  void startScan() {
    nativeLibrary.simpleble_adapter_scan_start(handle);
  }

  void stopScan() {
    nativeLibrary.simpleble_adapter_scan_stop(handle);
  }

  bool adapterScanIsActive() {
    final active = calloc<Bool>();
    nativeLibrary.simpleble_adapter_scan_is_active(handle, active);
    return active.value;
  }

  void adapterScanFor(int timeoutMs) {
    nativeLibrary.simpleble_adapter_scan_for(handle, timeoutMs);
  }

  int adapterScanGetResultsCount() {
    return nativeLibrary.simpleble_adapter_scan_get_results_count(handle);
  }

  int getPairedPeripheralsCount() {
    return nativeLibrary.simpleble_adapter_get_paired_peripherals_count(handle);
  }

  simpleble_peripheral_t adapterScanGetResultsHandle(int index) {
    return nativeLibrary.simpleble_adapter_scan_get_results_handle(
        handle, index);
  }

  simpleble_peripheral_t getPairedPeripheralsHandle(int index) {
    return nativeLibrary.simpleble_adapter_get_paired_peripherals_handle(
        handle, index);
  }

  void setStartScanCallback(Function() callback) {
    _scanStartCallback = callback;
    nativeLibrary.simpleble_adapter_set_callback_on_scan_start(
      handle,
      Pointer.fromFunction<ScanStartCallbackNative>(
          SimpleBleAdapter.scanStartCallback),
      nullptr,
    );
  }

  void setScanStopCallback(Function() callback) {
    _scanStopCallback = callback;
    nativeLibrary.simpleble_adapter_set_callback_on_scan_stop(
      handle,
      Pointer.fromFunction<ScanStartCallbackNative>(
          SimpleBleAdapter.scanStopCallback),
      nullptr,
    );
  }

  void setScanFoundCallback(Function(SimpleBlePeripheral) callback) {
    void scanFoundCallback(simpleble_adapter_t adapter,
        simpleble_peripheral_t peripheral, Pointer<Void> userdata) {
      callback(SimpleBlePeripheral(peripheral, nativeLibrary));
    }

    _scanFoundCallback ??= NativeCallable<ScanFoundCallbackNative>.listener(
      scanFoundCallback,
    );

    nativeLibrary.simpleble_adapter_set_callback_on_scan_found(
        handle, _scanFoundCallback!.nativeFunction, nullptr);
  }

  void removeScanFoundCallback() {
    _scanFoundCallback?.close();
  }

  // Callback proxy
  static void scanStartCallback(
      simpleble_adapter_t adapter, Pointer<Void> userdata) {
    _scanStartCallback?.call();
  }

  static void scanStopCallback(
      simpleble_adapter_t adapter, Pointer<Void> userdata) {
    _scanStopCallback?.call();
  }
}

typedef ScanStartCallbackNative = Void Function(
    Pointer<Void> adapter, Pointer<Void> userdata);

typedef ScanFoundCallbackNative = Void Function(simpleble_adapter_t adapter,
    simpleble_peripheral_t peripheral, Pointer<Void> userdata);

