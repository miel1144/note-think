import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../core/db/models/note.dart';
import 'note_file_saver.dart';

enum NoteExportFormat { markdown, text, pdf }

class NoteExporter {
  NoteExporter._();

  static Future<Directory> _tempDir() async {
    final base = await getTemporaryDirectory();
    final dir = Directory(p.join(base.path, 'exports'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static String _safeFileBase(String title) {
    final base = title.trim().isEmpty ? 'nota' : title.trim();
    final cleaned = base
        .replaceAll(RegExp(r'[\\/:*?"<>|]+'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final collapsed = cleaned.replaceAll(RegExp(r'^\.+|\.+$'), '').trim();
    if (collapsed.isEmpty) return 'nota';
    final truncated = collapsed.length > 80
        ? collapsed.substring(0, 80).trimRight()
        : collapsed;
    return truncated;
  }

  static String _fileName(NoteEntity note, NoteExportFormat format) {
    final ext = switch (format) {
      NoteExportFormat.markdown => 'md',
      NoteExportFormat.text => 'txt',
      NoteExportFormat.pdf => 'pdf',
    };
    return '${_safeFileBase(note.title)} (${note.id}).$ext';
  }

  static String exportFilename(NoteEntity note, NoteExportFormat format) {
    return _fileName(note, format);
  }

  static String mimeType(NoteExportFormat format) {
    return switch (format) {
      NoteExportFormat.markdown => 'text/markdown',
      NoteExportFormat.text => 'text/plain',
      NoteExportFormat.pdf => 'application/pdf',
    };
  }

  static String toText(NoteEntity note) {
    final lines = note.bodyPlain
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final buf = StringBuffer();
    final title = note.title.trim();
    if (title.isNotEmpty) {
      buf.writeln(title);
      if (lines.isNotEmpty) buf.writeln();
    }
    buf.writeln(lines.join('\n'));
    return buf.toString().trimRight();
  }

  static String toMarkdown(NoteEntity note) {
    final operations = _parseDelta(note.bodyDelta);
    if (operations.isEmpty) {
      return toText(note);
    }
    final buf = StringBuffer();
    final title = note.title.trim();
    if (title.isNotEmpty) {
      buf.writeln('# $title');
      buf.writeln();
    }
    final lines = _renderLines(operations);
    for (final line in lines) {
      if (line.isBlockSeparator) {
        buf.writeln();
        continue;
      }
      final prefix = line.blockPrefix;
      final rendered = _renderInline(line.runs, inCodeBlock: line.inCodeBlock);
      if (rendered.isEmpty && prefix == null) {
        buf.writeln();
        continue;
      }
      if (prefix != null) {
        buf.writeln('$prefix$rendered');
      } else {
        buf.writeln(rendered);
      }
    }
    return buf.toString().trimRight();
  }

  static Future<Uint8List> toPdf(NoteEntity note) async {
    final operations = _parseDelta(note.bodyDelta);
    final lines = operations.isEmpty
        ? <_RenderedLine>[]
        : await _renderLinesForPdf(operations);
    final widgets = <pw.Widget>[];
    final title = note.title.trim();
    if (title.isNotEmpty) {
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 12),
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      );
    }
    for (final line in lines) {
      if (line.isBlockSeparator) {
        widgets.add(pw.SizedBox(height: 6));
        continue;
      }
      final widget = await _lineToPdfWidget(line);
      if (widget != null) widgets.add(widget);
    }
    if (widgets.isEmpty) {
      return Uint8List(0);
    }
    final doc = pw.Document(
      title: title.isEmpty ? 'Nota' : title,
      author: 'NoteThink',
    );
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginLeft: 48,
          marginRight: 48,
          marginTop: 48,
          marginBottom: 48,
        ),
        build: (context) => widgets,
      ),
    );
    return doc.save();
  }

  static Future<pw.Widget?> _lineToPdfWidget(_RenderedLine line) async {
    final block = line.blockAttrs;
    if (line.runs.length == 1 &&
        line.runs.first.text == '```\n' &&
        block != null &&
        block['code-block'] == true) {
      return pw.SizedBox.shrink();
    }
    final text = line.runs.map((r) => r.text).join();
    if (line.inCodeBlock) {
      return pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromInt(0xFFEEEEEE),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            font: pw.Font.courier(),
            fontSize: 10,
          ),
        ),
      );
    }
    if (block != null) {
      if (block['header'] is int) {
        final level = (block['header'] as int).clamp(1, 6);
        final size = switch (level) {
          1 => 22.0,
          2 => 18.0,
          3 => 15.0,
          4 => 13.0,
          _ => 12.0,
        };
        return pw.Padding(
          padding: const pw.EdgeInsets.only(top: 6, bottom: 4),
          child: pw.Text(
            text,
            style: pw.TextStyle(fontSize: size, fontWeight: pw.FontWeight.bold),
          ),
        );
      }
      if (block['blockquote'] == true) {
        return pw.Container(
          padding: const pw.EdgeInsets.only(left: 12, top: 4, bottom: 4),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              left: pw.BorderSide(color: PdfColors.grey400, width: 3),
            ),
          ),
          child: pw.Text(
            text,
            style: const pw.TextStyle(
              fontSize: 11,
              color: PdfColors.grey700,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        );
      }
      final list = block['list'];
      if (list is String) {
        final prefix = switch (list) {
          'checked' => '[x] ',
          'unchecked' => '[ ] ',
          'ordered' => '1. ',
          _ => '• ',
        };
        return pw.Padding(
          padding: const pw.EdgeInsets.only(left: 12, top: 1, bottom: 1),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: 24,
                child: pw.Text(
                  prefix,
                  style: const pw.TextStyle(fontSize: 11),
                ),
              ),
              pw.Expanded(
                child: await _inlineRunsToRichText(line.runs),
              ),
            ],
          ),
        );
      }
    }
    return await _inlineRunsToRichText(line.runs);
  }

  static Future<pw.Widget> _inlineRunsToRichText(List<_InlineRun> runs) async {
    if (runs.isEmpty) return pw.SizedBox.shrink();
    final children = <pw.InlineSpan>[];
    for (final run in runs) {
      if (run.imageBytes != null) {
        try {
          final image = pw.MemoryImage(run.imageBytes!);
          children.add(
            pw.WidgetSpan(
              child: pw.Container(
                margin: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Image(
                  image,
                  fit: pw.BoxFit.contain,
                  height: 220,
                ),
              ),
            ),
          );
        } catch (_) {
          children.add(_textSpan(run.text, run.attrs));
        }
        continue;
      }
      children.add(_textSpan(run.text, run.attrs));
    }
    return pw.RichText(
      text: pw.TextSpan(children: children),
    );
  }

  static pw.InlineSpan _textSpan(String text, Map<String, dynamic> attrs) {
    final link = attrs['link'];
    if (link is String && link.isNotEmpty) {
      return pw.TextSpan(
        text: text,
        style: pw.TextStyle(
          color: PdfColors.blue700,
          decoration: pw.TextDecoration.underline,
        ),
      );
    }
    var style = pw.TextStyle(fontSize: 11);
    if (attrs['bold'] == true) {
      style = style.copyWith(fontWeight: pw.FontWeight.bold);
    }
    if (attrs['italic'] == true) {
      style = style.copyWith(fontStyle: pw.FontStyle.italic);
    }
    if (attrs['strike'] == true) {
      style = style.copyWith(decoration: pw.TextDecoration.lineThrough);
    }
    if (attrs['underline'] == true) {
      style = style.copyWith(decoration: pw.TextDecoration.underline);
    }
    if (attrs['code'] == true) {
      style = style.copyWith(
        font: pw.Font.courier(),
        background: pw.BoxDecoration(color: PdfColors.grey200),
      );
    }
    return pw.TextSpan(text: text, style: style);
  }

  static Future<XFile> exportFile(
    NoteEntity note,
    NoteExportFormat format,
  ) async {
    final dir = await _tempDir();
    final filename = _fileName(note, format);
    final file = File(p.join(dir.path, filename));
    if (format == NoteExportFormat.pdf) {
      final bytes = await toPdf(note);
      if (bytes.isEmpty) {
        throw const ExportEmptyException();
      }
      await file.writeAsBytes(bytes, flush: true);
    } else {
      final text = format == NoteExportFormat.markdown
          ? toMarkdown(note)
          : toText(note);
      if (text.isEmpty) {
        throw const ExportEmptyException();
      }
      await file.writeAsString(text, flush: true);
    }
    return XFile(file.path, mimeType: mimeType(format), name: filename);
  }

  static Future<void> share(
    NoteEntity note, {
    required NoteExportFormat format,
    Rect? sharePositionOrigin,
  }) async {
    final file = await exportFile(note, format);
    final params = ShareParams(
      files: [file],
      subject: note.title.trim().isEmpty ? 'Nota' : note.title.trim(),
      sharePositionOrigin: sharePositionOrigin,
    );
    await SharePlus.instance.share(params);
  }

  static Future<void> showExportSheet(
    BuildContext context,
    NoteEntity note, {
    Rect? sharePositionOrigin,
  }) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : sharePositionOrigin;
    final format = await showModalBottomSheet<NoteExportFormat>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Markdown (.md)'),
                subtitle: const Text(
                  'Con formato: títulos, listas, negritas, etc.',
                ),
                onTap: () => Navigator.pop(sheetContext, NoteExportFormat.markdown),
              ),
              ListTile(
                leading: const Icon(Icons.text_snippet_outlined),
                title: const Text('Texto plano (.txt)'),
                subtitle: const Text('Solo el contenido, sin formato'),
                onTap: () => Navigator.pop(sheetContext, NoteExportFormat.text),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('PDF'),
                subtitle: const Text(
                  'Documento con imágenes embebidas',
                ),
                onTap: () => Navigator.pop(sheetContext, NoteExportFormat.pdf),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (format == null) return;
    if (!context.mounted) return;
    final action = await _showActionSheet(context);
    if (action == null) return;
    if (!context.mounted) return;
    if (action == _ExportAction.share) {
      try {
        await share(note, format: format, sharePositionOrigin: origin);
      } on ExportEmptyException {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La nota no tiene contenido para exportar'),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo exportar: $e')),
        );
      }
    } else {
      try {
        await _saveToDevice(context, note, format);
      } on ExportEmptyException {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La nota no tiene contenido para exportar'),
          ),
        );
      } on SaveException catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo guardar: $e')),
        );
      }
    }
  }

  static Future<_ExportAction?> _showActionSheet(BuildContext context) {
    return showModalBottomSheet<_ExportAction>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.ios_share),
                title: const Text('Compartir'),
                subtitle: const Text('Abrir hoja de compartir de Android'),
                onTap: () => Navigator.pop(sheetContext, _ExportAction.share),
              ),
              if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: const Text('Guardar en Descargas'),
                  subtitle: const Text('Downloads/NoteThink/'),
                  onTap: () => Navigator.pop(sheetContext, _ExportAction.save),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _saveToDevice(
    BuildContext context,
    NoteEntity note,
    NoteExportFormat format,
  ) async {
    Uint8List? pdfBytes;
    if (format == NoteExportFormat.pdf) {
      pdfBytes = await toPdf(note);
      if (pdfBytes.isEmpty) {
        throw const ExportEmptyException();
      }
    }
    final filename = await NoteFileSaver.save(
      note: note,
      format: format,
      pdfBytes: pdfBytes,
    );
    if (!context.mounted) return;
    final displayName = filename.split('/').last;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Guardado en Descargas/$displayName'),
      ),
    );
  }

  static List<Operation> _parseDelta(String bodyDelta) {
    if (bodyDelta.isEmpty) return const [];
    try {
      final raw = jsonDecode(bodyDelta);
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((m) => Operation.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static List<_RenderedLine> _renderLines(List<Operation> operations) {
    return _renderLinesSync(operations, imageBytes: const {});
  }

  static Future<List<_RenderedLine>> _renderLinesForPdf(
    List<Operation> operations,
  ) async {
    final imagePaths = _collectImagePaths(operations);
    final imageBytes = <String, Uint8List>{};
    for (final entry in imagePaths.entries) {
      try {
        final file = File(entry.value);
        if (await file.exists()) {
          imageBytes[entry.value] = await file.readAsBytes();
        }
      } catch (_) {
        // ignore unreadable image
      }
    }
    return _renderLinesSync(operations, imageBytes: imageBytes);
  }

  static Map<int, String> _collectImagePaths(List<Operation> operations) {
    final map = <int, String>{};
    var index = 0;
    for (final op in operations) {
      if (op.isDelete) continue;
      final data = op.data;
      if (op.isInsert && data is Map) {
        final image = data['image'];
        if (image is String && image.isNotEmpty) {
          map[index] = image;
        }
        index++;
      }
    }
    return map;
  }

  static List<_RenderedLine> _renderLinesSync(
    List<Operation> operations, {
    required Map<String, Uint8List> imageBytes,
  }) {
    final lines = <_RenderedLine>[];
    final current = <_InlineRun>[];
    Map<String, dynamic>? pendingBlockAttrs;
    var inCodeBlock = false;

    void flushLine() {
      if (current.isEmpty && pendingBlockAttrs == null) {
        lines.add(_RenderedLine.empty());
        pendingBlockAttrs = null;
        return;
      }
      final prefix = _blockPrefix(pendingBlockAttrs, inCodeBlock: inCodeBlock);
      lines.add(
        _RenderedLine(
          runs: List.of(current),
          blockPrefix: prefix,
          blockAttrs: pendingBlockAttrs == null
              ? null
              : Map<String, dynamic>.from(pendingBlockAttrs!),
          inCodeBlock: inCodeBlock,
        ),
      );
      current.clear();
      pendingBlockAttrs = null;
    }

    for (final op in operations) {
      if (op.isDelete) continue;
      final data = op.data;
      if (op.isInsert) {
        if (data is Map) {
          final image = data['image'];
          if (image is String && image.isNotEmpty) {
            final bytes = imageBytes[image];
            if (bytes != null) {
              current.add(_InlineRun.image(bytes));
            } else {
              final embed = _embedToMarkdown(data);
              if (embed.isNotEmpty) current.add(_InlineRun.text(embed));
            }
            continue;
          }
          final embed = _embedToMarkdown(data);
          if (embed.isNotEmpty) {
            current.add(_InlineRun.text(embed));
          }
          continue;
        }
        if (data is! String) continue;
        final opAttrs = op.attributes ?? const <String, dynamic>{};
        final isBlockOp = _isBlockAttrs(opAttrs);
        if (isBlockOp) {
          pendingBlockAttrs = Map<String, dynamic>.from(opAttrs);
          if (opAttrs['code-block'] == true) {
            inCodeBlock = true;
            current.add(_InlineRun.text('```\n'));
            lines.add(
              _RenderedLine(
                runs: List.of(current),
                inCodeBlock: true,
              ),
            );
            current.clear();
            pendingBlockAttrs = null;
            continue;
          }
        }
        final inlineAttrs = isBlockOp
            ? const <String, dynamic>{}
            : Map<String, dynamic>.from(opAttrs);
        final chars = data.split('');
        for (final ch in chars) {
          if (ch == '\n') {
            if (inCodeBlock) {
              current.add(_InlineRun.text('\n'));
              pendingBlockAttrs ??= {'code-block': true};
              flushLine();
              inCodeBlock = false;
              continue;
            }
            flushLine();
            lines.add(_RenderedLine.empty());
            continue;
          }
          current.add(_InlineRun(ch, inlineAttrs));
        }
        continue;
      }
    }
    if (current.isNotEmpty || pendingBlockAttrs != null) {
      flushLine();
    }
    return lines;
  }

  static bool _isBlockAttrs(Map<String, dynamic> attrs) {
    return attrs['header'] != null ||
        attrs['list'] != null ||
        attrs['blockquote'] == true ||
        attrs['code-block'] == true;
  }

  static String? _blockPrefix(
    Map<String, dynamic>? attrs, {
    required bool inCodeBlock,
  }) {
    if (attrs == null || attrs.isEmpty) return null;
    if (attrs['header'] is int) {
      final level = (attrs['header'] as int).clamp(1, 6);
      return '${'#' * level} ';
    }
    if (attrs['blockquote'] == true) return '> ';
    final list = attrs['list'];
    if (list is String) {
      switch (list) {
        case 'checked':
          return '- [x] ';
        case 'unchecked':
          return '- [ ] ';
        case 'ordered':
          return '1. ';
        case 'bullet':
          return '- ';
        default:
          return '- ';
      }
    }
    return null;
  }

  static String _renderInline(
    List<_InlineRun> runs, {
    required bool inCodeBlock,
  }) {
    if (runs.isEmpty) return '';
    if (inCodeBlock) {
      return runs.map((r) => r.text).join();
    }
    final buf = StringBuffer();
    var groupText = StringBuffer();
    Map<String, dynamic>? groupAttrs;
    for (final run in runs) {
      if (groupAttrs == null) {
        groupText.write(run.text);
        groupAttrs = run.attrs;
        continue;
      }
      if (_sameInlineAttrs(groupAttrs, run.attrs)) {
        groupText.write(run.text);
        continue;
      }
      buf.write(_wrapInline(groupText.toString(), groupAttrs));
      groupText
        ..clear()
        ..write(run.text);
      groupAttrs = run.attrs;
    }
    if (groupAttrs != null) {
      buf.write(_wrapInline(groupText.toString(), groupAttrs));
    }
    return buf.toString();
  }

  static bool _sameInlineAttrs(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
  ) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (entry.value is String) {
        if (b[entry.key] != entry.value) return false;
      } else if (entry.value != b[entry.key]) {
        return false;
      }
    }
    return true;
  }

  static String _wrapInline(String text, Map<String, dynamic> attrs) {
    if (text.isEmpty || attrs.isEmpty) return text;
    var out = text;
    if (attrs['code'] == true) {
      out = '`$out`';
    }
    if (attrs['italic'] == true) {
      out = '_${out}_';
    }
    if (attrs['bold'] == true) {
      out = '**$out**';
    }
    if (attrs['strike'] == true) {
      out = '~~$out~~';
    }
    if (attrs['underline'] == true) {
      out = '<u>$out</u>';
    }
    if (attrs['link'] is String) {
      out = '[$out](${attrs['link']})';
    }
    return out;
  }

  static String _embedToMarkdown(Map data) {
    if (data.isEmpty) return '';
    final image = data['image'];
    if (image is String && image.isNotEmpty) {
      final caption = data['caption'];
      final alt = caption is String && caption.isNotEmpty
          ? caption
          : (caption is num ? caption.toString() : 'imagen');
      return '![${_escapeAlt(alt)}]($image)';
    }
    final video = data['video'];
    if (video is String && video.isNotEmpty) {
      return '🎬 $video';
    }
    return '';
  }

  static String _escapeAlt(String text) {
    return text
        .replaceAll('[', '\\[')
        .replaceAll(']', '\\]')
        .replaceAll('\n', ' ');
  }
}

class _InlineRun {
  _InlineRun(this.text, Map<String, dynamic> attrs) : imageBytes = null,
        attrs = attrs.isEmpty ? const <String, dynamic>{} : attrs;
  _InlineRun.text(this.text) : attrs = const <String, dynamic>{}, imageBytes = null;
  _InlineRun.image(this.imageBytes)
      : text = '',
        attrs = const <String, dynamic>{};

  final String text;
  final Map<String, dynamic> attrs;
  final Uint8List? imageBytes;
}

class _RenderedLine {
  _RenderedLine({
    this.runs = const [],
    this.blockPrefix,
    this.blockAttrs,
    this.inCodeBlock = false,
  });
  _RenderedLine.empty()
      : runs = const [],
        blockPrefix = null,
        blockAttrs = null,
        inCodeBlock = false;

  final List<_InlineRun> runs;
  final String? blockPrefix;
  final Map<String, dynamic>? blockAttrs;
  final bool inCodeBlock;

  bool get isBlockSeparator => runs.isEmpty && blockAttrs == null;
}

enum _ExportAction { share, save }

class ExportEmptyException implements Exception {
  const ExportEmptyException();
  @override
  String toString() => 'La nota no tiene contenido para exportar';
}
