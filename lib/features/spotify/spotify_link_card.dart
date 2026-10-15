import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/db/models/spotify_link.dart';

class SpotifyLinkCard extends StatelessWidget {
  const SpotifyLinkCard({
    super.key,
    required this.link,
    this.onRemove,
    this.compact = false,
  });

  final SpotifyLinkEntity link;
  final VoidCallback? onRemove;
  final bool compact;

  static const _color = Color(0xFF1DB954);

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

  String get _typeLabel {
    switch (link.type) {
      case SpotifyLinkType.track:
        return 'Canción';
      case SpotifyLinkType.playlist:
        return 'Playlist';
      case SpotifyLinkType.album:
        return 'Álbum';
    }
  }

  Future<void> _open() async {
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
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final size = compact ? 18.0 : 22.0;
    if (compact) {
      return InkWell(
        onTap: _open,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Tooltip(
            message: '$_typeLabel: ${link.title}',
            child: Icon(_typeIcon, color: _color, size: size),
          ),
        ),
      );
    }
    return Material(
      color: t.colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: _open,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: _color.withValues(alpha: 0.35)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_typeIcon, color: _color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(_typeIcon, size: 12, color: _color),
                        const SizedBox(width: 4),
                        Text(
                          _typeLabel,
                          style: t.textTheme.labelSmall?.copyWith(
                            color: _color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      link.title,
                      style: t.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (link.subtitle.isNotEmpty)
                      Text(
                        link.subtitle,
                        style: t.textTheme.bodySmall?.copyWith(
                          color: t.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (onRemove != null)
                IconButton(
                  tooltip: 'Quitar',
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onRemove,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
