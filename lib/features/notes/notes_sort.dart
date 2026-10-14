import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/db/models/note.dart';
import '../../core/theme/app_colors.dart';
import 'notes_filter.dart';

enum NotesSortField { modified, created, title, color }

enum NotesSortDirection { asc, desc }

class NotesSort {
  const NotesSort({this.field = NotesSortField.modified, this.direction = NotesSortDirection.desc});

  final NotesSortField field;
  final NotesSortDirection direction;

  static const NotesSort defaultSort = NotesSort();

  bool get isDefault => field == NotesSortField.modified && direction == NotesSortDirection.desc;

  NotesSort copyWith({NotesSortField? field, NotesSortDirection? direction}) {
    return NotesSort(
      field: field ?? this.field,
      direction: direction ?? this.direction,
    );
  }

  String get fieldLabel {
    switch (field) {
      case NotesSortField.modified:
        return 'Modificación';
      case NotesSortField.created:
        return 'Creación';
      case NotesSortField.title:
        return 'Título';
      case NotesSortField.color:
        return 'Color';
    }
  }

  String get shortLabel {
    switch (field) {
      case NotesSortField.modified:
        return direction == NotesSortDirection.desc ? 'Recientes' : 'Antiguas';
      case NotesSortField.created:
        return direction == NotesSortDirection.desc
            ? 'Creación ↓'
            : 'Creación ↑';
      case NotesSortField.title:
        return direction == NotesSortDirection.desc ? 'Z-A' : 'A-Z';
      case NotesSortField.color:
        return 'Por color';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotesSort &&
          field == other.field &&
          direction == other.direction;

  @override
  int get hashCode => Object.hash(field, direction);
}

class NotesSortController extends AsyncNotifier<NotesSort> {
  static const String _prefsKey = 'notes.sort';

  @override
  Future<NotesSort> build() async {
    final prefs = await SharedPreferences.getInstance();
    final fieldName = prefs.getString('$_prefsKey.field');
    final dirName = prefs.getString('$_prefsKey.direction');
    final field = NotesSortField.values.firstWhere(
      (f) => f.name == fieldName,
      orElse: () => NotesSortField.modified,
    );
    final dir = NotesSortDirection.values.firstWhere(
      (d) => d.name == dirName,
      orElse: () => NotesSortDirection.desc,
    );
    return NotesSort(field: field, direction: dir);
  }

  Future<void> setField(NotesSortField field) async {
    final next = NotesSort(field: field, direction: _defaultDirectionFor(field));
    state = AsyncValue.data(next);
    await _persist(next);
  }

  Future<void> setDirection(NotesSortDirection direction) async {
    final current = state.value ?? NotesSort.defaultSort;
    final next = current.copyWith(direction: direction);
    state = AsyncValue.data(next);
    await _persist(next);
  }

  Future<void> reset() async {
    state = const AsyncValue.data(NotesSort.defaultSort);
    await _persist(NotesSort.defaultSort);
  }

  NotesSortDirection _defaultDirectionFor(NotesSortField field) {
    switch (field) {
      case NotesSortField.modified:
      case NotesSortField.created:
        return NotesSortDirection.desc;
      case NotesSortField.title:
      case NotesSortField.color:
        return NotesSortDirection.asc;
    }
  }

  Future<void> _persist(NotesSort sort) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefsKey.field', sort.field.name);
    await prefs.setString('$_prefsKey.direction', sort.direction.name);
  }
}

final notesSortProvider =
    AsyncNotifierProvider<NotesSortController, NotesSort>(
      NotesSortController.new,
    );

final displayedNotesProvider = Provider<AsyncValue<List<NoteEntity>>>((ref) {
  final filteredAsync = ref.watch(filteredNotesProvider);
  final sort = ref.watch(notesSortProvider).value ?? NotesSort.defaultSort;
  return filteredAsync.whenData((notes) => _apply(notes, sort));
});

List<NoteEntity> _apply(List<NoteEntity> notes, NotesSort sort) {
  if (notes.isEmpty) return notes;
  final pinned = notes.where((n) => n.pinned).toList();
  final others = notes.where((n) => !n.pinned).toList();
  _sortInPlace(pinned, sort);
  _sortInPlace(others, sort);
  return [...pinned, ...others];
}

void _sortInPlace(List<NoteEntity> notes, NotesSort sort) {
  final dir = sort.direction == NotesSortDirection.asc ? 1 : -1;
  notes.sort((a, b) {
    int cmp;
    switch (sort.field) {
      case NotesSortField.modified:
        cmp = a.updatedAt.compareTo(b.updatedAt);
      case NotesSortField.created:
        cmp = a.createdAt.compareTo(b.createdAt);
      case NotesSortField.title:
        cmp = _titleCompare(a.title, b.title);
      case NotesSortField.color:
        cmp = _colorIndex(a.accentHex).compareTo(_colorIndex(b.accentHex));
    }
    if (cmp == 0) return a.updatedAt.compareTo(b.updatedAt) * -dir;
    return cmp * dir;
  });
}

int _titleCompare(String a, String b) {
  return a.toLowerCase().compareTo(b.toLowerCase());
}

int _colorIndex(String? hex) {
  if (hex == null) return 9999;
  for (int i = 0; i < AppColors.noteAccents.length; i++) {
    final candidate =
        '#${AppColors.noteAccents[i].toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
    if (candidate == hex) return i;
  }
  return 9999;
}
