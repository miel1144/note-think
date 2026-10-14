import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NotesLayout { list, grid }

class NotesLayoutController extends AsyncNotifier<NotesLayout> {
  static const String _prefsKey = 'notes.listLayout';

  @override
  Future<NotesLayout> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == NotesLayout.grid.name) return NotesLayout.grid;
    return NotesLayout.list;
  }

  Future<void> setLayout(NotesLayout layout) async {
    if (state.value == layout) return;
    state = AsyncValue.data(layout);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, layout.name);
  }

  Future<void> toggle() async {
    final current = state.value ?? NotesLayout.list;
    await setLayout(
      current == NotesLayout.list ? NotesLayout.grid : NotesLayout.list,
    );
  }
}

final notesLayoutProvider =
    AsyncNotifierProvider<NotesLayoutController, NotesLayout>(
      NotesLayoutController.new,
    );
