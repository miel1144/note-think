// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spotify_link.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSpotifyLinkEntityCollection on Isar {
  IsarCollection<SpotifyLinkEntity> get spotifyLinkEntitys => this.collection();
}

const SpotifyLinkEntitySchema = CollectionSchema(
  name: r'SpotifyLinkEntity',
  id: 7928824326239282468,
  properties: {
    r'addedAt': PropertySchema(
      id: 0,
      name: r'addedAt',
      type: IsarType.dateTime,
    ),
    r'noteId': PropertySchema(id: 1, name: r'noteId', type: IsarType.long),
    r'spotifyUri': PropertySchema(
      id: 2,
      name: r'spotifyUri',
      type: IsarType.string,
    ),
    r'spotifyUrl': PropertySchema(
      id: 3,
      name: r'spotifyUrl',
      type: IsarType.string,
    ),
    r'subtitle': PropertySchema(
      id: 4,
      name: r'subtitle',
      type: IsarType.string,
    ),
    r'thumbnailUrl': PropertySchema(
      id: 5,
      name: r'thumbnailUrl',
      type: IsarType.string,
    ),
    r'title': PropertySchema(id: 6, name: r'title', type: IsarType.string),
    r'type': PropertySchema(
      id: 7,
      name: r'type',
      type: IsarType.string,
      enumMap: _SpotifyLinkEntitytypeEnumValueMap,
    ),
  },

  estimateSize: _spotifyLinkEntityEstimateSize,
  serialize: _spotifyLinkEntitySerialize,
  deserialize: _spotifyLinkEntityDeserialize,
  deserializeProp: _spotifyLinkEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'noteId': IndexSchema(
      id: -9014133502494436840,
      name: r'noteId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'noteId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _spotifyLinkEntityGetId,
  getLinks: _spotifyLinkEntityGetLinks,
  attach: _spotifyLinkEntityAttach,
  version: '3.3.2',
);

int _spotifyLinkEntityEstimateSize(
  SpotifyLinkEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.spotifyUri.length * 3;
  bytesCount += 3 + object.spotifyUrl.length * 3;
  bytesCount += 3 + object.subtitle.length * 3;
  {
    final value = object.thumbnailUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.type.name.length * 3;
  return bytesCount;
}

void _spotifyLinkEntitySerialize(
  SpotifyLinkEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.addedAt);
  writer.writeLong(offsets[1], object.noteId);
  writer.writeString(offsets[2], object.spotifyUri);
  writer.writeString(offsets[3], object.spotifyUrl);
  writer.writeString(offsets[4], object.subtitle);
  writer.writeString(offsets[5], object.thumbnailUrl);
  writer.writeString(offsets[6], object.title);
  writer.writeString(offsets[7], object.type.name);
}

SpotifyLinkEntity _spotifyLinkEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SpotifyLinkEntity();
  object.addedAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.noteId = reader.readLong(offsets[1]);
  object.spotifyUri = reader.readString(offsets[2]);
  object.spotifyUrl = reader.readString(offsets[3]);
  object.subtitle = reader.readString(offsets[4]);
  object.thumbnailUrl = reader.readStringOrNull(offsets[5]);
  object.title = reader.readString(offsets[6]);
  object.type =
      _SpotifyLinkEntitytypeValueEnumMap[reader.readStringOrNull(offsets[7])] ??
      SpotifyLinkType.track;
  return object;
}

P _spotifyLinkEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (_SpotifyLinkEntitytypeValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              SpotifyLinkType.track)
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SpotifyLinkEntitytypeEnumValueMap = {
  r'track': r'track',
  r'playlist': r'playlist',
  r'album': r'album',
};
const _SpotifyLinkEntitytypeValueEnumMap = {
  r'track': SpotifyLinkType.track,
  r'playlist': SpotifyLinkType.playlist,
  r'album': SpotifyLinkType.album,
};

Id _spotifyLinkEntityGetId(SpotifyLinkEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _spotifyLinkEntityGetLinks(
  SpotifyLinkEntity object,
) {
  return [];
}

void _spotifyLinkEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  SpotifyLinkEntity object,
) {
  object.id = id;
}

extension SpotifyLinkEntityQueryWhereSort
    on QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QWhere> {
  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterWhere> anyNoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'noteId'),
      );
    });
  }
}

extension SpotifyLinkEntityQueryWhere
    on QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QWhereClause> {
  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterWhereClause>
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterWhereClause>
  noteIdEqualTo(int noteId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'noteId', value: [noteId]),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterWhereClause>
  noteIdNotEqualTo(int noteId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'noteId',
                lower: [],
                upper: [noteId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'noteId',
                lower: [noteId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'noteId',
                lower: [noteId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'noteId',
                lower: [],
                upper: [noteId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterWhereClause>
  noteIdGreaterThan(int noteId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'noteId',
          lower: [noteId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterWhereClause>
  noteIdLessThan(int noteId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'noteId',
          lower: [],
          upper: [noteId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterWhereClause>
  noteIdBetween(
    int lowerNoteId,
    int upperNoteId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'noteId',
          lower: [lowerNoteId],
          includeLower: includeLower,
          upper: [upperNoteId],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension SpotifyLinkEntityQueryFilter
    on QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QFilterCondition> {
  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  addedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'addedAt', value: value),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  addedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'addedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  addedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'addedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  addedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'addedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  noteIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'noteId', value: value),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  noteIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'noteId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  noteIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'noteId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  noteIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'noteId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  spotifyUriEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'spotifyUri',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  spotifyUriGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'spotifyUri',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  spotifyUriLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'spotifyUri',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  spotifyUriBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'spotifyUri',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  spotifyUriStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'spotifyUri',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  spotifyUriEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'spotifyUri',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  spotifyUriContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'spotifyUri',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  spotifyUriMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'spotifyUri',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  spotifyUriIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'spotifyUri', value: ''),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  spotifyUriIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'spotifyUri', value: ''),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  spotifyUrlEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'spotifyUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  spotifyUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'spotifyUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  spotifyUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'spotifyUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  spotifyUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'spotifyUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  spotifyUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'spotifyUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  spotifyUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'spotifyUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  spotifyUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'spotifyUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  spotifyUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'spotifyUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  spotifyUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'spotifyUrl', value: ''),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  spotifyUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'spotifyUrl', value: ''),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  subtitleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'subtitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  subtitleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'subtitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  subtitleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'subtitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  subtitleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'subtitle',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  subtitleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'subtitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  subtitleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'subtitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  subtitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'subtitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  subtitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'subtitle',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  subtitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'subtitle', value: ''),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  subtitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'subtitle', value: ''),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  thumbnailUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'thumbnailUrl'),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  thumbnailUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'thumbnailUrl'),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  thumbnailUrlEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'thumbnailUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  thumbnailUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'thumbnailUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  thumbnailUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'thumbnailUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  thumbnailUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'thumbnailUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  thumbnailUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'thumbnailUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  thumbnailUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'thumbnailUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  thumbnailUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'thumbnailUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  thumbnailUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'thumbnailUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  thumbnailUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'thumbnailUrl', value: ''),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  thumbnailUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'thumbnailUrl', value: ''),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  titleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  titleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  typeEqualTo(SpotifyLinkType value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  typeGreaterThan(
    SpotifyLinkType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  typeLessThan(
    SpotifyLinkType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  typeBetween(
    SpotifyLinkType lower,
    SpotifyLinkType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'type',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  typeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  typeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'type',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterFilterCondition>
  typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'type', value: ''),
      );
    });
  }
}

extension SpotifyLinkEntityQueryObject
    on QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QFilterCondition> {}

extension SpotifyLinkEntityQueryLinks
    on QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QFilterCondition> {}

extension SpotifyLinkEntityQuerySortBy
    on QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QSortBy> {
  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  sortByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  sortByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  sortByNoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'noteId', Sort.asc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  sortByNoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'noteId', Sort.desc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  sortBySpotifyUri() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spotifyUri', Sort.asc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  sortBySpotifyUriDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spotifyUri', Sort.desc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  sortBySpotifyUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spotifyUrl', Sort.asc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  sortBySpotifyUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spotifyUrl', Sort.desc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  sortBySubtitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitle', Sort.asc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  sortBySubtitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitle', Sort.desc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  sortByThumbnailUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.asc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  sortByThumbnailUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.desc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension SpotifyLinkEntityQuerySortThenBy
    on QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QSortThenBy> {
  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  thenByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  thenByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  thenByNoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'noteId', Sort.asc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  thenByNoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'noteId', Sort.desc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  thenBySpotifyUri() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spotifyUri', Sort.asc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  thenBySpotifyUriDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spotifyUri', Sort.desc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  thenBySpotifyUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spotifyUrl', Sort.asc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  thenBySpotifyUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spotifyUrl', Sort.desc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  thenBySubtitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitle', Sort.asc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  thenBySubtitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitle', Sort.desc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  thenByThumbnailUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.asc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  thenByThumbnailUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'thumbnailUrl', Sort.desc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QAfterSortBy>
  thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension SpotifyLinkEntityQueryWhereDistinct
    on QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QDistinct> {
  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QDistinct>
  distinctByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'addedAt');
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QDistinct>
  distinctByNoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'noteId');
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QDistinct>
  distinctBySpotifyUri({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'spotifyUri', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QDistinct>
  distinctBySpotifyUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'spotifyUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QDistinct>
  distinctBySubtitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subtitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QDistinct>
  distinctByThumbnailUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'thumbnailUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QDistinct>
  distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QDistinct> distinctByType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension SpotifyLinkEntityQueryProperty
    on QueryBuilder<SpotifyLinkEntity, SpotifyLinkEntity, QQueryProperty> {
  QueryBuilder<SpotifyLinkEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SpotifyLinkEntity, DateTime, QQueryOperations>
  addedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'addedAt');
    });
  }

  QueryBuilder<SpotifyLinkEntity, int, QQueryOperations> noteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'noteId');
    });
  }

  QueryBuilder<SpotifyLinkEntity, String, QQueryOperations>
  spotifyUriProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'spotifyUri');
    });
  }

  QueryBuilder<SpotifyLinkEntity, String, QQueryOperations>
  spotifyUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'spotifyUrl');
    });
  }

  QueryBuilder<SpotifyLinkEntity, String, QQueryOperations> subtitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subtitle');
    });
  }

  QueryBuilder<SpotifyLinkEntity, String?, QQueryOperations>
  thumbnailUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'thumbnailUrl');
    });
  }

  QueryBuilder<SpotifyLinkEntity, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<SpotifyLinkEntity, SpotifyLinkType, QQueryOperations>
  typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
