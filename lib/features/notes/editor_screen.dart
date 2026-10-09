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

enum SaveStatus { pristine, dirty, saving, saved, error }

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key, this.noteId});
  final int? noteId;

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
    if (note != null) {
      _id = note.id;
      _titleCtrl.text = note.title;
      _lastTitle = note.title;
      try {
        final raw = jsonDecode(note.bodyDelta);
        if (raw is List) {
          final delta = Delta.fromJson(raw.cast<dynamic>());
          _quillCtrl.document = Document.fromDelta(delta);
        }
      } catch (_) {}
    }
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
      ..bodyPlain = plain;
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
    _discard = true;
    await _repo.softDelete(id);
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
