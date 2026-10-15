import 'package:isar_community/isar.dart';

part 'spotify_link.g.dart';

enum SpotifyLinkType { track, playlist, album }

@Collection()
class SpotifyLinkEntity {
  Id id = Isar.autoIncrement;

  @Index()
  late int noteId;

  late String spotifyUri;
  late String spotifyUrl;

  @Enumerated(EnumType.name)
  late SpotifyLinkType type;

  late String title;
  late String subtitle;
  String? thumbnailUrl;

  late DateTime addedAt;
}
