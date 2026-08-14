import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// Navigation Index Provider
final navigationIndexProvider = StateProvider<int>((ref) => 0);

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



// Todos Provider
final todosProvider = FutureProvider<List<TodoItem>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getTodos();
});

