import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// Settings Provider
final settingsProvider = StreamProvider<UserSetting>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.userSettings).watchSingle();
});

// Categories Provider
final categoriesProvider = StreamProvider<List<Categorie>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.categories).watch();
});

// Joined Entrie and Categorie model for UI
class EntryWithCategory {
  final Entrie entry;
  final Categorie category;
  EntryWithCategory(this.entry, this.category);
}

// Timeline Entries Provider
final timelineEntriesProvider = StreamProvider<List<EntryWithCategory>>((ref) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.entries).join([
    innerJoin(db.categories, db.categories.id.equalsExp(db.entries.categoryId)),
  ]);
  query.orderBy([OrderingTerm.desc(db.entries.date)]);
  
  return query.watch().map((rows) {
    return rows.map((row) {
      final entry = row.readTable(db.entries);
      final category = row.readTable(db.categories);
      return EntryWithCategory(entry, category);
    }).toList();
  });
});

// Projects Provider
final projectsProvider = StreamProvider<List<Project>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.projects).watch();
});

// Skills Provider
final skillsProvider = StreamProvider<List<Skill>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.skills).watch();
});

// Goals Provider
final goalsProvider = StreamProvider<List<Goal>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.goals).watch();
});

// Reflections Provider
final reflectionsProvider = StreamProvider<List<Reflection>>((ref) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.reflections);
  query.orderBy([(t) => OrderingTerm.desc(t.monthYear)]);
  return query.watch();
});

// Milestones Provider
final milestonesProvider = StreamProvider<List<Milestone>>((ref) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.milestones);
  query.orderBy([(t) => OrderingTerm.asc(t.year)]);
  return query.watch();
});

// Summaries Provider
final summariesProvider = StreamProvider<List<Summarie>>((ref) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.summaries);
  query.orderBy([(t) => OrderingTerm.desc(t.dateCreated)]);
  return query.watch();
});
