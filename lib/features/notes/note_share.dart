import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/db/models/note.dart';

class NoteShare {
  NoteShare._();

  static String serialize(NoteEntity note) {
    final title = note.title.trim();
    final body = note.bodyPlain
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .join('\n');
    if (title.isEmpty && body.isEmpty) return '';
    if (title.isEmpty) return body;
    if (body.isEmpty) return title;
    return '$title\n\n$body';
  }

  static Future<void> share(
    BuildContext context,
    NoteEntity note, {
    Rect? sharePositionOrigin,
  }) async {
    final text = serialize(note);
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay nada que compartir en una nota vacía'),
        ),
      );
      return;
    }
    final params = ShareParams(
      text: text,
      subject: note.title.trim().isEmpty ? 'Nota' : note.title.trim(),
      sharePositionOrigin: sharePositionOrigin,
    );
    await SharePlus.instance.share(params);
  }
}
