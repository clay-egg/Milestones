import 'dart:io';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get role => text()(); // copper (learning), gold (achievement), plum (goal), sage (neutral/success), rose (destructive)
}

class Entries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get project => text().nullable()();
  TextColumn get tags => text()(); // kept for legacy, not shown in UI
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
          // Safety check: ensure notes column exists in SQLite table if upgrading from legacy schema
          try {
            await customStatement('ALTER TABLE entries ADD COLUMN notes TEXT;');
          } catch (_) {
            // Already exists
          }
        },
      );

  // Helper CRUD actions
  
  // 1. Save Timeline Entry
  Future<void> saveQuickCapture({
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

    await into(entries).insert(EntriesCompanion.insert(
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
    required String currentChapterGoal,
    required bool isDarkMode,
    required String stagesJson,
  }) async {
    final settingsList = await select(userSettings).get();
    if (settingsList.isEmpty) {
      await into(userSettings).insert(UserSettingsCompanion.insert(
        userName: Value(userName),
        currentChapterGoal: Value(currentChapterGoal),
        isDarkMode: Value(isDarkMode),
        stagesJson: Value(stagesJson),
      ));
    } else {
      final id = settingsList.first.id;
      await (update(userSettings)..where((t) => t.id.equals(id))).write(
        UserSettingsCompanion(
          userName: Value(userName),
          currentChapterGoal: Value(currentChapterGoal),
          isDarkMode: Value(isDarkMode),
          stagesJson: Value(stagesJson),
        ),
      );
    }
  }

  // Categories CRUD
  Future<void> addCategory(String name, String role) async {
    await into(categories).insert(CategoriesCompanion.insert(name: name, role: role));
  }

  Future<void> renameCategory(int id, String newName) async {
    await (update(categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(name: Value(newName)),
    );
  }

  Future<void> updateCategory(int id, {required String name, required String role}) async {
    await (update(categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        name: Value(name),
        role: Value(role),
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
