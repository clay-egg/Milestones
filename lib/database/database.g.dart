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
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        categories,
        entries,
        userSettings
      ];
}
