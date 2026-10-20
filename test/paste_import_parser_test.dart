import 'package:flutter_test/flutter_test.dart';
import 'package:notethink/features/import/paste_import_parser.dart';

void main() {
  group('PasteImportParser block separation', () {
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

    test('two blocks separated by 5 hyphens', () {
      final r = PasteImportParser.parse('Primera nota\n\n-----\n\nSegunda');
      expect(r.count, 2);
      expect(r.blocks[0].body, 'Primera nota');
      expect(r.blocks[1].body, 'Segunda');
    });

    test('6 or more hyphens also separates (forgiving on the long side)', () {
      expect(PasteImportParser.parse('A\n------\nB').count, 2);
      expect(PasteImportParser.parse('A\n--------\nB').count, 2);
      expect(PasteImportParser.parse('A\n     -----\nB').count, 2);
    });

    test('3 or 4 hyphens do NOT separate (markdown rule stays content)', () {
      final r3 = PasteImportParser.parse('A\n---\nB');
      expect(r3.count, 1);
      expect(r3.blocks.first.body, 'A\n---\nB');

      final r4 = PasteImportParser.parse('A\n----\nB');
      expect(r4.count, 1);
      expect(r4.blocks.first.body, 'A\n----\nB');
    });

    test('blank lines do NOT separate — they are paragraph breaks', () {
      final r = PasteImportParser.parse('Para uno\n\nPara dos');
      expect(r.count, 1);
      expect(r.blocks.first.body, 'Para uno\n\nPara dos');
      expect(r.blocks.first.bodyPlain, ['Para uno', '', 'Para dos']);
    });

    test('3 consecutive blank lines stay internal too', () {
      final r = PasteImportParser.parse('Una\n\n\n\nDos');
      expect(r.count, 1);
      expect(r.blocks.first.body, 'Una\n\n\n\nDos');
    });

    test('trailing ----- terminates the last note without a phantom', () {
      final r = PasteImportParser.parse('Nota A\n\n-----');
      expect(r.count, 1);
      expect(r.blocks.first.body, 'Nota A');
    });

    test('leading ----- does not create an empty first note', () {
      final r = PasteImportParser.parse('-----\nNota A');
      expect(r.count, 1);
      expect(r.blocks.first.body, 'Nota A');
    });

    test('multi-paragraph note survives intact (the reason for this design)', () {
      const body = '''
Compras

- pan
- leche

Pendientes

- llamar al dentista
- pagar el alquiler''';
      final r = PasteImportParser.parse(body);
      expect(r.count, 1);
      expect(r.blocks.first.bodyPlain, [
        'Compras',
        '',
        '- pan',
        '- leche',
        '',
        'Pendientes',
        '',
        '- llamar al dentista',
        '- pagar el alquiler',
      ]);
      expect(r.blocks.first.title, 'Compras');
    });

    test('blank lines around a ----- are trimmed, not kept', () {
      final r = PasteImportParser.parse('\n\nNota A\n\n\n-----\n\n\nNota B\n\n');
      expect(r.count, 2);
      expect(r.blocks[0].body, 'Nota A');
      expect(r.blocks[1].body, 'Nota B');
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

    test('date line followed by a blank line before the body', () {
      final r = PasteImportParser.parse('[2025-08-15 14:30]\n\nPrimera línea\n\nSegunda');
      expect(r.count, 1);
      expect(r.blocks.first.explicitDate, DateTime(2025, 8, 15, 14, 30));
      expect(r.blocks.first.title, 'Primera línea');
      expect(r.blocks.first.body, 'Primera línea\n\nSegunda');
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

    test('rejects out-of-range hour instead of normalizing', () {
      final r = PasteImportParser.parse('[2025-08-15 25:00]\nX');
      expect(r.blocks.first.hasExplicitDate, isFalse);
      expect(r.blocks.first.warning, isNotNull);
    });
  });

  group('PasteImportParser body & title inference', () {
    test('title is the first non-empty body line', () {
      final r = PasteImportParser.parse('El título de la nota\nMás detalle');
      expect(r.blocks.first.title, 'El título de la nota');
      expect(r.blocks.first.bodyPlain.first, 'El título de la nota');
    });

    test('empty body yields "Nota importada" placeholder title', () {
      final r = PasteImportParser.parse('[2025-08-15 14:30]\n');
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
      expect(decoded, contains('Hola'));
      expect(decoded, contains('Mundo'));
      expect(decoded, contains(r'\n'));
    });

    test('trimming keeps a single block with cleaner body edges', () {
      final r = PasteImportParser.parse('[2025-08-15 14:30]\n  Hola  ');
      expect(r.count, 1);
      expect(r.blocks.first.body, 'Hola');
      expect(r.blocks.first.title, 'Hola');
    });
  });

  group('PasteImportParser multi-block end-to-end', () {
    test('blank lines keep content in the same note, ----- splits', () {
      const text = '''
[2025-08-15 14:30]
Primera nota con corchetes

segundo párrafo de la primera

-----
2025-08-20 09:15
Segunda nota en formato bare

# 2025-08-25 22:00
Este heading NO corta: sigue siendo la misma nota

-----
Cuarta sin fecha explícita
''';
      final r = PasteImportParser.parse(text);
      expect(r.count, 3);

      expect(r.blocks[0].explicitDate, DateTime(2025, 8, 15, 14, 30));
      expect(r.blocks[0].title, 'Primera nota con corchetes');
      expect(r.blocks[0].bodyPlain.length, 3);

      expect(r.blocks[1].explicitDate, DateTime(2025, 8, 20, 9, 15));
      expect(r.blocks[1].title, 'Segunda nota en formato bare');
      expect(r.blocks[1].body, contains('# 2025-08-25 22:00'));

      expect(r.blocks[2].hasExplicitDate, isFalse);
      expect(r.blocks[2].title, 'Cuarta sin fecha explícita');
    });

    test('four notes with all three date formats', () {
      const text = '[2025-01-01 08:00]\nA\n\n-----\n'
          '2025-02-02 09:30\nB\n\n-----\n'
          '# 2025-03-03 10:15\nC\n\n-----\nD';
      final r = PasteImportParser.parse(text);
      expect(r.count, 4);
      expect(r.blocks[0].explicitDate, DateTime(2025, 1, 1, 8, 0));
      expect(r.blocks[1].explicitDate, DateTime(2025, 2, 2, 9, 30));
      expect(r.blocks[2].explicitDate, DateTime(2025, 3, 3, 10, 15));
      expect(r.blocks[3].hasExplicitDate, isFalse);
      expect(r.blocks[3].title, 'D');
    });

    test('nonEmptyCount ignores blocks whose body is only a date', () {
      const text = '[2025-01-01 08:00]\n\n-----\nnota real';
      final r = PasteImportParser.parse(text);
      expect(r.count, 2);
      expect(r.nonEmptyCount, 1);
    });
  });
}