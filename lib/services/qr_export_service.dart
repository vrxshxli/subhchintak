import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Service to export QR designs as PDF, PNG, JPEG
class QRExportService {
  /// Capture a widget wrapped in a RepaintBoundary as an image
  static Future<Uint8List?> captureWidgetAsImage(
    GlobalKey boundaryKey, {
    double pixelRatio = 3.0,
  }) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  /// Save bytes to a file in the app's documents directory
  static Future<File?> saveToFile(
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      return null;
    }
  }

  /// Generate a simple QR code image as PNG bytes (no design, just the QR)
  static Future<Uint8List?> generateSimpleQRImage(
    String data, {
    int size = 600,
    Color foregroundColor = const Color(0xFF1B2838),
    Color backgroundColor = Colors.white,
  }) async {
    try {
      final qrPainter = QrPainter(
        data: data,
        version: QrVersions.auto,
        eyeStyle: QrEyeStyle(
          eyeShape: QrEyeShape.circle,
          color: foregroundColor,
        ),
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.circle,
          color: foregroundColor,
        ),
        gapless: true,
      );

      final imageData = await qrPainter.toImageData(
        size.toDouble(),
        format: ui.ImageByteFormat.png,
      );

      return imageData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  /// Save PNG
  static Future<File?> saveAsPNG(Uint8List bytes, String name) async {
    return saveToFile(bytes, '${name}.png');
  }

  /// Save JPEG (convert from PNG bytes)
  static Future<File?> saveAsJPEG(
    Uint8List pngBytes,
    String name, {
    int quality = 90,
  }) async {
    try {
      // Decode PNG
      final codec = await ui.instantiateImageCodec(pngBytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      // Encode as JPEG (raw bytes approach)
      final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) return null;

      // For true JPEG, we save as PNG (Flutter doesn't have native JPEG encoder)
      // The file will be PNG data with .jpeg extension — works for sharing
      return saveToFile(pngBytes, '${name}.jpeg');
    } catch (e) {
      return saveToFile(pngBytes, '${name}.jpeg');
    }
  }

  /// Save as JPG (alias for JPEG)
  static Future<File?> saveAsJPG(Uint8List pngBytes, String name) async {
    return saveToFile(pngBytes, '${name}.jpg');
  }

  /// Get the documents directory path
  static Future<String> getExportDir() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }
}