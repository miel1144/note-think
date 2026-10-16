import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/db/models/note.dart';
import '../../core/storage/notes_repository.dart';
import '../../core/storage/repositories.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../private_notes/password_dialog.dart';
import '../private_notes/private_notes_controller.dart';
import '../reminders/reminder_picker.dart';
import '../reminders/reminders_service.dart';
import '../spotify/add_spotify_link_dialog.dart';
import '../spotify/spotify_link_carousel.dart';
import '../spotify/spotify_providers.dart';

enum SaveStatus { pristine, dirty, saving, saved, error }

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key, this.noteId, this.folderId});
  final int? noteId;
  final int? folderId;

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  static const _debounce = Duration(milliseconds: 500);

  late final TextEditingController _titleCtrl;
  late final QuillController _quillCtrl;
  final FocusNode _editorFocus = FocusNode();
  final FocusNode _titleFocus = FocusNode();
  bool _loading = true;
  int? _id;
  SaveStatus _status = SaveStatus.pristine;
  Timer? _saveTimer;
  StreamSubscription<DocChange>? _docSub;
  int _pendingChanges = 0;
  late final NotesRepository _repo;
  bool _discard = false;

  @override
  void initState() {
    super.initState();
    _repo = ref.read(notesRepositoryProvider);
    _titleCtrl = TextEditingController();
    _quillCtrl = QuillController.basic();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final id = widget.noteId;
    if (id == null) {
      _attachListeners();
      setState(() {
        _loading = false;
        _status = SaveStatus.pristine;
      });
      return;
    }
    final note = await _repo.getById(id);
    if (note == null) {
      if (mounted) context.pop();
      return;
    }
    if (note.isPrivate && !ref.read(privateNotesProvider).isUnlocked) {
      if (!mounted) return;
      final result = await showPasswordDialog(
        context,
        ref,
        mode: PasswordDialogMode.verify,
      );
      if (!mounted) return;
      if (!result.success) {
        if (result.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message!)),
          );
        }
        context.pop();
        return;
      }
    }
    _id = note.id;
    ref.read(currentEditorNoteIdProvider.notifier).set(note.id);
    _titleCtrl.text = note.title;
    _lastTitle = note.title;
    try {
      final raw = jsonDecode(note.bodyDelta);
      if (raw is List) {
        final delta = Delta.fromJson(raw.cast<dynamic>());
        _quillCtrl.document = Document.fromDelta(delta);
      }
    } catch (_) {}
    _attachListeners();
    if (mounted) {
      setState(() {
        _loading = false;
        _status = SaveStatus.saved;
      });
    }
  }

  void _attachListeners() {
    _docSub = _quillCtrl.document.changes.listen((_) => _onChanged());
    _titleCtrl.addListener(_onTitleChanged);
  }

  String _lastTitle = '';
  void _onTitleChanged() {
    if (_titleCtrl.text == _lastTitle) return;
    _lastTitle = _titleCtrl.text;
    _onChanged();
  }

  void _onChanged() {
    if (!mounted) return;
    _pendingChanges++;
    if (_status != SaveStatus.saving) {
      setState(() => _status = SaveStatus.dirty);
    }
    _saveTimer?.cancel();
    _saveTimer = Timer(_debounce, _performSave);
  }

  Future<void> _performSave() async {
    if (_status == SaveStatus.saving) return;
    _pendingChanges = 0;
    setState(() => _status = SaveStatus.saving);
    try {
      await _save();
      if (!mounted) return;
      setState(() {
        _status = _pendingChanges > 0 ? SaveStatus.dirty : SaveStatus.saved;
        if (_status == SaveStatus.dirty) {
          _saveTimer?.cancel();
          _saveTimer = Timer(_debounce, _performSave);
        }
      });
    } catch (e) {
      debugPrint('Error al guardar la nota: $e');
      if (!mounted) return;
      setState(() => _status = SaveStatus.error);
    }
  }

  Future<void> _save() async {
    final repo = _repo;
    final delta = _quillCtrl.document.toDelta();
    final plain = _quillCtrl.document
        .toPlainText()
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();
    final titleInput = _titleCtrl.text.trim();
    final hasEmbed = delta.toList().any((o) => o.data is Map);
    if (_id == null && titleInput.isEmpty && plain.isEmpty && !hasEmbed) return;
    final existing = _id == null ? null : await repo.getById(_id!);
    final note = existing ?? NoteEntity();
    note
      ..title = titleInput.isEmpty ? _autoTitleFrom(plain) : titleInput
      ..bodyDelta = jsonEncode(delta.toJson())
      ..bodyPlain = plain
      ..categoryId = existing?.categoryId ?? widget.folderId;
    final newId = await repo.upsert(note);
    _id ??= newId;
  }

  String _autoTitleFrom(List<String> lines) {
    for (final l in lines) {
      final t = l.trim();
      if (t.isNotEmpty) return t.length > 60 ? '${t.substring(0, 60)}…' : t;
    }
    return 'Sin título';
  }

  Future<void> _delete() async {
    final id = _id;
    if (id == null) {
      if (mounted) context.pop();
      return;
    }
    _saveTimer?.cancel();
    final isPrivate = (await _repo.getById(id))?.isPrivate ?? false;
    if (!mounted) return;
    final ok = await showConfirmDialog(
      context,
      icon: Icons.delete_outline,
      title: isPrivate ? '¿Eliminar nota privada?' : '¿Mover a papelera?',
      message: isPrivate
          ? 'Esta nota privada se borrará para siempre y no se puede recuperar.'
          : 'Podrás restaurarla desde la papelera durante 30 días. Pasado ese tiempo se eliminará definitivamente.',
      confirmLabel: isPrivate ? 'Eliminar' : 'Mover',
      destructive: isPrivate,
    );
    if (!ok) return;
    _discard = true;
    if (isPrivate) {
      await ref.read(spotifyRepositoryProvider).removeAllForNote(id);
      await _repo.permanentDelete(id);
    } else {
      await _repo.softDelete(id);
    }
    await RemindersService.instance.cancel(id);
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    final hasPending = !_discard && (_saveTimer?.isActive ?? false);
    _saveTimer?.cancel();
    if (hasPending) {
      _save();
    }
    _docSub?.cancel();
    _titleCtrl.removeListener(_onTitleChanged);
    _quillCtrl.dispose();
    _titleCtrl.dispose();
    _editorFocus.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  QuillIconTheme _buildToolbarIconTheme(ThemeData theme) {
    final text = theme.colorScheme.onSurface;
    final background = theme.scaffoldBackgroundColor;
    final muted = text.withValues(alpha: 0.6);

    return QuillIconTheme(
      iconButtonUnselectedData: IconButtonData(
        color: muted,
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: muted,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(8),
        ),
      ),
      iconButtonSelectedData: IconButtonData(
        color: background,
        style: IconButton.styleFrom(
          backgroundColor: text,
          foregroundColor: background,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Editar'),
        actions: [
          if (widget.noteId != null) const _SpotifyMenu(),
          if (widget.noteId != null) const _ReminderMenu(),
          _SaveIndicator(
            status: _status,
            onTap: _status == SaveStatus.saving ? null : _performSave,
          ),
          if (widget.noteId != null)
            IconButton(
              tooltip: 'Mover a papelera',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  if (widget.noteId != null)
                    _SpotifyLinksSection(noteId: widget.noteId!),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                    child: TextField(
                      controller: _titleCtrl,
                      focusNode: _titleFocus,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Título',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => _editorFocus.requestFocus(),
                    ),
                  ),
                  QuillSimpleToolbar(
                    controller: _quillCtrl,
                    config: QuillSimpleToolbarConfig(
                      multiRowsDisplay: false,
                      showAlignmentButtons: false,
                      showDirection: false,
                      showSearchButton: false,
                      showSubscript: false,
                      showSuperscript: false,
                      showFontFamily: false,
                      showFontSize: false,
                      color: theme.scaffoldBackgroundColor,
                      buttonOptions: QuillSimpleToolbarButtonOptions(
                        base: QuillToolbarBaseButtonOptions(
                          iconTheme: _buildToolbarIconTheme(theme),
                        ),
                      ),
                      embedButtons: FlutterQuillEmbeds.toolbarButtons(
                        imageButtonOptions: QuillToolbarImageButtonOptions(
                          imageButtonConfig: QuillToolbarImageConfig(
                            onRequestPickImage: (_) async {
                              final picker = ImagePicker();
                              final picked = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (picked == null) return null;
                              return NoteImageStore.instance.persistFromPicker(
                                picked.path,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: QuillEditor.basic(
                        controller: _quillCtrl,
                        focusNode: _editorFocus,
                        config: QuillEditorConfig(
                          placeholder: 'Empieza a escribir...',
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          expands: true,
                          autoFocus: widget.noteId == null,
                          embedBuilders:
                              FlutterQuillEmbeds.defaultEditorBuilders(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SaveIndicator extends StatelessWidget {
  const _SaveIndicator({required this.status, required this.onTap});
  final SaveStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface
        .withValues(alpha: 0.6);
    final Widget child = switch (status) {
      SaveStatus.pristine => const SizedBox.shrink(),
      SaveStatus.dirty => Icon(Icons.edit_note, color: color, size: 22),
      SaveStatus.saving => const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      SaveStatus.saved => Icon(Icons.check_circle, color: color, size: 22),
      SaveStatus.error => Icon(Icons.error_outline, color: color, size: 22),
    };
    if (status == SaveStatus.pristine || status == SaveStatus.saving) {
      return SizedBox(width: 48, child: Center(child: child));
    }
    return IconButton(
      tooltip: status == SaveStatus.saved ? 'Guardado' : 'Guardar ahora',
      onPressed: onTap,
      icon: child,
    );
  }
}

class _ReminderMenu extends ConsumerWidget {
  const _ReminderMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteId = _currentNoteId(ref);
    if (noteId == null) return const SizedBox.shrink();
    final noteAsync = ref.watch(_currentNoteProvider(noteId));
    final note = noteAsync.value;
    final hasReminder = note?.reminderAt != null;
    return PopupMenuButton<String>(
      tooltip: hasReminder ? 'Recordatorio' : 'Programar recordatorio',
      icon: Icon(
        hasReminder
            ? Icons.notifications_active_outlined
            : Icons.notifications_outlined,
      ),
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      onSelected: (value) async {
        if (note == null) return;
        if (value == 'schedule') {
          final granted =
              await RemindersService.instance.requestPermission();
          if (!granted) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Se necesita permiso de notificaciones'),
              ),
            );
            return;
          }
          if (!context.mounted) return;
          final when = await showReminderPicker(context);
          if (when == null) return;
          await ref
              .read(notesRepositoryProvider)
              .setReminder(noteId, when);
          final title = note.title.trim().isEmpty
              ? 'Recordatorio'
              : note.title.trim();
          final body = RemindersService.instance.firstBodyLine(note.bodyPlain);
          await RemindersService.instance.schedule(
            noteId: noteId,
            when: when,
            title: title,
            body: body,
            isPrivate: note.isPrivate,
          );
        } else if (value == 'change') {
          final when = await showReminderPicker(context);
          if (when == null) return;
          await ref
              .read(notesRepositoryProvider)
              .setReminder(noteId, when);
          final title = note.title.trim().isEmpty
              ? 'Recordatorio'
              : note.title.trim();
          final body = RemindersService.instance.firstBodyLine(note.bodyPlain);
          await RemindersService.instance.cancel(noteId);
          await RemindersService.instance.schedule(
            noteId: noteId,
            when: when,
            title: title,
            body: body,
            isPrivate: note.isPrivate,
          );
        } else if (value == 'cancel') {
          await ref
              .read(notesRepositoryProvider)
              .setReminder(noteId, null);
          await RemindersService.instance.cancel(noteId);
        }
      },
      itemBuilder: (_) {
        if (!hasReminder || note == null) {
          return const [
            PopupMenuItem(
              value: 'schedule',
              child: Row(
                children: [
                  Icon(Icons.notifications_outlined, size: 18),
                  SizedBox(width: 10),
                  Text('Programar recordatorio'),
                ],
              ),
            ),
          ];
        }
        return [
          PopupMenuItem(
            value: 'change',
            child: Row(
              children: [
                const Icon(Icons.edit_calendar_outlined, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Cambiar (${formatReminder(note.reminderAt!)})'),
                ),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'cancel',
            child: Row(
              children: [
                Icon(Icons.notifications_off_outlined, size: 18),
                SizedBox(width: 10),
                Text('Quitar recordatorio'),
              ],
            ),
          ),
        ];
      },
    );
  }

  int? _currentNoteId(WidgetRef ref) {
    return ref.read(currentEditorNoteIdProvider);
  }
}

class CurrentEditorNoteIdController extends Notifier<int?> {
  @override
  int? build() => null;

  void set(int? id) {
    state = id;
  }
}

final currentEditorNoteIdProvider =
    NotifierProvider<CurrentEditorNoteIdController, int?>(
      CurrentEditorNoteIdController.new,
    );

final _currentNoteProvider = FutureProvider.family<NoteEntity?, int>((
  ref,
  id,
) async {
  return ref.watch(notesRepositoryProvider).getById(id);
});

class _SpotifyMenu extends ConsumerWidget {
  const _SpotifyMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteId = ref.watch(currentEditorNoteIdProvider);
    if (noteId == null) return const SizedBox.shrink();
    final count = ref.watch(spotifyLinkCountByNoteProvider(noteId)).value ?? 0;
    return PopupMenuButton<String>(
      tooltip: 'Spotify',
      icon: Icon(
        Icons.music_note,
        color: count > 0 ? const Color(0xFF1DB954) : null,
      ),
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      onSelected: (value) async {
        if (value == 'add') {
          await AddSpotifyLinkDialog.show(context, noteId);
        } else if (value == 'remove_all' && count > 0) {
          final ok = await showConfirmDialog(
            context,
            icon: Icons.music_off_outlined,
            title: '¿Quitar todos los enlaces de Spotify?',
            message: 'Se eliminarán los $count enlaces asociados a esta nota.',
            confirmLabel: 'Quitar todos',
            destructive: true,
          );
          if (ok) {
            await ref.read(spotifyRepositoryProvider).removeAllForNote(noteId);
          }
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'add',
          child: Row(
            children: [
              Icon(Icons.add_link, size: 18),
              SizedBox(width: 10),
              Text('Vincular canción o playlist'),
            ],
          ),
        ),
        if (count > 0)
          PopupMenuItem(
            value: 'remove_all',
            child: Row(
              children: [
                const Icon(Icons.music_off_outlined, size: 18),
                const SizedBox(width: 10),
                Text('Quitar todos ($count)'),
              ],
            ),
          ),
      ],
    );
  }
}

class _SpotifyLinksSection extends ConsumerWidget {
  const _SpotifyLinksSection({required this.noteId});
  final int noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linksAsync = ref.watch(spotifyLinksByNoteProvider(noteId));
    final links = linksAsync.value ?? const [];
    if (links.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
        child: InkWell(
          onTap: () => AddSpotifyLinkDialog.show(context, noteId),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF1DB954).withValues(alpha: 0.35),
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.music_note,
                    size: 18, color: Color(0xFF1DB954)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Vincular canción o playlist de Spotify',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF1DB954),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                const Icon(Icons.add, size: 18, color: Color(0xFF1DB954)),
              ],
            ),
          ),
        ),
      );
    }
    return SpotifyLinkCarousel(
      links: links,
      onAdd: () => AddSpotifyLinkDialog.show(context, noteId),
      onRemove: (link) =>
          ref.read(spotifyRepositoryProvider).remove(link.id),
    );
  }
}
