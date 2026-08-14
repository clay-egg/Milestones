// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class Categorie extends DataClass implements Insertable<Categorie> {
  final int id;
  final String name;
  final String role;
  final int weeklyTarget;
  Categorie({required this.id, required this.name, required this.role, this.weeklyTarget = 0});
  factory Categorie.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return Categorie(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      name: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      role: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}role'])!,
      weeklyTarget: const IntType()
              .mapFromDatabaseResponse(data['${effectivePrefix}weekly_target']) ??
          0,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['role'] = Variable<String>(role);
    map['weekly_target'] = Variable<int>(weeklyTarget);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      role: Value(role),
      weeklyTarget: Value(weeklyTarget),
    );
  }

  factory Categorie.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Categorie(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      role: serializer.fromJson<String>(json['role']),
      weeklyTarget: json['weeklyTarget'] != null ? serializer.fromJson<int>(json['weeklyTarget']) : 0,
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'role': serializer.toJson<String>(role),
      'weeklyTarget': serializer.toJson<int>(weeklyTarget),
    };
  }

  Categorie copyWith({int? id, String? name, String? role, int? weeklyTarget}) => Categorie(
        id: id ?? this.id,
        name: name ?? this.name,
        role: role ?? this.role,
        weeklyTarget: weeklyTarget ?? this.weeklyTarget,
      );
  @override
  String toString() {
    return (StringBuffer('Categorie(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('weeklyTarget: $weeklyTarget')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, role, weeklyTarget);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Categorie &&
          other.id == this.id &&
          other.name == this.name &&
          other.role == this.role &&
          other.weeklyTarget == this.weeklyTarget);
}

class CategoriesCompanion extends UpdateCompanion<Categorie> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> role;
  final Value<int> weeklyTarget;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.weeklyTarget = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String role,
    this.weeklyTarget = const Value.absent(),
  })  : name = Value(name),
        role = Value(role);
  static Insertable<Categorie> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? role,
    Expression<int>? weeklyTarget,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (weeklyTarget != null) 'weekly_target': weeklyTarget,
    });
  }

  CategoriesCompanion copyWith(
      {Value<int>? id, Value<String>? name, Value<String>? role, Value<int>? weeklyTarget}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      weeklyTarget: weeklyTarget ?? this.weeklyTarget,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (weeklyTarget.present) {
      map['weekly_target'] = Variable<int>(weeklyTarget.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('weeklyTarget: $weeklyTarget')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Categorie> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String?> name = GeneratedColumn<String?>(
      'name', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String?> role = GeneratedColumn<String?>(
      'role', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _weeklyTargetMeta = const VerificationMeta('weeklyTarget');
  @override
  late final GeneratedColumn<int?> weeklyTarget = GeneratedColumn<int?>(
      'weekly_target', aliasedName, true,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [id, name, role, weeklyTarget];
  @override
  String get aliasedName => _alias ?? 'categories';
  @override
  String get actualTableName => 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Categorie> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Categorie map(Map<String, dynamic> data, {String? tablePrefix}) {
    return Categorie.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Entrie extends DataClass implements Insertable<Entrie> {
  final int id;
  final DateTime date;
  final String description;
  final int categoryId;
  final String? project;
  final String tags;
  final String? notes;
  Entrie(
      {required this.id,
      required this.date,
      required this.description,
      required this.categoryId,
      this.project,
      required this.tags,
      this.notes});
  factory Entrie.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return Entrie(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      date: const DateTimeType()
          .mapFromDatabaseResponse(data['${effectivePrefix}date'])!,
      description: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}description'])!,
      categoryId: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}category_id'])!,
      project: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}project']),
      tags: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}tags'])!,
      notes: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}notes']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['description'] = Variable<String>(description);
    map['category_id'] = Variable<int>(categoryId);
    if (!nullToAbsent || project != null) {
      map['project'] = Variable<String?>(project);
    }
    map['tags'] = Variable<String>(tags);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String?>(notes);
    }
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      id: Value(id),
      date: Value(date),
      description: Value(description),
      categoryId: Value(categoryId),
      project: project == null && nullToAbsent
          ? const Value.absent()
          : Value(project),
      tags: Value(tags),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Entrie.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entrie(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      description: serializer.fromJson<String>(json['description']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      project: serializer.fromJson<String?>(json['project']),
      tags: serializer.fromJson<String>(json['tags']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'description': serializer.toJson<String>(description),
      'categoryId': serializer.toJson<int>(categoryId),
      'project': serializer.toJson<String?>(project),
      'tags': serializer.toJson<String>(tags),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Entrie copyWith(
          {int? id,
          DateTime? date,
          String? description,
          int? categoryId,
          String? project,
          String? tags,
          String? notes}) =>
      Entrie(
        id: id ?? this.id,
        date: date ?? this.date,
        description: description ?? this.description,
        categoryId: categoryId ?? this.categoryId,
        project: project ?? this.project,
        tags: tags ?? this.tags,
        notes: notes ?? this.notes,
      );
  @override
  String toString() {
    return (StringBuffer('Entrie(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('project: $project, ')
          ..write('tags: $tags, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, description, categoryId, project, tags, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entrie &&
          other.id == this.id &&
          other.date == this.date &&
          other.description == this.description &&
          other.categoryId == this.categoryId &&
          other.project == this.project &&
          other.tags == this.tags &&
          other.notes == this.notes);
}

class EntriesCompanion extends UpdateCompanion<Entrie> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> description;
  final Value<int> categoryId;
  final Value<String?> project;
  final Value<String> tags;
  final Value<String?> notes;
  const EntriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.description = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.project = const Value.absent(),
    this.tags = const Value.absent(),
    this.notes = const Value.absent(),
  });
  EntriesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String description,
    required int categoryId,
    this.project = const Value.absent(),
    required String tags,
    this.notes = const Value.absent(),
  })  : date = Value(date),
        description = Value(description),
        categoryId = Value(categoryId),
        tags = Value(tags);
  static Insertable<Entrie> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? description,
    Expression<int>? categoryId,
    Expression<String?>? project,
    Expression<String>? tags,
    Expression<String?>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (description != null) 'description': description,
      if (categoryId != null) 'category_id': categoryId,
      if (project != null) 'project': project,
      if (tags != null) 'tags': tags,
      if (notes != null) 'notes': notes,
    });
  }

  EntriesCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? date,
      Value<String>? description,
      Value<int>? categoryId,
      Value<String?>? project,
      Value<String>? tags,
      Value<String?>? notes}) {
    return EntriesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      project: project ?? this.project,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (project.present) {
      map['project'] = Variable<String?>(project.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String?>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('project: $project, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }
}

class $EntriesTable extends Entries with TableInfo<$EntriesTable, Entrie> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntriesTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime?> date = GeneratedColumn<DateTime?>(
      'date', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String?> description = GeneratedColumn<String?>(
      'description', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _categoryIdMeta = const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int?> categoryId = GeneratedColumn<int?>(
      'category_id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: true,
      defaultConstraints: 'REFERENCES categories (id)');
  final VerificationMeta _projectMeta = const VerificationMeta('project');
  @override
  late final GeneratedColumn<String?> project = GeneratedColumn<String?>(
      'project', aliasedName, true,
      type: const StringType(), requiredDuringInsert: false);
  final VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String?> tags = GeneratedColumn<String?>(
      'tags', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String?> notes = GeneratedColumn<String?>(
      'notes', aliasedName, true,
      type: const StringType(), requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, date, description, categoryId, project, tags, notes];
  @override
  String get aliasedName => _alias ?? 'entries';
  @override
  String get actualTableName => 'entries';
  @override
  VerificationContext validateIntegrity(Insertable<Entrie> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('project')) {
      context.handle(_projectMeta,
          project.isAcceptableOrUnknown(data['project']!, _projectMeta));
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    } else if (isInserting) {
      context.missing(_tagsMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Entrie map(Map<String, dynamic> data, {String? tablePrefix}) {
    return Entrie.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $EntriesTable createAlias(String alias) {
    return $EntriesTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final int id;
  final String name;
  final String stepsJson;
  final String achievementsJson;
  Project(
      {required this.id,
      required this.name,
      required this.stepsJson,
      required this.achievementsJson});
  factory Project.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return Project(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      name: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      stepsJson: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}steps_json'])!,
      achievementsJson: const StringType().mapFromDatabaseResponse(
          data['${effectivePrefix}achievements_json'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['steps_json'] = Variable<String>(stepsJson);
    map['achievements_json'] = Variable<String>(achievementsJson);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      stepsJson: Value(stepsJson),
      achievementsJson: Value(achievementsJson),
    );
  }

  factory Project.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      stepsJson: serializer.fromJson<String>(json['stepsJson']),
      achievementsJson: serializer.fromJson<String>(json['achievementsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'stepsJson': serializer.toJson<String>(stepsJson),
      'achievementsJson': serializer.toJson<String>(achievementsJson),
    };
  }

  Project copyWith(
          {int? id,
          String? name,
          String? stepsJson,
          String? achievementsJson}) =>
      Project(
        id: id ?? this.id,
        name: name ?? this.name,
        stepsJson: stepsJson ?? this.stepsJson,
        achievementsJson: achievementsJson ?? this.achievementsJson,
      );
  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('stepsJson: $stepsJson, ')
          ..write('achievementsJson: $achievementsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, stepsJson, achievementsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.name == this.name &&
          other.stepsJson == this.stepsJson &&
          other.achievementsJson == this.achievementsJson);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> stepsJson;
  final Value<String> achievementsJson;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.stepsJson = const Value.absent(),
    this.achievementsJson = const Value.absent(),
  });
  ProjectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String stepsJson,
    required String achievementsJson,
  })  : name = Value(name),
        stepsJson = Value(stepsJson),
        achievementsJson = Value(achievementsJson);
  static Insertable<Project> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? stepsJson,
    Expression<String>? achievementsJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (stepsJson != null) 'steps_json': stepsJson,
      if (achievementsJson != null) 'achievements_json': achievementsJson,
    });
  }

  ProjectsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? stepsJson,
      Value<String>? achievementsJson}) {
    return ProjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      stepsJson: stepsJson ?? this.stepsJson,
      achievementsJson: achievementsJson ?? this.achievementsJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (stepsJson.present) {
      map['steps_json'] = Variable<String>(stepsJson.value);
    }
    if (achievementsJson.present) {
      map['achievements_json'] = Variable<String>(achievementsJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('stepsJson: $stepsJson, ')
          ..write('achievementsJson: $achievementsJson')
          ..write(')'))
        .toString();
  }
}

class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String?> name = GeneratedColumn<String?>(
      'name', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _stepsJsonMeta = const VerificationMeta('stepsJson');
  @override
  late final GeneratedColumn<String?> stepsJson = GeneratedColumn<String?>(
      'steps_json', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _achievementsJsonMeta =
      const VerificationMeta('achievementsJson');
  @override
  late final GeneratedColumn<String?> achievementsJson =
      GeneratedColumn<String?>('achievements_json', aliasedName, false,
          type: const StringType(), requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, stepsJson, achievementsJson];
  @override
  String get aliasedName => _alias ?? 'projects';
  @override
  String get actualTableName => 'projects';
  @override
  VerificationContext validateIntegrity(Insertable<Project> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('steps_json')) {
      context.handle(_stepsJsonMeta,
          stepsJson.isAcceptableOrUnknown(data['steps_json']!, _stepsJsonMeta));
    } else if (isInserting) {
      context.missing(_stepsJsonMeta);
    }
    if (data.containsKey('achievements_json')) {
      context.handle(
          _achievementsJsonMeta,
          achievementsJson.isAcceptableOrUnknown(
              data['achievements_json']!, _achievementsJsonMeta));
    } else if (isInserting) {
      context.missing(_achievementsJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    return Project.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Skill extends DataClass implements Insertable<Skill> {
  final int id;
  final String name;
  final double progressPercent;
  final String evidenceJson;
  Skill(
      {required this.id,
      required this.name,
      required this.progressPercent,
      required this.evidenceJson});
  factory Skill.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return Skill(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      name: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      progressPercent: const RealType()
          .mapFromDatabaseResponse(data['${effectivePrefix}progress_percent'])!,
      evidenceJson: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}evidence_json'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['progress_percent'] = Variable<double>(progressPercent);
    map['evidence_json'] = Variable<String>(evidenceJson);
    return map;
  }

  SkillsCompanion toCompanion(bool nullToAbsent) {
    return SkillsCompanion(
      id: Value(id),
      name: Value(name),
      progressPercent: Value(progressPercent),
      evidenceJson: Value(evidenceJson),
    );
  }

  factory Skill.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Skill(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      progressPercent: serializer.fromJson<double>(json['progressPercent']),
      evidenceJson: serializer.fromJson<String>(json['evidenceJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'progressPercent': serializer.toJson<double>(progressPercent),
      'evidenceJson': serializer.toJson<String>(evidenceJson),
    };
  }

  Skill copyWith(
          {int? id,
          String? name,
          double? progressPercent,
          String? evidenceJson}) =>
      Skill(
        id: id ?? this.id,
        name: name ?? this.name,
        progressPercent: progressPercent ?? this.progressPercent,
        evidenceJson: evidenceJson ?? this.evidenceJson,
      );
  @override
  String toString() {
    return (StringBuffer('Skill(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('progressPercent: $progressPercent, ')
          ..write('evidenceJson: $evidenceJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, progressPercent, evidenceJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Skill &&
          other.id == this.id &&
          other.name == this.name &&
          other.progressPercent == this.progressPercent &&
          other.evidenceJson == this.evidenceJson);
}

class SkillsCompanion extends UpdateCompanion<Skill> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> progressPercent;
  final Value<String> evidenceJson;
  const SkillsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.progressPercent = const Value.absent(),
    this.evidenceJson = const Value.absent(),
  });
  SkillsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double progressPercent,
    required String evidenceJson,
  })  : name = Value(name),
        progressPercent = Value(progressPercent),
        evidenceJson = Value(evidenceJson);
  static Insertable<Skill> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? progressPercent,
    Expression<String>? evidenceJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (progressPercent != null) 'progress_percent': progressPercent,
      if (evidenceJson != null) 'evidence_json': evidenceJson,
    });
  }

  SkillsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<double>? progressPercent,
      Value<String>? evidenceJson}) {
    return SkillsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      progressPercent: progressPercent ?? this.progressPercent,
      evidenceJson: evidenceJson ?? this.evidenceJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (progressPercent.present) {
      map['progress_percent'] = Variable<double>(progressPercent.value);
    }
    if (evidenceJson.present) {
      map['evidence_json'] = Variable<String>(evidenceJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SkillsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('progressPercent: $progressPercent, ')
          ..write('evidenceJson: $evidenceJson')
          ..write(')'))
        .toString();
  }
}

class $SkillsTable extends Skills with TableInfo<$SkillsTable, Skill> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SkillsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String?> name = GeneratedColumn<String?>(
      'name', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _progressPercentMeta =
      const VerificationMeta('progressPercent');
  @override
  late final GeneratedColumn<double?> progressPercent =
      GeneratedColumn<double?>('progress_percent', aliasedName, false,
          type: const RealType(), requiredDuringInsert: true);
  final VerificationMeta _evidenceJsonMeta =
      const VerificationMeta('evidenceJson');
  @override
  late final GeneratedColumn<String?> evidenceJson = GeneratedColumn<String?>(
      'evidence_json', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, progressPercent, evidenceJson];
  @override
  String get aliasedName => _alias ?? 'skills';
  @override
  String get actualTableName => 'skills';
  @override
  VerificationContext validateIntegrity(Insertable<Skill> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('progress_percent')) {
      context.handle(
          _progressPercentMeta,
          progressPercent.isAcceptableOrUnknown(
              data['progress_percent']!, _progressPercentMeta));
    } else if (isInserting) {
      context.missing(_progressPercentMeta);
    }
    if (data.containsKey('evidence_json')) {
      context.handle(
          _evidenceJsonMeta,
          evidenceJson.isAcceptableOrUnknown(
              data['evidence_json']!, _evidenceJsonMeta));
    } else if (isInserting) {
      context.missing(_evidenceJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Skill map(Map<String, dynamic> data, {String? tablePrefix}) {
    return Skill.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $SkillsTable createAlias(String alias) {
    return $SkillsTable(attachedDatabase, alias);
  }
}

class Goal extends DataClass implements Insertable<Goal> {
  final int id;
  final String name;
  final String currentStage;
  final String targetStage;
  Goal(
      {required this.id,
      required this.name,
      required this.currentStage,
      required this.targetStage});
  factory Goal.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return Goal(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      name: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}name'])!,
      currentStage: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}current_stage'])!,
      targetStage: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}target_stage'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['current_stage'] = Variable<String>(currentStage);
    map['target_stage'] = Variable<String>(targetStage);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      name: Value(name),
      currentStage: Value(currentStage),
      targetStage: Value(targetStage),
    );
  }

  factory Goal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Goal(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      currentStage: serializer.fromJson<String>(json['currentStage']),
      targetStage: serializer.fromJson<String>(json['targetStage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'currentStage': serializer.toJson<String>(currentStage),
      'targetStage': serializer.toJson<String>(targetStage),
    };
  }

  Goal copyWith(
          {int? id, String? name, String? currentStage, String? targetStage}) =>
      Goal(
        id: id ?? this.id,
        name: name ?? this.name,
        currentStage: currentStage ?? this.currentStage,
        targetStage: targetStage ?? this.targetStage,
      );
  @override
  String toString() {
    return (StringBuffer('Goal(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('currentStage: $currentStage, ')
          ..write('targetStage: $targetStage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, currentStage, targetStage);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          other.id == this.id &&
          other.name == this.name &&
          other.currentStage == this.currentStage &&
          other.targetStage == this.targetStage);
}

class GoalsCompanion extends UpdateCompanion<Goal> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> currentStage;
  final Value<String> targetStage;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.currentStage = const Value.absent(),
    this.targetStage = const Value.absent(),
  });
  GoalsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String currentStage,
    required String targetStage,
  })  : name = Value(name),
        currentStage = Value(currentStage),
        targetStage = Value(targetStage);
  static Insertable<Goal> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? currentStage,
    Expression<String>? targetStage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (currentStage != null) 'current_stage': currentStage,
      if (targetStage != null) 'target_stage': targetStage,
    });
  }

  GoalsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? currentStage,
      Value<String>? targetStage}) {
    return GoalsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      currentStage: currentStage ?? this.currentStage,
      targetStage: targetStage ?? this.targetStage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (currentStage.present) {
      map['current_stage'] = Variable<String>(currentStage.value);
    }
    if (targetStage.present) {
      map['target_stage'] = Variable<String>(targetStage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('currentStage: $currentStage, ')
          ..write('targetStage: $targetStage')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, Goal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String?> name = GeneratedColumn<String?>(
      'name', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _currentStageMeta =
      const VerificationMeta('currentStage');
  @override
  late final GeneratedColumn<String?> currentStage = GeneratedColumn<String?>(
      'current_stage', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _targetStageMeta =
      const VerificationMeta('targetStage');
  @override
  late final GeneratedColumn<String?> targetStage = GeneratedColumn<String?>(
      'target_stage', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, currentStage, targetStage];
  @override
  String get aliasedName => _alias ?? 'goals';
  @override
  String get actualTableName => 'goals';
  @override
  VerificationContext validateIntegrity(Insertable<Goal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('current_stage')) {
      context.handle(
          _currentStageMeta,
          currentStage.isAcceptableOrUnknown(
              data['current_stage']!, _currentStageMeta));
    } else if (isInserting) {
      context.missing(_currentStageMeta);
    }
    if (data.containsKey('target_stage')) {
      context.handle(
          _targetStageMeta,
          targetStage.isAcceptableOrUnknown(
              data['target_stage']!, _targetStageMeta));
    } else if (isInserting) {
      context.missing(_targetStageMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Goal map(Map<String, dynamic> data, {String? tablePrefix}) {
    return Goal.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class Reflection extends DataClass implements Insertable<Reflection> {
  final int id;
  final String monthYear;
  final String achieved;
  final String challenges;
  final String nextMonth;
  Reflection(
      {required this.id,
      required this.monthYear,
      required this.achieved,
      required this.challenges,
      required this.nextMonth});
  factory Reflection.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return Reflection(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      monthYear: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}month_year'])!,
      achieved: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}achieved'])!,
      challenges: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}challenges'])!,
      nextMonth: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}next_month'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['month_year'] = Variable<String>(monthYear);
    map['achieved'] = Variable<String>(achieved);
    map['challenges'] = Variable<String>(challenges);
    map['next_month'] = Variable<String>(nextMonth);
    return map;
  }

  ReflectionsCompanion toCompanion(bool nullToAbsent) {
    return ReflectionsCompanion(
      id: Value(id),
      monthYear: Value(monthYear),
      achieved: Value(achieved),
      challenges: Value(challenges),
      nextMonth: Value(nextMonth),
    );
  }

  factory Reflection.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reflection(
      id: serializer.fromJson<int>(json['id']),
      monthYear: serializer.fromJson<String>(json['monthYear']),
      achieved: serializer.fromJson<String>(json['achieved']),
      challenges: serializer.fromJson<String>(json['challenges']),
      nextMonth: serializer.fromJson<String>(json['nextMonth']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'monthYear': serializer.toJson<String>(monthYear),
      'achieved': serializer.toJson<String>(achieved),
      'challenges': serializer.toJson<String>(challenges),
      'nextMonth': serializer.toJson<String>(nextMonth),
    };
  }

  Reflection copyWith(
          {int? id,
          String? monthYear,
          String? achieved,
          String? challenges,
          String? nextMonth}) =>
      Reflection(
        id: id ?? this.id,
        monthYear: monthYear ?? this.monthYear,
        achieved: achieved ?? this.achieved,
        challenges: challenges ?? this.challenges,
        nextMonth: nextMonth ?? this.nextMonth,
      );
  @override
  String toString() {
    return (StringBuffer('Reflection(')
          ..write('id: $id, ')
          ..write('monthYear: $monthYear, ')
          ..write('achieved: $achieved, ')
          ..write('challenges: $challenges, ')
          ..write('nextMonth: $nextMonth')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, monthYear, achieved, challenges, nextMonth);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reflection &&
          other.id == this.id &&
          other.monthYear == this.monthYear &&
          other.achieved == this.achieved &&
          other.challenges == this.challenges &&
          other.nextMonth == this.nextMonth);
}

class ReflectionsCompanion extends UpdateCompanion<Reflection> {
  final Value<int> id;
  final Value<String> monthYear;
  final Value<String> achieved;
  final Value<String> challenges;
  final Value<String> nextMonth;
  const ReflectionsCompanion({
    this.id = const Value.absent(),
    this.monthYear = const Value.absent(),
    this.achieved = const Value.absent(),
    this.challenges = const Value.absent(),
    this.nextMonth = const Value.absent(),
  });
  ReflectionsCompanion.insert({
    this.id = const Value.absent(),
    required String monthYear,
    required String achieved,
    required String challenges,
    required String nextMonth,
  })  : monthYear = Value(monthYear),
        achieved = Value(achieved),
        challenges = Value(challenges),
        nextMonth = Value(nextMonth);
  static Insertable<Reflection> custom({
    Expression<int>? id,
    Expression<String>? monthYear,
    Expression<String>? achieved,
    Expression<String>? challenges,
    Expression<String>? nextMonth,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (monthYear != null) 'month_year': monthYear,
      if (achieved != null) 'achieved': achieved,
      if (challenges != null) 'challenges': challenges,
      if (nextMonth != null) 'next_month': nextMonth,
    });
  }

  ReflectionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? monthYear,
      Value<String>? achieved,
      Value<String>? challenges,
      Value<String>? nextMonth}) {
    return ReflectionsCompanion(
      id: id ?? this.id,
      monthYear: monthYear ?? this.monthYear,
      achieved: achieved ?? this.achieved,
      challenges: challenges ?? this.challenges,
      nextMonth: nextMonth ?? this.nextMonth,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (monthYear.present) {
      map['month_year'] = Variable<String>(monthYear.value);
    }
    if (achieved.present) {
      map['achieved'] = Variable<String>(achieved.value);
    }
    if (challenges.present) {
      map['challenges'] = Variable<String>(challenges.value);
    }
    if (nextMonth.present) {
      map['next_month'] = Variable<String>(nextMonth.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReflectionsCompanion(')
          ..write('id: $id, ')
          ..write('monthYear: $monthYear, ')
          ..write('achieved: $achieved, ')
          ..write('challenges: $challenges, ')
          ..write('nextMonth: $nextMonth')
          ..write(')'))
        .toString();
  }
}

class $ReflectionsTable extends Reflections
    with TableInfo<$ReflectionsTable, Reflection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReflectionsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _monthYearMeta = const VerificationMeta('monthYear');
  @override
  late final GeneratedColumn<String?> monthYear = GeneratedColumn<String?>(
      'month_year', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _achievedMeta = const VerificationMeta('achieved');
  @override
  late final GeneratedColumn<String?> achieved = GeneratedColumn<String?>(
      'achieved', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _challengesMeta = const VerificationMeta('challenges');
  @override
  late final GeneratedColumn<String?> challenges = GeneratedColumn<String?>(
      'challenges', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  final VerificationMeta _nextMonthMeta = const VerificationMeta('nextMonth');
  @override
  late final GeneratedColumn<String?> nextMonth = GeneratedColumn<String?>(
      'next_month', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, monthYear, achieved, challenges, nextMonth];
  @override
  String get aliasedName => _alias ?? 'reflections';
  @override
  String get actualTableName => 'reflections';
  @override
  VerificationContext validateIntegrity(Insertable<Reflection> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('month_year')) {
      context.handle(_monthYearMeta,
          monthYear.isAcceptableOrUnknown(data['month_year']!, _monthYearMeta));
    } else if (isInserting) {
      context.missing(_monthYearMeta);
    }
    if (data.containsKey('achieved')) {
      context.handle(_achievedMeta,
          achieved.isAcceptableOrUnknown(data['achieved']!, _achievedMeta));
    } else if (isInserting) {
      context.missing(_achievedMeta);
    }
    if (data.containsKey('challenges')) {
      context.handle(
          _challengesMeta,
          challenges.isAcceptableOrUnknown(
              data['challenges']!, _challengesMeta));
    } else if (isInserting) {
      context.missing(_challengesMeta);
    }
    if (data.containsKey('next_month')) {
      context.handle(_nextMonthMeta,
          nextMonth.isAcceptableOrUnknown(data['next_month']!, _nextMonthMeta));
    } else if (isInserting) {
      context.missing(_nextMonthMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reflection map(Map<String, dynamic> data, {String? tablePrefix}) {
    return Reflection.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $ReflectionsTable createAlias(String alias) {
    return $ReflectionsTable(attachedDatabase, alias);
  }
}

class Milestone extends DataClass implements Insertable<Milestone> {
  final int id;
  final int year;
  final String label;
  Milestone({required this.id, required this.year, required this.label});
  factory Milestone.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return Milestone(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      year: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}year'])!,
      label: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}label'])!,
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['year'] = Variable<int>(year);
    map['label'] = Variable<String>(label);
    return map;
  }

  MilestonesCompanion toCompanion(bool nullToAbsent) {
    return MilestonesCompanion(
      id: Value(id),
      year: Value(year),
      label: Value(label),
    );
  }

  factory Milestone.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Milestone(
      id: serializer.fromJson<int>(json['id']),
      year: serializer.fromJson<int>(json['year']),
      label: serializer.fromJson<String>(json['label']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'year': serializer.toJson<int>(year),
      'label': serializer.toJson<String>(label),
    };
  }

  Milestone copyWith({int? id, int? year, String? label}) => Milestone(
        id: id ?? this.id,
        year: year ?? this.year,
        label: label ?? this.label,
      );
  @override
  String toString() {
    return (StringBuffer('Milestone(')
          ..write('id: $id, ')
          ..write('year: $year, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, year, label);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Milestone &&
          other.id == this.id &&
          other.year == this.year &&
          other.label == this.label);
}

class MilestonesCompanion extends UpdateCompanion<Milestone> {
  final Value<int> id;
  final Value<int> year;
  final Value<String> label;
  const MilestonesCompanion({
    this.id = const Value.absent(),
    this.year = const Value.absent(),
    this.label = const Value.absent(),
  });
  MilestonesCompanion.insert({
    this.id = const Value.absent(),
    required int year,
    required String label,
  })  : year = Value(year),
        label = Value(label);
  static Insertable<Milestone> custom({
    Expression<int>? id,
    Expression<int>? year,
    Expression<String>? label,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (year != null) 'year': year,
      if (label != null) 'label': label,
    });
  }

  MilestonesCompanion copyWith(
      {Value<int>? id, Value<int>? year, Value<String>? label}) {
    return MilestonesCompanion(
      id: id ?? this.id,
      year: year ?? this.year,
      label: label ?? this.label,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MilestonesCompanion(')
          ..write('id: $id, ')
          ..write('year: $year, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }
}

class $MilestonesTable extends Milestones
    with TableInfo<$MilestonesTable, Milestone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MilestonesTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int?> year = GeneratedColumn<int?>(
      'year', aliasedName, false,
      type: const IntType(), requiredDuringInsert: true);
  final VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String?> label = GeneratedColumn<String?>(
      'label', aliasedName, false,
      type: const StringType(), requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, year, label];
  @override
  String get aliasedName => _alias ?? 'milestones';
  @override
  String get actualTableName => 'milestones';
  @override
  VerificationContext validateIntegrity(Insertable<Milestone> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Milestone map(Map<String, dynamic> data, {String? tablePrefix}) {
    return Milestone.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $MilestonesTable createAlias(String alias) {
    return $MilestonesTable(attachedDatabase, alias);
  }
class UserSetting extends DataClass implements Insertable<UserSetting> {
  final int id;
  final String userName;
  final String currentChapterGoal;
  final bool isDarkMode;
  final String stagesJson;
  final bool isReminderEnabled;
  final String reminderTime;
  UserSetting(
      {required this.id,
      required this.userName,
      required this.currentChapterGoal,
      required this.isDarkMode,
      required this.stagesJson,
      this.isReminderEnabled = false,
      this.reminderTime = '20:00'});
  factory UserSetting.fromData(Map<String, dynamic> data, {String? prefix}) {
    final effectivePrefix = prefix ?? '';
    return UserSetting(
      id: const IntType()
          .mapFromDatabaseResponse(data['${effectivePrefix}id'])!,
      userName: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}user_name'])!,
      currentChapterGoal: const StringType().mapFromDatabaseResponse(
          data['${effectivePrefix}current_chapter_goal'])!,
      isDarkMode: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}is_dark_mode'])!,
      stagesJson: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}stages_json'])!,
      isReminderEnabled: const BoolType()
          .mapFromDatabaseResponse(data['${effectivePrefix}is_reminder_enabled']) ?? false,
      reminderTime: const StringType()
          .mapFromDatabaseResponse(data['${effectivePrefix}reminder_time']) ?? '20:00',
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_name'] = Variable<String>(userName);
    map['current_chapter_goal'] = Variable<String>(currentChapterGoal);
    map['is_dark_mode'] = Variable<bool>(isDarkMode);
    map['stages_json'] = Variable<String>(stagesJson);
    map['is_reminder_enabled'] = Variable<bool>(isReminderEnabled);
    map['reminder_time'] = Variable<String>(reminderTime);
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      id: Value(id),
      userName: Value(userName),
      currentChapterGoal: Value(currentChapterGoal),
      isDarkMode: Value(isDarkMode),
      stagesJson: Value(stagesJson),
      isReminderEnabled: Value(isReminderEnabled),
      reminderTime: Value(reminderTime),
    );
  }

  factory UserSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSetting(
      id: serializer.fromJson<int>(json['id']),
      userName: serializer.fromJson<String>(json['userName']),
      currentChapterGoal:
          serializer.fromJson<String>(json['currentChapterGoal']),
      isDarkMode: serializer.fromJson<bool>(json['isDarkMode']),
      stagesJson: serializer.fromJson<String>(json['stagesJson']),
      isReminderEnabled: serializer.fromJson<bool>(json['isReminderEnabled']),
      reminderTime: serializer.fromJson<String>(json['reminderTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userName': serializer.toJson<String>(userName),
      'currentChapterGoal': serializer.toJson<String>(currentChapterGoal),
      'isDarkMode': serializer.toJson<bool>(isDarkMode),
      'stagesJson': serializer.toJson<String>(stagesJson),
      'isReminderEnabled': serializer.toJson<bool>(isReminderEnabled),
      'reminderTime': serializer.toJson<String>(reminderTime),
    };
  }

  UserSetting copyWith(
          {int? id,
          String? userName,
          String? currentChapterGoal,
          bool? isDarkMode,
          String? stagesJson,
          bool? isReminderEnabled,
          String? reminderTime}) =>
      UserSetting(
        id: id ?? this.id,
        userName: userName ?? this.userName,
        currentChapterGoal: currentChapterGoal ?? this.currentChapterGoal,
        isDarkMode: isDarkMode ?? this.isDarkMode,
        stagesJson: stagesJson ?? this.stagesJson,
        isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
        reminderTime: reminderTime ?? this.reminderTime,
      );
  @override
  String toString() {
    return (StringBuffer('UserSetting(')
          ..write('id: $id, ')
          ..write('userName: $userName, ')
          ..write('currentChapterGoal: $currentChapterGoal, ')
          ..write('isDarkMode: $isDarkMode, ')
          ..write('stagesJson: $stagesJson, ')
          ..write('isReminderEnabled: $isReminderEnabled, ')
          ..write('reminderTime: $reminderTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userName, currentChapterGoal, isDarkMode, stagesJson, isReminderEnabled, reminderTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSetting &&
          other.id == this.id &&
          other.userName == this.userName &&
          other.currentChapterGoal == this.currentChapterGoal &&
          other.isDarkMode == this.isDarkMode &&
          other.stagesJson == this.stagesJson &&
          other.isReminderEnabled == this.isReminderEnabled &&
          other.reminderTime == this.reminderTime);
}

class UserSettingsCompanion extends UpdateCompanion<UserSetting> {
  final Value<int> id;
  final Value<String> userName;
  final Value<String> currentChapterGoal;
  final Value<bool> isDarkMode;
  final Value<String> stagesJson;
  final Value<bool> isReminderEnabled;
  final Value<String> reminderTime;
  const UserSettingsCompanion({
    this.id = const Value.absent(),
    this.userName = const Value.absent(),
    this.currentChapterGoal = const Value.absent(),
    this.isDarkMode = const Value.absent(),
    this.stagesJson = const Value.absent(),
    this.isReminderEnabled = const Value.absent(),
    this.reminderTime = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.userName = const Value.absent(),
    this.currentChapterGoal = const Value.absent(),
    this.isDarkMode = const Value.absent(),
    this.stagesJson = const Value.absent(),
    this.isReminderEnabled = const Value.absent(),
    this.reminderTime = const Value.absent(),
  });
  static Insertable<UserSetting> custom({
    Expression<int>? id,
    Expression<String>? userName,
    Expression<String>? currentChapterGoal,
    Expression<bool>? isDarkMode,
    Expression<String>? stagesJson,
    Expression<bool>? isReminderEnabled,
    Expression<String>? reminderTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userName != null) 'user_name': userName,
      if (currentChapterGoal != null)
        'current_chapter_goal': currentChapterGoal,
      if (isDarkMode != null) 'is_dark_mode': isDarkMode,
      if (stagesJson != null) 'stages_json': stagesJson,
      if (isReminderEnabled != null) 'is_reminder_enabled': isReminderEnabled,
      if (reminderTime != null) 'reminder_time': reminderTime,
    });
  }

  UserSettingsCompanion copyWith(
      {Value<int>? id,
      Value<String>? userName,
      Value<String>? currentChapterGoal,
      Value<bool>? isDarkMode,
      Value<String>? stagesJson}) {
    return UserSettingsCompanion(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      currentChapterGoal: currentChapterGoal ?? this.currentChapterGoal,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      stagesJson: stagesJson ?? this.stagesJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userName.present) {
      map['user_name'] = Variable<String>(userName.value);
    }
    if (currentChapterGoal.present) {
      map['current_chapter_goal'] = Variable<String>(currentChapterGoal.value);
    }
    if (isDarkMode.present) {
      map['is_dark_mode'] = Variable<bool>(isDarkMode.value);
    }
    if (stagesJson.present) {
      map['stages_json'] = Variable<String>(stagesJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('id: $id, ')
          ..write('userName: $userName, ')
          ..write('currentChapterGoal: $currentChapterGoal, ')
          ..write('isDarkMode: $isDarkMode, ')
          ..write('stagesJson: $stagesJson')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, UserSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int?> id = GeneratedColumn<int?>(
      'id', aliasedName, false,
      type: const IntType(),
      requiredDuringInsert: false,
      defaultConstraints: 'PRIMARY KEY AUTOINCREMENT');
  final VerificationMeta _userNameMeta = const VerificationMeta('userName');
  @override
  late final GeneratedColumn<String?> userName = GeneratedColumn<String?>(
      'user_name', aliasedName, false,
      type: const StringType(),
      requiredDuringInsert: false,
      defaultValue: const Constant('User'));
  final VerificationMeta _currentChapterGoalMeta =
      const VerificationMeta('currentChapterGoal');
  @override
  late final GeneratedColumn<String?> currentChapterGoal =
      GeneratedColumn<String?>('current_chapter_goal', aliasedName, false,
          type: const StringType(),
          requiredDuringInsert: false,
          defaultValue: const Constant(''));
  final VerificationMeta _isDarkModeMeta = const VerificationMeta('isDarkMode');
  @override
  late final GeneratedColumn<bool?> isDarkMode = GeneratedColumn<bool?>(
      'is_dark_mode', aliasedName, false,
      type: const BoolType(),
      requiredDuringInsert: false,
      defaultConstraints: 'CHECK (is_dark_mode IN (0, 1))',
      defaultValue: const Constant(true));
  final VerificationMeta _stagesJsonMeta = const VerificationMeta('stagesJson');
  @override
  late final GeneratedColumn<String?> stagesJson = GeneratedColumn<String?>(
      'stages_json', aliasedName, false,
      type: const StringType(),
      requiredDuringInsert: false,
      defaultValue: const Constant('Idea,Research,Prototype,Launch'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, userName, currentChapterGoal, isDarkMode, stagesJson];
  @override
  String get aliasedName => _alias ?? 'user_settings';
  @override
  String get actualTableName => 'user_settings';
  @override
  VerificationContext validateIntegrity(Insertable<UserSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_name')) {
      context.handle(_userNameMeta,
          userName.isAcceptableOrUnknown(data['user_name']!, _userNameMeta));
    }
    if (data.containsKey('current_chapter_goal')) {
      context.handle(
          _currentChapterGoalMeta,
          currentChapterGoal.isAcceptableOrUnknown(
              data['current_chapter_goal']!, _currentChapterGoalMeta));
    }
    if (data.containsKey('is_dark_mode')) {
      context.handle(
          _isDarkModeMeta,
          isDarkMode.isAcceptableOrUnknown(
              data['is_dark_mode']!, _isDarkModeMeta));
    }
    if (data.containsKey('stages_json')) {
      context.handle(
          _stagesJsonMeta,
          stagesJson.isAcceptableOrUnknown(
              data['stages_json']!, _stagesJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    return UserSetting.fromData(data,
        prefix: tablePrefix != null ? '$tablePrefix.' : null);
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $EntriesTable entries = $EntriesTable(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $SkillsTable skills = $SkillsTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $ReflectionsTable reflections = $ReflectionsTable(this);
  late final $MilestonesTable milestones = $MilestonesTable(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        categories,
        entries,
        projects,
        skills,
        goals,
        reflections,
        milestones,
        userSettings
      ];
}
