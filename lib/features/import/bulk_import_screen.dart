import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/models/note.dart';
import '../../core/storage/repositories.dart';
import '../../shared/widgets/neu_surface.dart';
import 'paste_import_parser.dart';

class BulkImportScreen extends ConsumerStatefulWidget {
  const BulkImportScreen({super.key});

  @override
  ConsumerState<BulkImportScreen> createState() => _BulkImportScreenState();
}

class _BulkImportScreenState extends ConsumerState<BulkImportScreen> {
  final TextEditingController _controller = TextEditingController();
  PasteImportParseResult _parsed = const PasteImportParseResult(blocks: []);
  bool _busy = false;
  bool _showHint = true;

  @override
  void initState() {
    super.initState();
    _recompute();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _recompute() {
    final result = PasteImportParser.parse(_controller.text);
    if (!mounted) return;
    setState(() => _parsed = result);
  }

  Future<void> _runImport() async {
    if (_parsed.isEmpty || _busy) return;
    final messenger = ScaffoldMessenger.of(context);
    final importTime = DateTime.now();
    final notes = <NoteEntity>[];
    for (final block in _parsed.blocks) {
      if (block.body.trim().isEmpty) continue;
      final createdAt = block.hasExplicitDate
          ? block.explicitDate!
          : importTime;
      final note = NoteEntity()
        ..title = block.title
        ..bodyPlain = block.bodyPlain
        ..bodyDelta = block.bodyDelta
        ..createdAt = createdAt
        ..updatedAt = createdAt;
      notes.add(note);
    }
    if (notes.isEmpty) return;
    setState(() => _busy = true);
    final repo = ref.read(notesRepositoryProvider);
    try {
      final inserted = await repo.bulkInsert(notes);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Importadas: $inserted de ${notes.length}'),
        ),
      );
      _controller.clear();
      _recompute();
      if (mounted) context.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo importar: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final validCount = _parsed.nonEmptyCount;
    final hasWarnings = _parsed.blocks.any((b) => b.warning != null);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar notas pegadas'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cerrar',
          onPressed: _busy ? null : () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_showHint) _FormatHint(onClose: () => setState(() => _showHint = false)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  NeuSurface(
                    radius: 14,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      minLines: 8,
                      onChanged: (_) => _recompute(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                      decoration: const InputDecoration(
                        hintText:
                            'Pegá acá tus notas separadas por una línea --- o dos blancos seguidos…',
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Vista previa',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '($validCount ${validCount == 1 ? 'nota' : 'notas'})',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface
                              .withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      if (hasWarnings)
                        Icon(
                          Icons.warning_amber_outlined,
                          size: 18,
                          color: Theme.of(context).colorScheme.error,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_parsed.isEmpty)
                    const _EmptyPreview()
                  else
                    ...List.generate(_parsed.blocks.length, (i) {
                      final b = _parsed.blocks[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _BlockPreview(index: i + 1, block: b),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: NeuSurface(
            radius: 16,
            padding: const EdgeInsets.symmetric(vertical: 14),
            onTap: (_parsed.isEmpty || _busy) ? null : _runImport,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_busy)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.content_paste_go_outlined, size: 18),
                const SizedBox(width: 10),
                Text(
                  _parsed.isEmpty
                      ? 'Esperando pegado…'
                      : 'Importar ${_parsed.nonEmptyCount} '
                          '${_parsed.nonEmptyCount == 1 ? 'nota' : 'notas'}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FormatHint extends StatelessWidget {
  const _FormatHint({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context)
        .colorScheme
        .onSurface
        .withValues(alpha: 0.6);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: NeuSurface(
        radius: 14,
        padding: const EdgeInsets.fromLTRB(14, 10, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Formato aceptado',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Cerrar',
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: onClose,
                ),
              ],
            ),
            Text(
              'Cada nota puede empezar con su fecha real entre corchetes '
              '[YYYY-MM-DD HH:MM] (opcional). Si no la ponés, usamos la '
              'fecha en que se ejecuta el import. Separá las notas con '
              'una línea en blanco o con --- entre ellas.',
              style: TextStyle(color: muted, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              '[2025-08-15 14:30]\n'
              'Esta es una nota.\n'
              '\n'
              '---\n'
              '\n'
              '2025-08-20 09:15\n'
              'Otra nota, también con fecha explícita.\n'
              '\n'
              'Una nota sin fecha explícita.\n'
              '(Queda con la fecha del import.)',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview();
  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context)
        .colorScheme
        .onSurface
        .withValues(alpha: 0.5);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.content_paste_off_outlined,
              size: 48,
              color: muted,
            ),
            const SizedBox(height: 8),
            Text(
              'Pegá texto en el recuadro para ver la vista previa.',
              style: TextStyle(color: muted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockPreview extends StatelessWidget {
  const _BlockPreview({required this.index, required this.block});
  final int index;
  final ParsedImportBlock block;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final hasWarning = block.warning != null;
    final titleEmpty = block.body.trim().isEmpty;
    final dateLabel = block.hasExplicitDate
        ? _formatDate(block.explicitDate!)
        : 'Fecha: ahora';
    return NeuSurface(
      radius: 14,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: titleEmpty
                    ? muted.withValues(alpha: 0.4)
                    : theme.colorScheme.onSurface,
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: theme.scaffoldBackgroundColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  block.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                block.hasExplicitDate
                    ? Icons.event
                    : Icons.event_busy_outlined,
                size: 14,
                color: block.hasExplicitDate
                    ? theme.colorScheme.onSurface
                    : muted,
              ),
              const SizedBox(width: 4),
              Text(
                dateLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: block.hasExplicitDate
                      ? theme.colorScheme.onSurface
                      : muted,
                ),
              ),
            ],
          ),
          if (block.body.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              block.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: muted),
            ),
          ],
          if (hasWarning) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    size: 14,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      block.warning!,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${pad(d.month)}-${pad(d.day)} '
        '${pad(d.hour)}:${pad(d.minute)}';
  }
}
