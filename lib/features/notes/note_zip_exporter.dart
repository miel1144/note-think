import 'dart:io';
import 'dart:ui';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/db/models/category.dart';
import '../../core/db/models/note.dart';
import 'note_exporter.dart';

class NoteZipExporter {
  NoteZipExporter._();

  static const String zipMimeType = 'application/zip';

  static String sanitizeFolderName(String name) {
    final base = name.trim();
    if (base.isEmpty) return 'carpeta';
    final cleaned = base
        .replaceAll(RegExp(r'[\\/:*?"<>|\r\n\t]+'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final collapsed = cleaned.replaceAll(RegExp(r'^\.+|\.+$'), '').trim();
    if (collapsed.isEmpty) return 'carpeta';
    final truncated = collapsed.length > 80
        ? collapsed.substring(0, 80).trimRight()
        : collapsed;
    return truncated;
  }

  static String archivePathForNote({
    required NoteEntity note,
    required Map<int, String> folderNames,
  }) {
    final filename = NoteExporter.exportFilename(note, NoteExportFormat.text);
    final catId = note.categoryId;
    if (catId == null) return filename;
    final folderLabel = folderNames[catId];
    if (folderLabel == null || folderLabel.trim().isEmpty) return filename;
    return p.posix.join(sanitizeFolderName(folderLabel), filename);
  }

  static Archive buildArchive({
    required List<NoteEntity> notes,
    required List<CategoryEntity> folders,
  }) {
    final folderNames = <int, String>{
      for (final f in folders)
        if (!f.isTag) f.id: f.name,
    };
    final archive = Archive();
    for (final note in notes) {
      final text = NoteExporter.toText(note);
      final path = archivePathForNote(note: note, folderNames: folderNames);
      archive.add(ArchiveFile.string(path, text));
    }
    return archive;
  }

  static Uint8List encodeArchive(Archive archive) {
    final encoder = ZipEncoder();
    return encoder.encodeBytes(archive);
  }

  static String timestampSlug(DateTime now) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${now.year}-${pad(now.month)}-${pad(now.day)}'
        '_${pad(now.hour)}${pad(now.minute)}${pad(now.second)}';
  }

  static Future<XFile> writeTempZip({
    required List<NoteEntity> notes,
    required List<CategoryEntity> folders,
    DateTime? now,
  }) async {
    final archive = buildArchive(notes: notes, folders: folders);
    final bytes = encodeArchive(archive);
    final base = await getTemporaryDirectory();
    final dir = Directory(p.join(base.path, 'exports'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final at = now ?? DateTime.now();
    final filename = 'notethink-export-${timestampSlug(at)}.zip';
    final file = File(p.join(dir.path, filename));
    await file.writeAsBytes(bytes, flush: true);
    return XFile(file.path, mimeType: zipMimeType, name: filename);
  }

  static Future<void> share({
    required List<NoteEntity> notes,
    required List<CategoryEntity> folders,
    Rect? sharePositionOrigin,
    DateTime? now,
  }) async {
    final zip = await writeTempZip(
      notes: notes,
      folders: folders,
      now: now,
    );
    final params = ShareParams(
      files: [zip],
      subject: 'Copia de NoteThink',
      sharePositionOrigin: sharePositionOrigin,
    );
    await SharePlus.instance.share(params);
  }
}
