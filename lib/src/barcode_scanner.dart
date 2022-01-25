import 'package:combined_barcode_scanner/combined_barcode_scanner.dart';
import 'package:flutter/widgets.dart';

/// Base for custom bar code scanners
///
/// Capabilities:
/// Scanners expose their capabilities via the [properties] getter.
///
/// Flow:
///   - Scanner is passed to the [BarcodeScannerWidget]
///   - [BarcodeScanner.configure] is called and awaited
///   - [BarcodeScanner.buildUI] is called if-and-only-if [properties.hasUI] is true
///   - [BarcodeScanner.dispose] is called when the containing widget is disposed
abstract class BarcodeScanner {
  /// The properties of this scanner. This getter can be called a lot, ensure
  /// it is performant
  ScannerProperties get properties;

  /// The controller controlling the scanner. Will not be called until
  /// [configure] completes
  BarcodeScannerController get controller;

  /// Configures the scanner with the provided parameters
  ///
  /// This method can be called multiple times
  Future<void> configure({
    required ScannerConfiguration configuration,
    required ValueChanged<BarcodeScanResult> onScan,
  });

  /// Called when the scanner is no longer required
  void dispose();

  /// Called a containing widget needs to display the UI of this scanner
  /// Will not be called if [properties.hasUI] is false.
  ///
  /// If it is called, it will always be caleld AFTER [configure] has completed
  Widget? buildUI(
    ScannerConfiguration configuration,
    BuildContext context,
  );
}

/// Controller interface for [BarcodeScanner]
abstract class BarcodeScannerController {
  /// Whether the device can switch between cameras (for example front vs back)
  Future<bool> get supportsSwitchingCamera async => false;

  /// Whether the device has a torch that is on
  bool get torchState => false;

  /// Switch between cameras (if supported. see [supportsSwitchingCamera])
  void toggleCamera() {}

  /// Switch the torch on/off (see [torchState] for current state)
  void toggleTorch() {}

  /// Starts the scanner if it is not running
  void start();

  /// Pauses the scanner, no events should be reported until
  /// [start] is called
  void pause();
}

/// Hold the result of a successful scan.
///
/// This data class contains toMap/fromMap methods that return a map that is
/// safe to use in platform channels (or state restoration)
@immutable
class BarcodeScanResult {
  /// The value of the barcode
  final String code;

  /// The format of the barcode if reported by the library
  final BarcodeFormat? format;

  const BarcodeScanResult({
    required this.code,
    required this.format,
  });

  @override
  String toString() {
    return 'BarcodeScanResult{code: $code, format: $format}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarcodeScanResult &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          format == other.format;

  @override
  int get hashCode => code.hashCode ^ format.hashCode;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'code': code,
      'format': format?.index,
    };
  }

  factory BarcodeScanResult.fromMap(Map<String, dynamic> map) {
    final formatCode = map['format'] as int?;
    final format = formatCode == null ? null : BarcodeFormat.values[formatCode];
    return BarcodeScanResult(
      code: map['code'] as String,
      format: format,
    );
  }
}
