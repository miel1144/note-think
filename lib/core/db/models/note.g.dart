// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNoteEntityCollection on Isar {
  IsarCollection<NoteEntity> get noteEntitys => this.collection();
}

const NoteEntitySchema = CollectionSchema(
  name: r'NoteEntity',
  id: -8531409808967742627,
  properties: {
    r'accentHex': PropertySchema(
      id: 0,
      name: r'accentHex',
      type: IsarType.string,
    ),
    r'bodyDelta': PropertySchema(
      id: 1,
      name: r'bodyDelta',
      type: IsarType.string,
    ),
    r'bodyPlain': PropertySchema(
      id: 2,
      name: r'bodyPlain',
      type: IsarType.stringList,
    ),
    r'categoryId': PropertySchema(
      id: 3,
      name: r'categoryId',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 4,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'deletedAt': PropertySchema(
      id: 5,
      name: r'deletedAt',
      type: IsarType.dateTime,
    ),
    r'pinned': PropertySchema(id: 6, name: r'pinned', type: IsarType.bool),
    r'title': PropertySchema(id: 7, name: r'title', type: IsarType.string),
    r'updatedAt': PropertySchema(
      id: 8,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _noteEntityEstimateSize,
  serialize: _noteEntitySerialize,
  deserialize: _noteEntityDeserialize,
  deserializeProp: _noteEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'title': IndexSchema(
      id: -7636685945352118059,
      name: r'title',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'title',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'bodyPlain': IndexSchema(
      id: -6552049035748381648,
      name: r'bodyPlain',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'bodyPlain',
          type: IndexType.value,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _noteEntityGetId,
  getLinks: _noteEntityGetLinks,
  attach: _noteEntityAttach,
  version: '3.3.2',
);

int _noteEntityEstimateSize(
  NoteEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.accentHex;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.bodyDelta.length * 3;
  bytesCount += 3 + object.bodyPlain.length * 3;
  {
    for (var i = 0; i < object.bodyPlain.length; i++) {
      final value = object.bodyPlain[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _noteEntitySerialize(
  NoteEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.accentHex);
  writer.writeString(offsets[1], object.bodyDelta);
  writer.writeStringList(offsets[2], object.bodyPlain);
  writer.writeLong(offsets[3], object.categoryId);
  writer.writeDateTime(offsets[4], object.createdAt);
  writer.writeDateTime(offsets[5], object.deletedAt);
  writer.writeBool(offsets[6], object.pinned);
  writer.writeString(offsets[7], object.title);
  writer.writeDateTime(offsets[8], object.updatedAt);
}

NoteEntity _noteEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NoteEntity();
  object.accentHex = reader.readStringOrNull(offsets[0]);
  object.bodyDelta = reader.readString(offsets[1]);
  object.bodyPlain = reader.readStringList(offsets[2]) ?? [];
  object.categoryId = reader.readLongOrNull(offsets[3]);
  object.createdAt = reader.readDateTime(offsets[4]);
  object.deletedAt = reader.readDateTimeOrNull(offsets[5]);
  object.id = id;
  object.pinned = reader.readBool(offsets[6]);
  object.title = reader.readString(offsets[7]);
  object.updatedAt = reader.readDateTime(offsets[8]);
  return object;
}

P _noteEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _noteEntityGetId(NoteEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _noteEntityGetLinks(NoteEntity object) {
  return [];
}

void _noteEntityAttach(IsarCollection<dynamic> col, Id id, NoteEntity object) {
  object.id = id;
}

extension NoteEntityQueryWhereSort
    on QueryBuilder<NoteEntity, NoteEntity, QWhere> {
  QueryBuilder<NoteEntity, NoteEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterWhere> anyTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'title'),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterWhere> anyBodyPlainElement() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'bodyPlain'),
      );
    });
  }
}

extension NoteEntityQueryWhere
    on QueryBuilder<NoteEntity, NoteEntity, QWhereClause> {
  QueryBuilder<NoteEntity, NoteEntity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterWhereClause> titleEqualTo(
    String title,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'title', value: [title]),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterWhereClause> titleNotEqualTo(
    String title,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'title',
                lower: [],
                upper: [title],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'title',
                lower: [title],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'title',
                lower: [title],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'title',
                lower: [],
                upper: [title],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterWhereClause> titleGreaterThan(
    String title, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'title',
          lower: [title],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterWhereClause> titleLessThan(
    String title, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'title',
          lower: [],
          upper: [title],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterWhereClause> titleBetween(
    String lowerTitle,
    String upperTitle, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'title',
          lower: [lowerTitle],
          includeLower: includeLower,
          upper: [upperTitle],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterWhereClause> titleStartsWith(
    String TitlePrefix,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'title',
          lower: [TitlePrefix],
          upper: ['$TitlePrefix\u{FFFFF}'],
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterWhereClause> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'title', value: ['']),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterWhereClause> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.lessThan(indexName: r'title', upper: ['']),
            )
            .addWhereClause(
              IndexWhereClause.greaterThan(indexName: r'title', lower: ['']),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.greaterThan(indexName: r'title', lower: ['']),
            )
            .addWhereClause(
              IndexWhereClause.lessThan(indexName: r'title', upper: ['']),
            );
      }
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterWhereClause>
  bodyPlainElementEqualTo(String bodyPlainElement) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'bodyPlain',
          value: [bodyPlainElement],
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterWhereClause>
  bodyPlainElementNotEqualTo(String bodyPlainElement) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'bodyPlain',
                lower: [],
                upper: [bodyPlainElement],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'bodyPlain',
                lower: [bodyPlainElement],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'bodyPlain',
                lower: [bodyPlainElement],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'bodyPlain',
                lower: [],
                upper: [bodyPlainElement],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterWhereClause>
  bodyPlainElementGreaterThan(String bodyPlainElement, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'bodyPlain',
          lower: [bodyPlainElement],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterWhereClause>
  bodyPlainElementLessThan(String bodyPlainElement, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'bodyPlain',
          lower: [],
          upper: [bodyPlainElement],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterWhereClause>
  bodyPlainElementBetween(
    String lowerBodyPlainElement,
    String upperBodyPlainElement, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'bodyPlain',
          lower: [lowerBodyPlainElement],
          includeLower: includeLower,
          upper: [upperBodyPlainElement],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterWhereClause>
  bodyPlainElementStartsWith(String BodyPlainElementPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'bodyPlain',
          lower: [BodyPlainElementPrefix],
          upper: ['$BodyPlainElementPrefix\u{FFFFF}'],
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterWhereClause>
  bodyPlainElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'bodyPlain', value: ['']),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterWhereClause>
  bodyPlainElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.lessThan(indexName: r'bodyPlain', upper: ['']),
            )
            .addWhereClause(
              IndexWhereClause.greaterThan(
                indexName: r'bodyPlain',
                lower: [''],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.greaterThan(
                indexName: r'bodyPlain',
                lower: [''],
              ),
            )
            .addWhereClause(
              IndexWhereClause.lessThan(indexName: r'bodyPlain', upper: ['']),
            );
      }
    });
  }
}

extension NoteEntityQueryFilter
    on QueryBuilder<NoteEntity, NoteEntity, QFilterCondition> {
  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  accentHexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'accentHex'),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  accentHexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'accentHex'),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> accentHexEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'accentHex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  accentHexGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'accentHex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> accentHexLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'accentHex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> accentHexBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'accentHex',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  accentHexStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'accentHex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> accentHexEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'accentHex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> accentHexContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'accentHex',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> accentHexMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'accentHex',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  accentHexIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'accentHex', value: ''),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  accentHexIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'accentHex', value: ''),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> bodyDeltaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'bodyDelta',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  bodyDeltaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'bodyDelta',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> bodyDeltaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'bodyDelta',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> bodyDeltaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'bodyDelta',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  bodyDeltaStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'bodyDelta',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> bodyDeltaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'bodyDelta',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> bodyDeltaContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'bodyDelta',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> bodyDeltaMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'bodyDelta',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  bodyDeltaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'bodyDelta', value: ''),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  bodyDeltaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'bodyDelta', value: ''),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  bodyPlainElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'bodyPlain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  bodyPlainElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'bodyPlain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  bodyPlainElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'bodyPlain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  bodyPlainElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'bodyPlain',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  bodyPlainElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'bodyPlain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  bodyPlainElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'bodyPlain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  bodyPlainElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'bodyPlain',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  bodyPlainElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'bodyPlain',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  bodyPlainElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'bodyPlain', value: ''),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  bodyPlainElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'bodyPlain', value: ''),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  bodyPlainLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'bodyPlain', length, true, length, true);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  bodyPlainIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'bodyPlain', 0, true, 0, true);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  bodyPlainIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'bodyPlain', 0, false, 999999, true);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  bodyPlainLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'bodyPlain', 0, true, length, include);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  bodyPlainLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'bodyPlain', length, include, 999999, true);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  bodyPlainLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'bodyPlain',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  categoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'categoryId'),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  categoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'categoryId'),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> categoryIdEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'categoryId', value: value),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  categoryIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'categoryId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  categoryIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'categoryId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> categoryIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'categoryId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  deletedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'deletedAt'),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  deletedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'deletedAt'),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> deletedAtEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'deletedAt', value: value),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  deletedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'deletedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> deletedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'deletedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> deletedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'deletedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> pinnedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'pinned', value: value),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> titleGreaterThan(
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> titleLessThan(
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> titleBetween(
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> titleContains(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> titleMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> updatedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension NoteEntityQueryObject
    on QueryBuilder<NoteEntity, NoteEntity, QFilterCondition> {}

extension NoteEntityQueryLinks
    on QueryBuilder<NoteEntity, NoteEntity, QFilterCondition> {}

extension NoteEntityQuerySortBy
    on QueryBuilder<NoteEntity, NoteEntity, QSortBy> {
  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByAccentHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentHex', Sort.asc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByAccentHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentHex', Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByBodyDelta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyDelta', Sort.asc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByBodyDeltaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyDelta', Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinned', Sort.asc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByPinnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinned', Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension NoteEntityQuerySortThenBy
    on QueryBuilder<NoteEntity, NoteEntity, QSortThenBy> {
  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByAccentHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentHex', Sort.asc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByAccentHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentHex', Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByBodyDelta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyDelta', Sort.asc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByBodyDeltaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyDelta', Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.asc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByDeletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deletedAt', Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinned', Sort.asc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByPinnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pinned', Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension NoteEntityQueryWhereDistinct
    on QueryBuilder<NoteEntity, NoteEntity, QDistinct> {
  QueryBuilder<NoteEntity, NoteEntity, QDistinct> distinctByAccentHex({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accentHex', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QDistinct> distinctByBodyDelta({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bodyDelta', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QDistinct> distinctByBodyPlain() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bodyPlain');
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QDistinct> distinctByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryId');
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QDistinct> distinctByDeletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deletedAt');
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QDistinct> distinctByPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pinned');
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NoteEntity, NoteEntity, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension NoteEntityQueryProperty
    on QueryBuilder<NoteEntity, NoteEntity, QQueryProperty> {
  QueryBuilder<NoteEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<NoteEntity, String?, QQueryOperations> accentHexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accentHex');
    });
  }

  QueryBuilder<NoteEntity, String, QQueryOperations> bodyDeltaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bodyDelta');
    });
  }

  QueryBuilder<NoteEntity, List<String>, QQueryOperations> bodyPlainProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bodyPlain');
    });
  }

  QueryBuilder<NoteEntity, int?, QQueryOperations> categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryId');
    });
  }

  QueryBuilder<NoteEntity, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<NoteEntity, DateTime?, QQueryOperations> deletedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deletedAt');
    });
  }

  QueryBuilder<NoteEntity, bool, QQueryOperations> pinnedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pinned');
    });
  }

  QueryBuilder<NoteEntity, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<NoteEntity, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
