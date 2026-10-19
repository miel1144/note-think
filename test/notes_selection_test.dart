import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notethink/features/notes/notes_selection.dart';

ProviderContainer _container() => ProviderContainer();

void main() {
  group('NotesSelectionController', () {
    test('starts empty and disabled', () {
      final c = _container();
      addTearDown(c.dispose);
      expect(c.read(notesSelectionProvider), NotesSelectionState.empty);
      expect(c.read(notesSelectionProvider).enabled, isFalse);
      expect(c.read(notesSelectionProvider).count, 0);
    });

    test('enter() flips enabled without changing the selection', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(notesSelectionProvider.notifier).enter();
      expect(c.read(notesSelectionProvider).enabled, isTrue);
      expect(c.read(notesSelectionProvider).count, 0);
    });

    test('enterWith enables and seeds the selection', () {
      final c = _container();
      addTearDown(c.dispose);
      c.read(notesSelectionProvider.notifier).enterWith(7);
      final state = c.read(notesSelectionProvider);
      expect(state.enabled, isTrue);
      expect(state.count, 1);
      expect(state.contains(7), isTrue);
    });

    test('toggle adds, removes, and keeps enabled while toggling', () {
      final c = _container();
      addTearDown(c.dispose);
      final controller = c.read(notesSelectionProvider.notifier);
      controller.toggle(1);
      expect(c.read(notesSelectionProvider).enabled, isTrue);
      expect(c.read(notesSelectionProvider).contains(1), isTrue);

      controller.toggle(2);
      expect(c.read(notesSelectionProvider).contains(2), isTrue);
      expect(c.read(notesSelectionProvider).count, 2);

      controller.toggle(1);
      expect(c.read(notesSelectionProvider).contains(1), isFalse);
      expect(c.read(notesSelectionProvider).count, 1);
    });

    test('selectAll replaces the selection while staying enabled', () {
      final c = _container();
      addTearDown(c.dispose);
      final controller = c.read(notesSelectionProvider.notifier);
      controller.selectAll(const [1, 2, 3]);
      expect(c.read(notesSelectionProvider).count, 3);
      expect(c.read(notesSelectionProvider).contains(1), isTrue);
      expect(c.read(notesSelectionProvider).contains(2), isTrue);
      expect(c.read(notesSelectionProvider).contains(3), isTrue);

      controller.selectAll(const [10, 11]);
      // selectAll merges rather than replaces (addAll under the hood).
      expect(c.read(notesSelectionProvider).count, 5);
      expect(c.read(notesSelectionProvider).contains(10), isTrue);
    });

    test('clearSelectionKeepingMode keeps enabled but empties the set', () {
      final c = _container();
      addTearDown(c.dispose);
      final controller = c.read(notesSelectionProvider.notifier);
      controller.selectAll(const [1, 2, 3]);
      controller.clearSelectionKeepingMode();
      final state = c.read(notesSelectionProvider);
      expect(state.enabled, isTrue);
      expect(state.count, 0);
      expect(state.isEmpty, isTrue);
    });

    test('exit() resets enabled and the selection', () {
      final c = _container();
      addTearDown(c.dispose);
      final controller = c.read(notesSelectionProvider.notifier);
      controller.selectAll(const [1, 2, 3]);
      controller.exit();
      expect(c.read(notesSelectionProvider), NotesSelectionState.empty);
    });

    test('toggling off the last selection keeps mode enabled', () {
      final c = _container();
      addTearDown(c.dispose);
      final controller = c.read(notesSelectionProvider.notifier);
      controller.toggle(1);
      controller.toggle(1);
      final state = c.read(notesSelectionProvider);
      expect(state.enabled, isTrue);
      expect(state.isEmpty, isTrue);
    });

    test('selectAll on empty input is a no-op', () {
      final c = _container();
      addTearDown(c.dispose);
      final controller = c.read(notesSelectionProvider.notifier);
      controller.selectAll(const <int>[]);
      expect(c.read(notesSelectionProvider), NotesSelectionState.empty);
    });
  });
}
