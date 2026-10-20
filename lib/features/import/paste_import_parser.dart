import 'dart:convert';

import 'package:flutter/foundation.dart';

@immutable
class ParsedImportBlock {
  const ParsedImportBlock({
    required this.title,
    required this.body,
    required this.bodyPlain,
    required this.bodyDelta,
    required this.explicitDate,
    required this.hasExplicitDate,
    required this.warning,
  });

  final String title;
  final String body;
  final List<String> bodyPlain;
  final String bodyDelta;
  final DateTime? explicitDate;
  final bool hasExplicitDate;
  final String? warning;
}

@immutable
class PasteImportParseResult {
  const PasteImportParseResult({required this.blocks});
  final List<ParsedImportBlock> blocks;
  int get count => blocks.length;
  bool get isEmpty => blocks.isEmpty;
  int get nonEmptyCount =>
      blocks.where((b) => b.body.trim().isNotEmpty).length;
}

/// Parses pasted plain text into one or more `ParsedImportBlock`s.
///
/// Block separation rules:
/// - **Only a line with 5 or more hyphens (`-----`) separates notes.**
///   Fewer hyphens (`---`, the markdown horizontal rule, or `----`) stay
///   in the body as literal text, so notes that contain markdown
///   decoration don't get split by accident.
/// - **Blank lines never split a note** — they're paragraph breaks and
///   are preserved as-is in the body. This is what makes it safe to
///   paste a multi-paragraph note straight out of another app.
///
/// A trailing `-----` just terminates the last note; the empty block
/// after it is discarded (no phantom note is created).
///
/// Supported date prefixes (case-sensitive, on the first non-empty line):
/// - `[YYYY-MM-DD HH:MM]` (most explicit, recommended)
/// - `# YYYY-MM-DD HH:MM` (markdown-style heading)
/// - `YYYY-MM-DD HH:MM` (bare line)
///
/// If no date prefix is found in a block, the importer uses the import
/// time as the note's `createdAt` (and `updatedAt`).
///
/// Date validation is strict: month/day ranges are checked and the
/// result is verified via round-trip to reject Dart's silent
/// normalization (e.g. `2025-13-45` → `2026-02-14`).
class PasteImportParser {
  PasteImportParser._();

  static final RegExp _separatorLine = RegExp(r'^\s*-{5,}\s*$');

  static final List<RegExp> _datePatterns = [
    RegExp(
      r'^\[\s*(\d{4}-\d{2}-\d{2}(?:\s+\d{1,2}:\d{2}(?::\d{2})?)?)\s*\]\s*$',
    ),
    RegExp(
      r'^#\s+(\d{4}-\d{2}-\d{2}(?:\s+\d{1,2}:\d{2}(?::\d{2})?)?)\s*$',
    ),
    RegExp(
      r'^(\d{4}-\d{2}-\d{2}(?:\s+\d{1,2}:\d{2}(?::\d{2})?)?)\s*$',
    ),
  ];

  static DateTime? _tryParseDate(String raw) {
    final parts = raw.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return null;
    final dateParts = parts.first.split('-');
    if (dateParts.length != 3) return null;
    final year = int.tryParse(dateParts[0]);
    final month = int.tryParse(dateParts[1]);
    final day = int.tryParse(dateParts[2]);
    if (year == null || month == null || day == null) return null;
    if (month < 1 || month > 12) return null;
    if (day < 1 || day > 31) return null;

    int hour = 0, minute = 0, second = 0;
    if (parts.length > 1) {
      final timeParts = parts[1].split(':');
      if (timeParts.length < 2 || timeParts.length > 3) return null;
      final h = int.tryParse(timeParts[0]);
      final m = int.tryParse(timeParts[1]);
      final s = timeParts.length > 2 ? int.tryParse(timeParts[2]) : 0;
      if (h == null || m == null || s == null) return null;
      if (h < 0 || h > 23) return null;
      if (m < 0 || m > 59) return null;
      if (s < 0 || s > 59) return null;
      hour = h;
      minute = m;
      second = s;
    }
    final candidate = DateTime(year, month, day, hour, minute, second);
    if (candidate.year != year ||
        candidate.month != month ||
        candidate.day != day) {
      return null;
    }
    return candidate;
  }

  static String _safeTitleBase(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'Nota importada';
    final collapsed = trimmed.replaceAll(RegExp(r'\s+'), ' ');
    final truncated =
        collapsed.length > 80 ? collapsed.substring(0, 80).trimRight() : collapsed;
    return truncated;
  }

  static List<String> _bodyPlainFromString(String body) {
    if (body.isEmpty) return const [];
    final lines = body.split('\n');
    while (lines.isNotEmpty && lines.last.trim().isEmpty) {
      lines.removeLast();
    }
    while (lines.isNotEmpty && lines.first.trim().isEmpty) {
      lines.removeAt(0);
    }
    return lines;
  }

  static String _bodyDeltaFromLines(List<String> lines) {
    final inserts = <Map<String, Object>>[];
    for (final line in lines) {
      inserts.add({'insert': '$line\n'});
    }
    if (inserts.isEmpty) return '[]';
    return jsonEncode(inserts);
  }

  static List<List<String>> _splitBlocks(List<String> lines) {
    final blocks = <List<String>>[];
    var current = <String>[];

    void flush() {
      // Only trim the edges so a body keeps its internal blank lines
      // (they're paragraph breaks, not separators).
      while (current.isNotEmpty && current.last.trim().isEmpty) {
        current.removeLast();
      }
      while (current.isNotEmpty && current.first.trim().isEmpty) {
        current.removeAt(0);
      }
      if (current.isEmpty) return;
      blocks.add(current);
      current = <String>[];
    }

    for (final line in lines) {
      if (_separatorLine.hasMatch(line)) {
        flush();
        continue;
      }
      current.add(line);
    }
    flush();
    return blocks;
  }

  static ParsedImportBlock _parseBlock(List<String> rawLines) {
    DateTime? explicit;
    String? warning;
    final lines = List<String>.from(rawLines);
    var hasExplicitDate = false;

    for (final pattern in _datePatterns) {
      if (lines.isEmpty) break;
      final first = lines.first;
      final match = pattern.firstMatch(first);
      if (match == null) continue;
      final raw = match.group(1)!;
      final parsed = _tryParseDate(raw);
      if (parsed == null) {
        warning =
            'Fecha inválida en primera línea ($raw); se ignora y se usa la fecha por defecto.';
        break;
      }
      explicit = parsed;
      hasExplicitDate = true;
      lines.removeAt(0);
      break;
    }

    while (lines.isNotEmpty && lines.first.trim().isEmpty) {
      lines.removeAt(0);
    }
    while (lines.isNotEmpty && lines.last.trim().isEmpty) {
      lines.removeLast();
    }
    final body = lines.join('\n').trim();
    final bodyPlain = _bodyPlainFromString(body);
    final title = bodyPlain.isNotEmpty
        ? _safeTitleBase(bodyPlain.first)
        : 'Nota importada';
    final bodyDelta = _bodyDeltaFromLines(bodyPlain);

    return ParsedImportBlock(
      title: title,
      body: body,
      bodyPlain: bodyPlain,
      bodyDelta: bodyDelta,
      explicitDate: explicit,
      hasExplicitDate: hasExplicitDate,
      warning: warning,
    );
  }

  static PasteImportParseResult parse(String input) {
    if (input.trim().isEmpty) {
      return const PasteImportParseResult(blocks: []);
    }
    final lines = input.split('\n');
    final blocks = _splitBlocks(lines);
    final parsed = blocks.map(_parseBlock).toList(growable: false);
    return PasteImportParseResult(blocks: parsed);
  }
}
