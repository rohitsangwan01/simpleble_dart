import 'dart:ffi';

import 'package:simpleble_dart/generated/generated_bindings.dart';
import 'package:simpleble_dart/simple_ble_adapter.dart';

class SimpleBle {
  late final NativeLibrary nativeLibrary;
  late final DynamicLibrary dyLib;

  void init() {
    String? path = binaryPath;
    if (path == null) throw Exception("Platform not supported");
    dyLib = DynamicLibrary.open(path);
    nativeLibrary = NativeLibrary(dyLib);
  }

  void dispose() {
    dyLib.close();
  }

  bool isBluetoothEnabled() =>
      nativeLibrary.simpleble_adapter_is_bluetooth_enabled();

  int getAdapterCount() => nativeLibrary.simpleble_adapter_get_count();

  SimpleBleAdapter getAdapter(int index) {
    var handler = nativeLibrary.simpleble_adapter_get_handle(index);
    return SimpleBleAdapter(handler, nativeLibrary);
  }

  String? get binaryPath => switch (Abi.current()) {
        Abi.macosX64 => "binaries/mac/x86_64/libsimpleble-c.dylib",
        Abi.macosArm64 => "binaries/mac/arm/libsimpleble-c.dylib",
        Abi.windowsX64 => "binaries/win/x86_64/simple_ble.dll",
        Abi.windowsIA32 => "binaries/win/win32/simple_ble.dll",
        Abi.linuxX64 => "binaries/linux/x86_64/libsimpleble-c.so",
        _ => null,
      };
}
