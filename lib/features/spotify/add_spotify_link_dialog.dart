import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/repositories.dart';
import 'spotify_oembed_service.dart';

class AddSpotifyLinkDialog extends ConsumerStatefulWidget {
  const AddSpotifyLinkDialog({super.key, required this.noteId});
  final int noteId;

  static Future<bool> show(BuildContext context, int noteId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AddSpotifyLinkDialog(noteId: noteId),
    );
    return result ?? false;
  }

  @override
  ConsumerState<AddSpotifyLinkDialog> createState() =>
      _AddSpotifyLinkDialogState();
}

class _AddSpotifyLinkDialogState extends ConsumerState<AddSpotifyLinkDialog> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Pegá un link de Spotify');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(spotifyRepositoryProvider).addFromInput(
            noteId: widget.noteId,
            input: text,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on SpotifyOembedException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'No se pudo obtener metadata: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return AlertDialog(
      icon: const Icon(Icons.music_note, color: Color(0xFF1DB954)),
      title: const Text('Vincular canción o playlist'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Pegá el link de Spotify (canción, playlist o álbum). Lo abrimos en la app de Spotify al tocarlo.',
            style: t.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            enabled: !_loading,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'URL o URI de Spotify',
              hintText: 'https://open.spotify.com/track/...',
              errorText: _error,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.link),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _loading ? null : _submit,
          icon: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add),
          label: const Text('Vincular'),
        ),
      ],
    );
  }
}
