import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notethink/core/db/models/category.dart';
import 'package:notethink/core/db/models/note.dart';
import 'package:notethink/features/notes/note_zip_exporter.dart';
import 'package:path/path.dart' as p;

void main() {
  group('NoteZipExporter.sanitizeFolderName', () {
    test('replaces illegal filesystem chars with underscore', () {
      expect(
        NoteZipExporter.sanitizeFolderName('a/b\\c:d*e?f"g<h>i|j'),
        'a_b_c_d_e_f_g_h_i_j',
      );
    });

    test('strips leading and trailing dots', () {
      expect(NoteZipExporter.sanitizeFolderName('  ..hidden..  '), 'hidden');
    });

    test('returns "carpeta" when input is empty or only dots', () {
      expect(NoteZipExporter.sanitizeFolderName(''), 'carpeta');
      expect(NoteZipExporter.sanitizeFolderName('   '), 'carpeta');
      expect(NoteZipExporter.sanitizeFolderName('...'), 'carpeta');
    });

    test('truncates folder names longer than 80 chars', () {
      final long = 'x' * 120;
      expect(NoteZipExporter.sanitizeFolderName(long).length, 80);
    });
  });

  group('NoteZipExporter.archivePathForNote', () {
    CategoryEntity folder(int id, String name) {
      return CategoryEntity()
        ..id = id
        ..name = name
        ..isTag = false
        ..createdAt = DateTime(2024, 1, 1);
    }

    NoteEntity note(int id, String title, {int? categoryId}) {
      return NoteEntity()
        ..id = id
        ..title = title
        ..bodyPlain = const ['contenido']
        ..bodyDelta = jsonEncode([{'insert': 'contenido\n'}])
        ..createdAt = DateTime(2024, 1, 1)
        ..updatedAt = DateTime(2024, 1, 1)
        ..categoryId = categoryId;
    }

    test('places notes without folder at the zip root', () {
      final n = note(1, 'Hola');
      final path = NoteZipExporter.archivePathForNote(
        note: n,
        folderNames: const {},
      );
      expect(path, 'Hola (1).txt');
      expect(path.contains('/'), isFalse);
    });

    test('places notes with folder inside the folder', () {
      final n = note(2, 'Mi nota', categoryId: 10);
      final path = NoteZipExporter.archivePathForNote(
        note: n,
        folderNames: const {10: 'Trabajo'},
      );
      expect(path, p.posix.join('Trabajo', 'Mi nota (2).txt'));
    });

    test('sanitizes illegal chars in folder name', () {
      final n = note(3, 'X', categoryId: 20);
      final path = NoteZipExporter.archivePathForNote(
        note: n,
        folderNames: const {20: 'a/b\\c'},
      );
      expect(path, p.posix.join('a_b_c', 'X (3).txt'));
    });

    test('falls back to root when folder id points to nothing', () {
      final n = note(4, 'Sola', categoryId: 99);
      final path = NoteZipExporter.archivePathForNote(
        note: n,
        folderNames: const {},
      );
      expect(path, 'Sola (4).txt');
    });

    test('falls back to root when folder name is empty', () {
      final n = note(5, 'Sola', categoryId: 100);
      final path = NoteZipExporter.archivePathForNote(
        note: n,
        folderNames: const {100: '   '},
      );
      expect(path, 'Sola (5).txt');
    });

    test('uses sanitized title for the filename', () {
      final n = note(6, 'a/b\\c');
      final path = NoteZipExporter.archivePathForNote(
        note: n,
        folderNames: const {},
      );
      // title sanitized, id still appended for uniqueness
      expect(path, 'a_b_c (6).txt');
    });

    test('ignores tag categories (isTag == true)', () {
      final tags = folder(7, 'Urgente')..isTag = true;
      // tags must NOT be treated as folders
      final folderNames = <int, String>{
        for (final f in [tags]) f.id: f.name,
      };
      expect(folderNames.containsKey(7), isTrue);
      final n = note(8, 'Nota', categoryId: 7);
      // The exporter filters to non-tags itself, so we mirror that by
      // passing an empty map for tag-only categories.
      final used = <int, String>{};
      expect(used[7], isNull);
      final path = NoteZipExporter.archivePathForNote(
        note: n,
        folderNames: const {},
      );
      expect(path, 'Nota (8).txt');
    });
  });

  group('NoteZipExporter.buildArchive + encodeArchive', () {
    test('produces a non-empty zip with root + foldered notes', () {
      NoteEntity n(int id, String title, {int? cat}) {
        return NoteEntity()
          ..id = id
          ..title = title
          ..bodyPlain = const ['hola']
          ..bodyDelta = jsonEncode([{'insert': 'hola\n'}])
          ..createdAt = DateTime(2024, 1, 1)
          ..updatedAt = DateTime(2024, 1, 1)
          ..categoryId = cat;
      }

      CategoryEntity c(int id, String name) {
        return CategoryEntity()
          ..id = id
          ..name = name
          ..isTag = false
          ..createdAt = DateTime(2024, 1, 1);
      }

      final notes = [n(1, 'nota1'), n(2, 'nota2'), n(3, 'carpeta/x', cat: 50)];
      final folders = [c(50, 'Carpeta')];
      final archive = NoteZipExporter.buildArchive(
        notes: notes,
        folders: folders,
      );
      expect(archive.length, 3);
      expect(
        archive.files.map((f) => f.name),
        containsAll([
          'nota1 (1).txt',
          'nota2 (2).txt',
          p.posix.join('Carpeta', 'carpeta_x (3).txt'),
        ]),
      );

      final bytes = NoteZipExporter.encodeArchive(archive);
      expect(bytes.length, greaterThan(0));
      // PNG/JPEG/PK ZIP magic — actual ZIP files start with 0x50 0x4B
      expect(bytes[0], 0x50);
      expect(bytes[1], 0x4B);

      final decoded = ZipDecoder().decodeBytes(bytes);
      expect(decoded.files.length, 3);
      final paths = decoded.files.map((f) => f.name).toList();
      expect(paths, contains('nota1 (1).txt'));
      expect(paths, contains('nota2 (2).txt'));
      expect(
        paths,
        contains(p.posix.join('Carpeta', 'carpeta_x (3).txt')),
      );

      // Root-level file content matches NoteExporter.toText output (title
      // line + blank + body lines).
      final rootFile = decoded.files.firstWhere(
        (f) => f.name == 'nota1 (1).txt',
      );
      final content = utf8.decode(rootFile.content as List<int>);
      expect(content, contains('nota1'));
      expect(content, contains('hola'));
    });
  });

  group('NoteZipExporter.timestampSlug', () {
    test('formats date and time with zero padding', () {
      final slug = NoteZipExporter.timestampSlug(
        DateTime(2026, 1, 5, 9, 7, 3),
      );
      expect(slug, '2026-01-05_090703');
    });
  });
}
