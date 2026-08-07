import 'dart:io';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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

class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get stepsJson => text()(); // JSON list of steps (step: String, completed: bool)
  TextColumn get achievementsJson => text()(); // JSON list of achievement titles (title: String, completed: bool)
}

class Skills extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get progressPercent => real()();
  TextColumn get evidenceJson => text()(); // JSON list of evidence strings
}

class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get currentStage => text()();
  TextColumn get targetStage => text()();
}

class Reflections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get monthYear => text()(); // e.g. "2026-08"
  TextColumn get achieved => text()();
  TextColumn get challenges => text()();
  TextColumn get nextMonth => text()();
}

class Milestones extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get year => integer()();
  TextColumn get label => text()();
}

class Summaries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get year => integer()();
  TextColumn get content => text()();
  DateTimeColumn get dateCreated => dateTime()();
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

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbDir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbDir.path, 'milestone.sqlite'));
    return NativeDatabase(file);
  });
}

@DriftDatabase(tables: [
  Categories,
  Entries,
  Projects,
  Skills,
  Goals,
  Reflections,
  Milestones,
  Summaries,
  UserSettings
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

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

          // Seed Focus items (Projects, Skills, Goals)
          await into(projects).insert(ProjectsCompanion.insert(
            name: 'Flutter App',
            stepsJson: jsonEncode([
              {'title': 'Completed basic Dart streams tutorial', 'completed': true},
              {'title': 'Implement Drift offline database', 'completed': false},
            ]),
            achievementsJson: jsonEncode([
              {'title': 'Database connected', 'completed': false},
            ]),
          ));

          await into(projects).insert(ProjectsCompanion.insert(
            name: 'Spanish',
            stepsJson: jsonEncode([
              {'title': 'Memorized 50 new Spanish verbs', 'completed': true},
              {'title': 'Finish Duolingo checkpoint 3', 'completed': false},
            ]),
            achievementsJson: jsonEncode([]),
          ));

          await into(skills).insert(SkillsCompanion.insert(
            name: 'Flutter',
            progressPercent: 40.0,
            evidenceJson: jsonEncode([
              'Completed basic Dart streams tutorial',
            ]),
          ));

          await into(skills).insert(SkillsCompanion.insert(
            name: 'Spanish',
            progressPercent: 20.0,
            evidenceJson: jsonEncode([
              'Memorized 50 new Spanish verbs',
            ]),
          ));

          await into(goals).insert(GoalsCompanion.insert(
            name: 'Run Half Marathon',
            currentStage: 'Research',
            targetStage: 'Launch',
          ));

          await into(reflections).insert(ReflectionsCompanion.insert(
            monthYear: '2026-08',
            achieved: 'Learned Dart and Drift SQLite basics.',
            challenges: 'Finding quiet time for language study.',
            nextMonth: 'Build UI screens for the milestone app.',
          ));

          await into(milestones).insert(MilestonesCompanion.insert(
            year: 2026,
            label: 'Deploy first personal app to macOS App Store',
          ));
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2: add notes column to entries
            await m.addColumn(entries, entries.notes);
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

  // 2. Settings CRUD
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

  // Projects U
  Future<void> updateProjectSteps(int id, List steps) async {
    await (update(projects)..where((p) => p.id.equals(id))).write(
      ProjectsCompanion(stepsJson: Value(jsonEncode(steps))),
    );
  }

  Future<void> updateProjectAchievements(int id, List achievements) async {
    await (update(projects)..where((p) => p.id.equals(id))).write(
      ProjectsCompanion(achievementsJson: Value(jsonEncode(achievements))),
    );
  }

  Future<void> createProject(String name) async {
    await into(projects).insert(ProjectsCompanion.insert(
      name: name,
      stepsJson: '[]',
      achievementsJson: '[]',
    ));
  }

  // Skills U
  Future<void> updateSkillProgress(int id, double newProgress) async {
    await (update(skills)..where((s) => s.id.equals(id))).write(
      SkillsCompanion(progressPercent: Value(newProgress)),
    );
  }

  Future<void> addSkillEvidence(int id, String evidenceText) async {
    final skill = await (select(skills)..where((s) => s.id.equals(id))).getSingle();
    final List evidence = jsonDecode(skill.evidenceJson);
    evidence.add(evidenceText);
    await (update(skills)..where((s) => s.id.equals(id))).write(
      SkillsCompanion(evidenceJson: Value(jsonEncode(evidence))),
    );
  }

  Future<void> createSkill(String name) async {
    await into(skills).insert(SkillsCompanion.insert(
      name: name,
      progressPercent: 10.0,
      evidenceJson: '[]',
    ));
  }

  // Goals CRUD
  Future<void> createGoal(String name, String currentStage, String targetStage) async {
    await into(goals).insert(GoalsCompanion.insert(
      name: name,
      currentStage: currentStage,
      targetStage: targetStage,
    ));
  }

  Future<void> updateGoalStage(int id, String newStage) async {
    await (update(goals)..where((g) => g.id.equals(id))).write(
      GoalsCompanion(currentStage: Value(newStage)),
    );
  }

  Future<void> deleteGoal(int id) async {
    await (delete(goals)..where((g) => g.id.equals(id))).go();
  }

  // Reflections CRUD
  Future<void> updateReflection(String monthYear, {String? achieved, String? challenges, String? nextMonth}) async {
    final existing = await (select(reflections)..where((r) => r.monthYear.equals(monthYear))).getSingleOrNull();
    if (existing != null) {
      await (update(reflections)..where((r) => r.id.equals(existing.id))).write(
        ReflectionsCompanion(
          achieved: achieved != null ? Value(achieved) : const Value.absent(),
          challenges: challenges != null ? Value(challenges) : const Value.absent(),
          nextMonth: nextMonth != null ? Value(nextMonth) : const Value.absent(),
        ),
      );
    } else {
      await into(reflections).insert(ReflectionsCompanion.insert(
        monthYear: monthYear,
        achieved: achieved ?? '',
        challenges: challenges ?? '',
        nextMonth: nextMonth ?? '',
      ));
    }
  }

  // Milestones CRUD
  Future<void> createMilestone(int year, String label) async {
    await into(milestones).insert(MilestonesCompanion.insert(year: year, label: label));
  }

  Future<void> deleteMilestone(int id) async {
    await (delete(milestones)..where((m) => m.id.equals(id))).go();
  }

  // Summaries CRUD
  Future<void> createSummary(int year, String content) async {
    await into(summaries).insert(SummariesCompanion.insert(
      year: year,
      content: content,
      dateCreated: DateTime.now(),
    ));
  }
}
