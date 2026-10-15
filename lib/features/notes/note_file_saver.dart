import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/db/models/note.dart';
import 'note_exporter.dart';

class NoteFileSaver {
  NoteFileSaver._();

  static const MethodChannel _channel = MethodChannel('note_think/save_file');

  static Future<bool> _needsStoragePermission() async {
    if (!Platform.isAndroid) return false;
    final deviceInfo = DeviceInfoPlugin();
    final android = await deviceInfo.androidInfo;
    return android.version.sdkInt < 29;
  }

  static Future<String> save({
    required NoteEntity note,
    required NoteExportFormat format,
    Uint8List? pdfBytes,
  }) async {
    final filename = NoteExporter.exportFilename(note, format);
    final mimeType = NoteExporter.mimeType(format);
    final Uint8List bytes;
    if (format == NoteExportFormat.pdf) {
      if (pdfBytes == null) {
        throw const SaveException('Faltan los bytes del PDF para guardar');
      }
      bytes = pdfBytes;
    } else {
      final text = format == NoteExportFormat.markdown
          ? NoteExporter.toMarkdown(note)
          : NoteExporter.toText(note);
      if (text.isEmpty) {
        throw const SaveException('La nota no tiene contenido para guardar');
      }
      bytes = Uint8List.fromList(text.codeUnits);
    }
    if (await _needsStoragePermission()) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw const SaveException(
          'Se necesita permiso de almacenamiento para guardar el archivo',
        );
      }
    }
    try {
      final result = await _channel.invokeMethod<String>(
        'saveToDownloads',
        <String, dynamic>{
          'filename': filename,
          'mimeType': mimeType,
          'bytes': bytes,
        },
      );
      return result ?? filename;
    } on PlatformException catch (e) {
      if (e.code == 'SAVE_FAILED') {
        throw SaveException(e.message ?? 'No se pudo guardar');
      }
      rethrow;
    }
  }

  static bool get isAvailable => Platform.isAndroid && !kIsWeb;
}

class SaveException implements Exception {
  const SaveException(this.message);
  final String message;
  @override
  String toString() => message;
}
