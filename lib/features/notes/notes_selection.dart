import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class NotesSelectionState {
  const NotesSelectionState({
    this.enabled = false,
    this.selectedIds = const <int>{},
  });

  final bool enabled;
  final Set<int> selectedIds;

  int get count => selectedIds.length;
  bool get isEmpty => selectedIds.isEmpty;

  bool contains(int id) => selectedIds.contains(id);

  NotesSelectionState copyWith({bool? enabled, Set<int>? selectedIds}) {
    return NotesSelectionState(
      enabled: enabled ?? this.enabled,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }

  static const empty = NotesSelectionState();
}

class NotesSelectionController extends Notifier<NotesSelectionState> {
  @override
  NotesSelectionState build() => NotesSelectionState.empty;

  void enter() {
    if (state.enabled) return;
    state = state.copyWith(enabled: true);
  }

  void exit() {
    if (!state.enabled && state.selectedIds.isEmpty) return;
    state = NotesSelectionState.empty;
  }

  void toggle(int noteId) {
    final next = Set<int>.from(state.selectedIds);
    if (!next.remove(noteId)) next.add(noteId);
    final enabled = state.enabled || next.isNotEmpty;
    state = state.copyWith(enabled: enabled, selectedIds: next);
  }

  void enterWith(int noteId) {
    state = state.copyWith(
      enabled: true,
      selectedIds: {noteId},
    );
  }

  void clearSelectionKeepingMode() {
    if (state.selectedIds.isEmpty) return;
    state = state.copyWith(selectedIds: const <int>{});
  }

  void selectAll(Iterable<int> noteIds) {
    if (noteIds.isEmpty) return;
    final next = Set<int>.from(state.selectedIds)..addAll(noteIds);
    state = state.copyWith(enabled: true, selectedIds: next);
  }

  bool isSelected(int noteId) => state.selectedIds.contains(noteId);
}

final notesSelectionProvider =
    NotifierProvider<NotesSelectionController, NotesSelectionState>(
      NotesSelectionController.new,
    );
