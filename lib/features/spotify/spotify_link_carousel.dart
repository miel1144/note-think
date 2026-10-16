import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/db/models/spotify_link.dart';
import 'spotify_providers.dart';

class SpotifyLinkCarousel extends ConsumerWidget {
  const SpotifyLinkCarousel({
    super.key,
    required this.links,
    required this.onAdd,
    required this.onRemove,
  });

  final List<SpotifyLinkEntity> links;
  final VoidCallback onAdd;
  final ValueChanged<SpotifyLinkEntity> onRemove;

  static const _tileSize = 80.0;

  static const _color = Color(0xFF1DB954);

  Future<void> _open(SpotifyLinkEntity link) async {
    final uri = Uri.parse(link.spotifyUri);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    final webUri = Uri.parse(link.spotifyUrl);
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: _tileSize + 16,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: links.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          if (i < links.length) {
            final link = links[i];
            return _CoverTile(
              link: link,
              onTap: () => _open(link),
              onRemove: () => onRemove(link),
            );
          }
          return _AddTile(onTap: onAdd);
        },
      ),
    );
  }
}

class _CoverTile extends ConsumerWidget {
  const _CoverTile({
    required this.link,
    required this.onTap,
    required this.onRemove,
  });

  final SpotifyLinkEntity link;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  IconData get _typeIcon {
    switch (link.type) {
      case SpotifyLinkType.track:
        return Icons.music_note;
      case SpotifyLinkType.playlist:
        return Icons.queue_music;
      case SpotifyLinkType.album:
        return Icons.album;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeholder = _placeholder();
    final url = link.thumbnailUrl;

    final image = url == null || url.isEmpty
        ? placeholder
        : FutureBuilder<File?>(
            future: ref.read(spotifyThumbnailCacheProvider).fileFor(url),
            builder: (context, snap) {
              final file = snap.data;
              if (file != null) return _cover(child: Image.file(file, fit: BoxFit.cover));
              if (snap.connectionState != ConnectionState.done) {
                return _cover(child: const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ));
              }
              return placeholder;
            },
          );

    return SizedBox(
      width: SpotifyLinkCarousel._tileSize,
      height: SpotifyLinkCarousel._tileSize,
      child: Tooltip(
        message: link.title,
        child: GestureDetector(
          onTap: onTap,
          onLongPress: () => _confirmRemove(context),
          child: Stack(
            children: [
              Positioned.fill(child: image),
              Positioned(
                left: 4,
                bottom: 4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    _typeIcon,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => _cover(
    child: Icon(
      _typeIcon,
      color: SpotifyLinkCarousel._color,
      size: 28,
    ),
  );

  Widget _cover({required Widget child}) => ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: ColoredBox(
      color: SpotifyLinkCarousel._color.withValues(alpha: 0.15),
      child: child,
    ),
  );

  Future<void> _confirmRemove(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.link_off, color: SpotifyLinkCarousel._color),
        title: const Text('¿Quitar este enlace?'),
        content: Text('“${link.title}” se va a desvincular de esta nota.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Quitar'),
          ),
        ],
      ),
    );
    if (ok == true) onRemove();
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: SpotifyLinkCarousel._tileSize,
      height: SpotifyLinkCarousel._tileSize,
      child: Tooltip(
        message: 'Vincular otro',
        child: Material(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: SpotifyLinkCarousel._color.withValues(alpha: 0.45),
              width: 1.4,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Center(
              child: Icon(
                Icons.add,
                size: 28,
                color: SpotifyLinkCarousel._color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}