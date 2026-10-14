import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/models/category.dart';
import '../../core/db/models/note.dart';
import '../../core/theme/app_colors.dart';
import '../categories/categories_providers.dart';
import 'notes_providers.dart';

class NotesFilter {
  const NotesFilter({
    this.categoryId,
    this.accentHex,
    this.pinnedOnly = false,
  });

  static const String noAccentSentinel = '__none__';

  final int? categoryId;
  final String? accentHex;
  final bool pinnedOnly;

  bool get hasAny =>
      categoryId != null || accentHex != null || pinnedOnly;

  NotesFilter copyWith({
    int? categoryId,
    String? accentHex,
    bool? pinnedOnly,
    bool clearCategory = false,
    bool clearAccent = false,
  }) {
    return NotesFilter(
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      accentHex: clearAccent ? null : (accentHex ?? this.accentHex),
      pinnedOnly: pinnedOnly ?? this.pinnedOnly,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotesFilter &&
          categoryId == other.categoryId &&
          accentHex == other.accentHex &&
          pinnedOnly == other.pinnedOnly;

  @override
  int get hashCode => Object.hash(categoryId, accentHex, pinnedOnly);
}

class NotesFilterController extends Notifier<NotesFilter> {
  @override
  NotesFilter build() => const NotesFilter();

  void setCategory(int? id) {
    state = state.copyWith(categoryId: id, clearCategory: id == null);
  }

  void setAccent(String? hex) {
    state = state.copyWith(accentHex: hex, clearAccent: hex == null);
  }

  void setPinnedOnly(bool value) {
    state = state.copyWith(pinnedOnly: value);
  }

  void clear() {
    state = const NotesFilter();
  }
}

final notesFilterProvider =
    NotifierProvider<NotesFilterController, NotesFilter>(
      NotesFilterController.new,
    );

final filteredNotesProvider = Provider<AsyncValue<List<NoteEntity>>>((ref) {
  final notesAsync = ref.watch(notesListProvider);
  final filter = ref.watch(notesFilterProvider);
  return notesAsync.whenData((notes) => _apply(notes, filter));
});

List<NoteEntity> _apply(List<NoteEntity> notes, NotesFilter f) {
  if (!f.hasAny) return notes;
  return notes.where((n) {
    if (f.categoryId != null && n.categoryId != f.categoryId) return false;
    if (f.pinnedOnly && !n.pinned) return false;
    if (f.accentHex != null) {
      if (f.accentHex == NotesFilter.noAccentSentinel) {
        if (n.accentHex != null) return false;
      } else if (n.accentHex != f.accentHex) {
        return false;
      }
    }
    return true;
  }).toList();
}

String? folderNameFor(WidgetRef ref, int? id) {
  if (id == null) return null;
  final folders = ref.read(foldersListProvider).value;
  if (folders == null) return null;
  for (final CategoryEntity c in folders) {
    if (c.id == id) return c.name;
  }
  return null;
}

String? accentLabelFor(String? hex) {
  if (hex == null) return null;
  if (hex == NotesFilter.noAccentSentinel) return 'Sin color';
  final idx = _indexOfHex(hex);
  if (idx == null) return null;
  switch (idx) {
    case 0:
      return 'Oliva';
    case 1:
      return 'Oliva oscuro';
    case 2:
      return 'Marrón';
    case 3:
      return 'Marrón muy oscuro';
  }
  return null;
}

int? _indexOfHex(String hex) {
  for (int i = 0; i < AppColors.noteAccents.length; i++) {
    final candidate =
        '#${AppColors.noteAccents[i].toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
    if (candidate == hex) return i;
  }
  return null;
}
