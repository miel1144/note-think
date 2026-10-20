import 'package:flutter_test/flutter_test.dart';
import 'package:notethink/features/import/paste_import_parser.dart';

void main() {
  group('PasteImportParser.splitBlocks', () {
    test('returns empty for empty input', () {
      final r = PasteImportParser.parse('');
      expect(r.isEmpty, isTrue);
      expect(r.count, 0);
    });

    test('returns empty for whitespace-only input', () {
      expect(PasteImportParser.parse('   \n  \n').isEmpty, isTrue);
    });

    test('single block without separator', () {
      final r = PasteImportParser.parse('Hola mundo');
      expect(r.count, 1);
      expect(r.blocks.first.body, 'Hola mundo');
      expect(r.blocks.first.title, 'Hola mundo');
      expect(r.blocks.first.hasExplicitDate, isFalse);
    });

    test('two blocks separated by ---', () {
      final r = PasteImportParser.parse(
        'Primera nota\n\n---\n\nSegunda nota',
      );
      expect(r.count, 2);
      expect(r.blocks[0].body, 'Primera nota');
      expect(r.blocks[1].body, 'Segunda nota');
    });

    test('single blank line also separates blocks', () {
      final r = PasteImportParser.parse('Una\n\nDos');
      expect(r.count, 2);
      expect(r.blocks[0].body, 'Una');
      expect(r.blocks[1].body, 'Dos');
    });

    test('two or more consecutive blank lines also separate blocks', () {
      final r = PasteImportParser.parse('Una\n\n\n\nDos');
      expect(r.count, 2);
      expect(r.blocks[0].body, 'Una');
      expect(r.blocks[1].body, 'Dos');
    });

    test('a single --- always separates (predictability for paste import)', () {
      final r = PasteImportParser.parse(
        'Sección uno\n---\nlínea decorativa\nSección dos',
      );
      expect(r.count, 2);
    });
  });

  group('PasteImportParser date detection', () {
    test('bracket-prefix [YYYY-MM-DD HH:MM]', () {
      final r = PasteImportParser.parse('[2025-08-15 14:30]\nMi nota');
      expect(r.count, 1);
      final b = r.blocks.first;
      expect(b.hasExplicitDate, isTrue);
      expect(b.explicitDate, DateTime(2025, 8, 15, 14, 30));
      expect(b.body, 'Mi nota');
      expect(b.title, 'Mi nota');
    });

    test('bracket-prefix [YYYY-MM-DD] (no time)', () {
      final r = PasteImportParser.parse('[2025-08-15]\nCuerpo');
      expect(r.blocks.first.explicitDate, DateTime(2025, 8, 15));
    });

    test('bare YYYY-MM-DD HH:MM first line', () {
      final r = PasteImportParser.parse('2025-08-15 14:30\nCuerpo');
      expect(r.blocks.first.hasExplicitDate, isTrue);
      expect(r.blocks.first.explicitDate, DateTime(2025, 8, 15, 14, 30));
    });

    test('markdown # date style', () {
      final r = PasteImportParser.parse('# 2025-08-15 14:30\nCuerpo');
      expect(r.blocks.first.hasExplicitDate, isTrue);
      expect(r.blocks.first.explicitDate, DateTime(2025, 8, 15, 14, 30));
    });

    test('invalid date produces a warning but still parses', () {
      final r = PasteImportParser.parse('[2025-13-45]\nCuerpo');
      expect(r.blocks.first.hasExplicitDate, isFalse);
      expect(r.blocks.first.warning, isNotNull);
      expect(r.blocks.first.warning, contains('Fecha inválida'));
    });

    test('explicit date with seconds', () {
      final r = PasteImportParser.parse('[2025-08-15 14:30:45]\nX');
      expect(r.blocks.first.explicitDate, DateTime(2025, 8, 15, 14, 30, 45));
    });
  });

  group('PasteImportParser body & title inference', () {
    test('title is the first non-empty body line (no blank between date+body)', () {
      final r = PasteImportParser.parse(
        '[2025-08-15 14:30]\nEl título de la nota\nMás detalle',
      );
      expect(r.blocks.first.title, 'El título de la nota');
      expect(r.blocks.first.bodyPlain.first, 'El título de la nota');
    });

    test('empty body yields "Nota importada" placeholder title', () {
      final r = PasteImportParser.parse('[2025-08-15 14:30]\n   \n  ');
      expect(r.blocks.first.title, 'Nota importada');
      expect(r.blocks.first.bodyPlain.isEmpty, isTrue);
      expect(r.blocks.first.bodyDelta, '[]');
    });

    test('title is truncated to 80 chars', () {
      final longTitle = 'a' * 200;
      final r = PasteImportParser.parse(longTitle);
      expect(r.blocks.first.title.length, 80);
    });

    test('multi-line body is preserved in bodyPlain', () {
      final r = PasteImportParser.parse('Línea 1\nLínea 2\nLínea 3');
      expect(r.blocks.first.bodyPlain, ['Línea 1', 'Línea 2', 'Línea 3']);
    });

    test('bodyDelta contains the body JSON-encoded as Quill delta', () {
      final r = PasteImportParser.parse('Hola\nMundo');
      final decoded = r.blocks.first.bodyDelta;
      expect(decoded.contains(r'L\u00ednea'), isFalse); // sanity plain ASCII
      expect(decoded, contains('Hola'));
      expect(decoded, contains('Mundo'));
      expect(decoded, contains(r'\n'));
    });

    });

  group('PasteImportParser multi-block end-to-end', () {
    test('mixed explicit + bare dates + date-less', () {
      final text = '''
[2025-08-15 14:30]
Primera nota con corchetes

---

2025-08-20 09:15
Segunda nota en formato markdown-bare

# 2025-08-25 22:00
Tercera nota con heading markdown

---
Cuarta sin fecha explícita
''';
      final r = PasteImportParser.parse(text);
      expect(r.count, 4);

      expect(r.blocks[0].explicitDate, DateTime(2025, 8, 15, 14, 30));
      expect(r.blocks[0].title, 'Primera nota con corchetes');

      expect(r.blocks[1].explicitDate, DateTime(2025, 8, 20, 9, 15));
      expect(r.blocks[1].title, 'Segunda nota en formato markdown-bare');

      expect(r.blocks[2].explicitDate, DateTime(2025, 8, 25, 22, 0));
      expect(r.blocks[2].title, 'Tercera nota con heading markdown');

      expect(r.blocks[3].hasExplicitDate, isFalse);
      expect(r.blocks[3].title, 'Cuarta sin fecha explícita');
    });

    test('trimming keeps a single block with cleaner body edges', () {
      // Leading/trailing blank lines in the block are dropped; per-blank
      // line edges on the body itself are stripped.
      final r = PasteImportParser.parse(
        '[2025-08-15 14:30]\n  Hola  ',
      );
      expect(r.count, 1);
      expect(r.blocks.first.body, 'Hola');
      expect(r.blocks.first.title, 'Hola');
    });
  });
}
