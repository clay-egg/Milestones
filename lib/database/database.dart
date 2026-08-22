import 'dart:convert';
import 'package:drift/drift.dart';
import 'connection/connection.dart';

part 'database.g.dart';

class TodoItem {
  final int id;
  final String title;
  final bool isCompleted;
  final int categoryId;
  final DateTime dateCreated;
  final DateTime? dateCompleted;
  final int? linkedEntryId;

  TodoItem({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.categoryId,
    required this.dateCreated,
    this.dateCompleted,
    this.linkedEntryId,
  });
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get role => text()(); // copper (learning), gold (achievement), plum (goal), sage (neutral/success), rose (destructive)
  IntColumn get weeklyTarget => integer().nullable().withDefault(const Constant(0))(); // 0 = no target, >0 = entries per week
}

class Entries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get project => text().nullable()();
  TextColumn get tags => text().withDefault(const Constant(''))();
  TextColumn get notes => text().nullable()(); // optional user notes
}


class UserSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userName => text().withDefault(const Constant('User'))();
  TextColumn get currentChapterGoal => text().withDefault(const Constant(''))();
  BoolColumn get isDarkMode => boolean().withDefault(const Constant(true))();
  TextColumn get stagesJson => text().withDefault(const Constant('Idea,Research,Prototype,Launch'))();
  BoolColumn get isReminderEnabled => boolean().withDefault(const Constant(false))();
  TextColumn get reminderTime => text().withDefault(const Constant('20:00'))();
}


@DriftDatabase(tables: [
  Categories,
  Entries,
  UserSettings
])
class AppDatabase extends _$AppDatabase {
  // Lazy singleton — only created on first access, after file system is ready
  static AppDatabase? _instance;
  factory AppDatabase() => _instance ??= AppDatabase._internal();
  AppDatabase._internal() : super(openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Seed initial categories
          await into(categories).insert(CategoriesCompanion.insert(
            name: 'Coding',
            role: 'learning', // copper
          ));
          await into(categories).insert(CategoriesCompanion.insert(
            name: 'Language Study',
            role: 'learning', // copper
          ));
          await into(categories).insert(CategoriesCompanion.insert(
            name: 'Marathon Run',
            role: 'achievement', // gold
          ));
          await into(categories).insert(CategoriesCompanion.insert(
            name: 'Career Pivot',
            role: 'goal', // plum
          ));
          await into(categories).insert(CategoriesCompanion.insert(
            name: 'Daily Yoga',
            role: 'neutral', // sage
          ));
          // Seed default settings
          await into(userSettings).insert(UserSettingsCompanion.insert(
            userName: const Value('Explorer'),
            currentChapterGoal: const Value('Build amazing things offline.'),
            isDarkMode: const Value(true),
            stagesJson: const Value('Idea,Research,Prototype,Launch'),
          ));
          
          // Seed initial entries (Timeline / Focus / Achievements preview)
          final now = DateTime.now();
          final codCat = await (select(categories)..where((tbl) => tbl.name.equals('Coding'))).getSingle();
          final langCat = await (select(categories)..where((tbl) => tbl.name.equals('Language Study'))).getSingle();
          final marCat = await (select(categories)..where((tbl) => tbl.name.equals('Marathon Run'))).getSingle();
          final carCat = await (select(categories)..where((tbl) => tbl.name.equals('Career Pivot'))).getSingle();

          await into(entries).insert(EntriesCompanion.insert(
            date: now.subtract(const Duration(days: 3)),
            description: 'Completed basic Dart streams tutorial',
            categoryId: codCat.id,
            project: Value('Flutter App'),
            tags: 'Flutter,Dart',
          ));

          await into(entries).insert(EntriesCompanion.insert(
            date: now.subtract(const Duration(days: 2)),
            description: 'Memorized 50 new Spanish verbs',
            categoryId: langCat.id,
            project: Value('Spanish'),
            tags: 'Spanish,Language',
          ));

          await into(entries).insert(EntriesCompanion.insert(
            date: now.subtract(const Duration(days: 1)),
            description: 'Ran 10k in under 50 minutes',
            categoryId: marCat.id,
            project: Value('Running'),
            tags: 'Fitness,Running',
          ));

        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2: add notes column to entries
            await m.addColumn(entries, entries.notes);
          }
          if (from < 3) {
            // v3: drop legacy tables no longer in the schema
            await customStatement('DROP TABLE IF EXISTS projects;');
            await customStatement('DROP TABLE IF EXISTS skills;');
            await customStatement('DROP TABLE IF EXISTS goals;');
            await customStatement('DROP TABLE IF EXISTS reflections;');
            await customStatement('DROP TABLE IF EXISTS milestones;');
          }
        },
        beforeOpen: (details) async {
          // Safety check: ensure notes and weekly_target columns exist in SQLite table
          try {
            await customStatement('ALTER TABLE entries ADD COLUMN notes TEXT;');
          } catch (_) {
            // Already exists
          }
          try {
            await customStatement('ALTER TABLE categories ADD COLUMN weekly_target INTEGER DEFAULT 0;');
          } catch (_) {
            // Already exists
          }
          try {
            await customStatement('''
              CREATE TABLE IF NOT EXISTS todos (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                is_completed INTEGER NOT NULL DEFAULT 0,
                category_id INTEGER NOT NULL,
                date_created TEXT NOT NULL,
                date_completed TEXT,
                linked_entry_id INTEGER
              );
            ''');
          } catch (_) {
            // Already exists
          }
          try {
            await customStatement('ALTER TABLE todos ADD COLUMN linked_entry_id INTEGER;');
          } catch (_) {
            // Already exists
          }
          try {
            await customStatement('ALTER TABLE user_settings ADD COLUMN is_reminder_enabled INTEGER DEFAULT 0;');
          } catch (_) {
            // Already exists
          }
          try {
            await customStatement('ALTER TABLE user_settings ADD COLUMN reminder_time TEXT DEFAULT "20:00";');
          } catch (_) {
            // Already exists
          }
        },
      );

  // Todo CRUD & Auto-Log
  Future<List<TodoItem>> getTodos() async {
    final rows = await customSelect(
      'SELECT id, title, is_completed, category_id, date_created, date_completed, linked_entry_id FROM todos ORDER BY is_completed ASC, id DESC',
    ).get();

    return rows.map((r) {
      return TodoItem(
        id: r.read<int>('id'),
        title: r.read<String>('title'),
        isCompleted: r.read<int>('is_completed') == 1,
        categoryId: r.read<int>('category_id'),
        dateCreated: DateTime.tryParse(r.read<String>('date_created')) ?? DateTime.now(),
        dateCompleted: r.read<String?>('date_completed') != null
            ? DateTime.tryParse(r.read<String>('date_completed'))
            : null,
        linkedEntryId: r.read<int?>('linked_entry_id'),
      );
    }).toList();
  }

  Future<void> addTodo(String title, int categoryId, {DateTime? dateCreated}) async {
    final dateStr = (dateCreated ?? DateTime.now()).toIso8601String();
    await customStatement(
      'INSERT INTO todos (title, is_completed, category_id, date_created) VALUES (?, 0, ?, ?)',
      [title, categoryId, dateStr],
    );
  }

  Future<void> toggleTodo(TodoItem item) async {
    final newCompleted = !item.isCompleted;
    final now = DateTime.now();
    final nowStr = now.toIso8601String();

    if (newCompleted) {
      final entryId = await saveQuickCapture(
        description: item.title,
        categoryId: item.categoryId,
        date: item.dateCreated,
      );

      await customStatement(
        'UPDATE todos SET is_completed = 1, date_completed = ?, linked_entry_id = ? WHERE id = ?',
        [nowStr, entryId, item.id],
      );
    } else {
      if (item.linkedEntryId != null) {
        await (delete(entries)..where((e) => e.id.equals(item.linkedEntryId!))).go();
      }

      await customStatement(
        'UPDATE todos SET is_completed = 0, date_completed = NULL, linked_entry_id = NULL WHERE id = ?',
        [item.id],
      );
    }
  }

  Future<void> updateTodo(TodoItem item, {required String title, required int categoryId, required DateTime dateCreated}) async {
    final dateStr = dateCreated.toIso8601String();
    await customStatement(
      'UPDATE todos SET title = ?, category_id = ?, date_created = ? WHERE id = ?',
      [title, categoryId, dateStr, item.id],
    );

    if (item.linkedEntryId != null) {
      await updateEntry(
        item.linkedEntryId!,
        description: title,
        categoryId: categoryId,
        date: dateCreated,
      );
    }
  }

  Future<void> deleteTodo(TodoItem item) async {
    if (item.linkedEntryId != null) {
      await (delete(entries)..where((e) => e.id.equals(item.linkedEntryId!))).go();
    }
    await customStatement('DELETE FROM todos WHERE id = ?', [item.id]);
  }

  // Helper CRUD actions
  
  // 1. Save Timeline Entry
  Future<int> saveQuickCapture({
    required String description,
    required int categoryId,
    String? notes,
    DateTime? date,
  }) async {
    int validCatId = categoryId;
    final catExists = await (select(categories)..where((c) => c.id.equals(categoryId))).getSingleOrNull();
    if (catExists == null) {
      final available = await select(categories).get();
      if (available.isNotEmpty) {
        validCatId = available.first.id;
      } else {
        validCatId = await into(categories).insert(CategoriesCompanion.insert(
          name: 'General',
          role: 'copper',
        ));
      }
    }

    return await into(entries).insert(EntriesCompanion.insert(
      date: date ?? DateTime.now(),
      description: description,
      categoryId: validCatId,
      tags: '',
      notes: Value(notes?.trim().isNotEmpty == true ? notes!.trim() : null),
    ));
  }

  Future<void> updateEntry(
    int id, {
    required String description,
    required int categoryId,
    String? notes,
    required DateTime date,
  }) async {
    await (update(entries)..where((e) => e.id.equals(id))).write(
      EntriesCompanion(
        description: Value(description),
        categoryId: Value(categoryId),
        notes: Value(notes?.trim().isNotEmpty == true ? notes!.trim() : null),
        date: Value(date),
      ),
    );
  }

  Future<void> deleteEntry(int entryId) async {
    // Delete linked todo list item if one exists
    await customStatement('DELETE FROM todos WHERE linked_entry_id = ?', [entryId]);
    // Delete the entry from entries table
    await (delete(entries)..where((e) => e.id.equals(entryId))).go();
  }

  // 2. Settings CRUD
  Future<UserSetting?> getSettings() async {
    final list = await select(userSettings).get();
    return list.isEmpty ? null : list.first;
  }

  Future<void> updateSettings({
    required String userName,
    String? currentChapterGoal,
    required bool isDarkMode,
    required String stagesJson,
    bool? isReminderEnabled,
    String? reminderTime,
  }) async {
    final settingsList = await select(userSettings).get();
    if (settingsList.isEmpty) {
      await into(userSettings).insert(UserSettingsCompanion.insert(
        userName: Value(userName),
        currentChapterGoal: Value(currentChapterGoal ?? ''),
        isDarkMode: Value(isDarkMode),
        stagesJson: Value(stagesJson),
        isReminderEnabled: Value(isReminderEnabled ?? false),
        reminderTime: Value(reminderTime ?? '20:00'),
      ));
    } else {
      final id = settingsList.first.id;
      await (update(userSettings)..where((t) => t.id.equals(id))).write(
        UserSettingsCompanion(
          userName: Value(userName),
          currentChapterGoal: currentChapterGoal != null ? Value(currentChapterGoal) : const Value.absent(),
          isDarkMode: Value(isDarkMode),
          stagesJson: Value(stagesJson),
          isReminderEnabled: isReminderEnabled != null ? Value(isReminderEnabled) : const Value.absent(),
          reminderTime: reminderTime != null ? Value(reminderTime) : const Value.absent(),
        ),
      );
    }
  }

  // Categories CRUD
  Future<void> addCategory(String name, String role, {int weeklyTarget = 0}) async {
    await into(categories).insert(CategoriesCompanion.insert(
      name: name,
      role: role,
      weeklyTarget: Value(weeklyTarget),
    ));
  }

  Future<void> renameCategory(int id, String newName) async {
    await (update(categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(name: Value(newName)),
    );
  }

  Future<void> updateCategory(int id, {required String name, required String role, int? weeklyTarget}) async {
    await (update(categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        name: Value(name),
        role: Value(role),
        weeklyTarget: weeklyTarget != null ? Value(weeklyTarget) : const Value.absent(),
      ),
    );
  }

  Future<void> deleteCategory(int id) async {
    await (delete(categories)..where((c) => c.id.equals(id))).go();
  }

}

