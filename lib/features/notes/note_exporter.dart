import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/db/models/note.dart';

enum NoteExportFormat { markdown, text }

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
    final ext = format == NoteExportFormat.markdown ? 'md' : 'txt';
    return '${_safeFileBase(note.title)} (${note.id}).$ext';
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

  static Future<XFile> exportFile(
    NoteEntity note,
    NoteExportFormat format,
  ) async {
    final text = format == NoteExportFormat.markdown
        ? toMarkdown(note)
        : toText(note);
    if (text.isEmpty) {
      throw const ExportEmptyException();
    }
    final dir = await _tempDir();
    final file = File(p.join(dir.path, _fileName(note, format)));
    await file.writeAsString(text, flush: true);
    final mime = format == NoteExportFormat.markdown
        ? 'text/markdown'
        : 'text/plain';
    return XFile(file.path, mimeType: mime, name: p.basename(file.path));
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
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (format == null) return;
    if (!context.mounted) return;
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
  _InlineRun(this.text, Map<String, dynamic> attrs)
      : attrs = attrs.isEmpty ? const <String, dynamic>{} : attrs;
  _InlineRun.text(this.text) : attrs = const <String, dynamic>{};

  final String text;
  final Map<String, dynamic> attrs;
}

class _RenderedLine {
  _RenderedLine({
    this.runs = const [],
    this.blockPrefix,
    this.inCodeBlock = false,
  });
  _RenderedLine.empty()
      : runs = const [],
        blockPrefix = null,
        inCodeBlock = false;

  final List<_InlineRun> runs;
  final String? blockPrefix;
  final bool inCodeBlock;

  bool get isBlockSeparator => runs.isEmpty && blockPrefix == null;
}

class ExportEmptyException implements Exception {
  const ExportEmptyException();
  @override
  String toString() => 'La nota no tiene contenido para exportar';
}
