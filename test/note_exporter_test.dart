import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:notethink/core/db/models/note.dart';
import 'package:notethink/features/notes/note_exporter.dart';

void main() {
  group('NoteExporter.toText', () {
    test('returns only title when body is empty', () {
      final note = _note(title: 'Hola', bodyPlain: const [], bodyDelta: '[]');
      expect(NoteExporter.toText(note), 'Hola');
    });

    test('joins lines with double newline from title and body', () {
      final note = _note(
        title: 'Lista',
        bodyPlain: const ['uno', 'dos'],
        bodyDelta: '[]',
      );
      expect(NoteExporter.toText(note), 'Lista\n\nuno\ndos');
    });

    test('skips empty lines in body', () {
      final note = _note(
        title: '',
        bodyPlain: const ['a', '', '  ', 'b'],
        bodyDelta: '[]',
      );
      expect(NoteExporter.toText(note), 'a\nb');
    });
  });

  group('NoteExporter.toMarkdown', () {
    test('plain text becomes a heading + paragraph', () {
      final note = _note(
        title: 'Mi nota',
        bodyPlain: const ['hola mundo'],
        bodyDelta: jsonEncode([
          {'insert': 'hola mundo\n'},
        ]),
      );
      final md = NoteExporter.toMarkdown(note);
      expect(md, '# Mi nota\n\nhola mundo');
    });

    test('renders bold and italic as markdown', () {
      final note = _note(
        title: '',
        bodyPlain: const [],
        bodyDelta: jsonEncode([
          {
            'insert': 'normal **bold** _italic_',
          },
          {
            'insert': ' final',
            'attributes': {'bold': true, 'italic': true},
          },
          {'insert': '\n'},
        ]),
      );
      final md = NoteExporter.toMarkdown(note);
      expect(md, 'normal **bold** _italic_**_ final_**');
    });

    test('renders H1 header as #', () {
      final note = _note(
        title: 'S',
        bodyPlain: const ['cuerpo'],
        bodyDelta: jsonEncode([
          {
            'insert': 'Título',
          },
          {
            'insert': '\n',
            'attributes': {'header': 1},
          },
          {'insert': 'cuerpo\n'},
        ]),
      );
      final md = NoteExporter.toMarkdown(note);
      expect(md, '# S\n\n# Título\n\ncuerpo');
    });

    test('renders bullet list', () {
      final note = _note(
        title: '',
        bodyPlain: const [],
        bodyDelta: jsonEncode([
          {
            'insert': 'uno',
          },
          {
            'insert': '\n',
            'attributes': {'list': 'bullet'},
          },
          {
            'insert': 'dos',
          },
          {
            'insert': '\n',
            'attributes': {'list': 'bullet'},
          },
        ]),
      );
      final md = NoteExporter.toMarkdown(note);
      expect(md, '- uno\n\n- dos');
    });

    test('renders ordered list', () {
      final note = _note(
        title: '',
        bodyPlain: const [],
        bodyDelta: jsonEncode([
          {
            'insert': 'primero',
          },
          {
            'insert': '\n',
            'attributes': {'list': 'ordered'},
          },
          {
            'insert': 'segundo',
          },
          {
            'insert': '\n',
            'attributes': {'list': 'ordered'},
          },
        ]),
      );
      final md = NoteExporter.toMarkdown(note);
      expect(md, '1. primero\n\n1. segundo');
    });

    test('renders blockquote', () {
      final note = _note(
        title: '',
        bodyPlain: const [],
        bodyDelta: jsonEncode([
          {
            'insert': 'citame',
          },
          {
            'insert': '\n',
            'attributes': {'blockquote': true},
          },
        ]),
      );
      final md = NoteExporter.toMarkdown(note);
      expect(md, '> citame');
    });

    test('renders link', () {
      final note = _note(
        title: '',
        bodyPlain: const [],
        bodyDelta: jsonEncode([
          {
            'insert': 'doku',
            'attributes': {'link': 'https://example.com'},
          },
          {'insert': '\n'},
        ]),
      );
      final md = NoteExporter.toMarkdown(note);
      expect(md, '[doku](https://example.com)');
    });

    test('renders image embed', () {
      final note = _note(
        title: '',
        bodyPlain: const [],
        bodyDelta: jsonEncode([
          {
            'insert': {
              'image': '/storage/img.png',
              'caption': 'Mi foto',
            },
          },
          {'insert': '\n'},
        ]),
      );
      final md = NoteExporter.toMarkdown(note);
      expect(md, '![Mi foto](/storage/img.png)');
    });

    test('renders check lists', () {
      final note = _note(
        title: '',
        bodyPlain: const [],
        bodyDelta: jsonEncode([
          {
            'insert': 'hecho',
          },
          {
            'insert': '\n',
            'attributes': {'list': 'checked'},
          },
          {
            'insert': 'pendiente',
          },
          {
            'insert': '\n',
            'attributes': {'list': 'unchecked'},
          },
        ]),
      );
      final md = NoteExporter.toMarkdown(note);
      expect(md, '- [x] hecho\n\n- [ ] pendiente');
    });

    test('falls back to text when delta is invalid', () {
      final note = _note(
        title: 'T',
        bodyPlain: const ['linea'],
        bodyDelta: 'no es json valido',
      );
      final md = NoteExporter.toMarkdown(note);
      expect(md, 'T\n\nlinea');
    });
  });

  group('NoteExporter.toPdf', () {
    test('produces non-empty PDF for a note with text', () async {
      final note = _note(
        title: 'Mi nota',
        bodyPlain: const ['hola', 'mundo'],
        bodyDelta: jsonEncode([
          {'insert': 'hola mundo\n'},
        ]),
      );
      final bytes = await NoteExporter.toPdf(note);
      expect(bytes.length, greaterThan(100));
      expect(String.fromCharCodes(bytes.sublist(0, 4)), '%PDF');
    });

    test('produces empty bytes for an empty note', () async {
      final note = _note(
        title: '',
        bodyPlain: const [],
        bodyDelta: '[]',
      );
      final bytes = await NoteExporter.toPdf(note);
      expect(bytes, isEmpty);
    });

    test('includes title in PDF', () async {
      final note = _note(
        title: 'TituloVisible',
        bodyPlain: const ['cuerpo'],
        bodyDelta: jsonEncode([
          {'insert': 'cuerpo\n'},
        ]),
      );
      final bytes = await NoteExporter.toPdf(note);
      expect(bytes.length, greaterThan(1000));
      final header = String.fromCharCodes(bytes.sublist(0, 5));
      expect(header, '%PDF-');
    });
  });
}

NoteEntity _note({
  required String title,
  required List<String> bodyPlain,
  required String bodyDelta,
}) {
  return NoteEntity()
    ..title = title
    ..bodyPlain = bodyPlain
    ..bodyDelta = bodyDelta
    ..createdAt = DateTime(2024, 1, 1)
    ..updatedAt = DateTime(2024, 1, 1);
}
