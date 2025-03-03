import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'whisper_dart_bindings_generated.dart';

class WhisperLibrary {
  static late WhisperDartBindings binding;
  static String _libName = 'whisper';
  static bool flagFirst = false;
  static bool loaded = false;
  static void init() {
    try {
      /// The dynamic library in which the symbols for [WhisperDartBindings] can be found.
      final DynamicLibrary _dylib = () {
        if (Platform.isMacOS || Platform.isIOS) {
          return DynamicLibrary.open('$_libName.framework/$_libName');
        }
        if (Platform.isAndroid || Platform.isLinux) {
          return DynamicLibrary.open('lib$_libName.so');
        }
        if (Platform.isWindows) {
          return DynamicLibrary.open('$_libName.dll');
        }
        throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
      }();

      /// The bindings to the native functions in [_dylib].
      WhisperLibrary.binding=WhisperDartBindings( _dylib);
      loaded = true;
      flagFirst = true;
    } catch (e) {
      flagFirst = true;
      debugPrint('error loading libmpv: ${e.toString()}');
    }
  }
}
