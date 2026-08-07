import 'dart:convert';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/state_providers.dart';
import '../widgets/common_widgets.dart';
import '../database/database.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  bool _profileInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveProfile(AppDatabase db, UserSetting settings) {
    db.updateSettings(
      userName: _nameController.text.trim(),
      isDarkMode: settings.isDarkMode,
      stagesJson: settings.stagesJson,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final settingsAsync = ref.watch(settingsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final db = ref.watch(databaseProvider);

    settingsAsync.whenData((settings) {
      if (!_profileInitialized) {
        _nameController.text = settings.userName;
        _profileInitialized = true;
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              Text('Settings', style: AppFonts.heading(context, size: 18)),
              const SizedBox(height: 16),

              settingsAsync.when(
                data: (settings) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Appearance Section
                      _buildThemeSection(context, db, settings),
                      const SizedBox(height: 16),

                      // 2. Profile & Motto Section
                      _buildProfileSection(context, db, settings),
                      const SizedBox(height: 16),

                      // 3. Category Management Section
                      _buildCategoriesSection(context, db, categoriesAsync),
                      const SizedBox(height: 16),

                      // 4. Data Backup & Restore Section
                      _buildDataBackupSection(context, db, settings),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                error: (err, stack) => Center(
                  child: Text('Error loading settings', style: AppFonts.ui(context, color: theme.textMuted)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- THEME TOGGLE SECTION ---
  Widget _buildThemeSection(BuildContext context, AppDatabase db, UserSetting settings) {
    final theme = ThemeProvider.of(context);
    final sageColor = AppColors.getRoleColor('sage', theme.isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.border, width: 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Theme Mode', style: AppFonts.ui(context, size: 14, weight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(
                settings.isDarkMode ? 'Dark' : 'Light',
                style: AppFonts.mono(context, size: 11, color: theme.textMuted),
              ),
            ],
          ),
          Switch(
            value: settings.isDarkMode,
            activeColor: sageColor,
            onChanged: (val) {
              db.updateSettings(
                userName: settings.userName,
                isDarkMode: val,
                stagesJson: settings.stagesJson,
              );
            },
          ),
        ],
      ),
    );
  }

  // --- PROFILE SECTION ---
  Widget _buildProfileSection(BuildContext context, AppDatabase db, UserSetting settings) {
    final theme = ThemeProvider.of(context);
    final sageColor = AppColors.getRoleColor('sage', theme.isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile', style: AppFonts.ui(context, size: 14, weight: FontWeight.bold)),
          const SizedBox(height: 12),
          Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) {
                _saveProfile(db, settings);
              }
            },
            child: TextField(
              controller: _nameController,
              style: AppFonts.ui(context, size: 13.5),
              decoration: InputDecoration(
                labelText: 'User Name',
                labelStyle: AppFonts.ui(context, size: 12, color: theme.textMuted),
                filled: true,
                fillColor: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.border, width: 0.8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.border, width: 0.8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: sageColor, width: 1.2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CATEGORIES MANAGER SECTION ---
  Widget _buildCategoriesSection(
    BuildContext context,
    AppDatabase db,
    AsyncValue<List<Categorie>> categoriesAsync,
  ) {
    final theme = ThemeProvider.of(context);
    final sageColor = AppColors.getRoleColor('sage', theme.isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Categories', style: AppFonts.ui(context, size: 14, weight: FontWeight.bold)),
              GestureDetector(
                onTap: () => _showAddCategoryDialog(context, db),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: sageColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: sageColor.withValues(alpha: 0.35), width: 0.8),
                  ),
                  child: Text(
                    '+ Category',
                    style: AppFonts.mono(context, size: 10.5, color: sageColor, weight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          categoriesAsync.when(
            data: (categories) {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.border, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        RoleBadge(text: cat.name, role: cat.role, isSmall: true),
                        const Spacer(),
                        InkWell(
                          onTap: () => _showRenameCategoryDialog(context, db, cat),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(Icons.edit_outlined, size: 15, color: theme.textMuted),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: categories.length > 1
                              ? () => db.deleteCategory(cat.id)
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Must keep at least 1 category.')),
                                  );
                                },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.delete_outline,
                              size: 15,
                              color: AppColors.getRoleColor('destructive', theme.isDark),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const SizedBox(
              height: 40,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (err, stack) => Text('Error: $err', style: AppFonts.ui(context, size: 12, color: theme.textMuted)),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, AppDatabase db) {
    final nameController = TextEditingController();
    String selectedRole = 'learning';

    showDialog(
      context: context,
      builder: (context) {
        final theme = ThemeProvider.of(context);
        final sageColor = AppColors.getRoleColor('sage', theme.isDark);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: theme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text('Add Category', style: AppFonts.heading(context, size: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    style: AppFonts.ui(context, size: 13.5),
                    decoration: InputDecoration(
                      hintText: 'Category Name',
                      hintStyle: AppFonts.ui(context, size: 12.5, color: theme.textMuted),
                      filled: true,
                      fillColor: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.border, width: 0.8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.border, width: 0.8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: sageColor, width: 1.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'ROLE COLOR',
                    style: AppFonts.mono(context, size: 9, color: theme.textMuted, weight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    dropdownColor: theme.surface,
                    style: AppFonts.ui(context, size: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.border, width: 0.8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'learning', child: Text('Learning (Copper)')),
                      DropdownMenuItem(value: 'achievement', child: Text('Achievement (Gold)')),
                      DropdownMenuItem(value: 'goal', child: Text('Goal (Plum)')),
                      DropdownMenuItem(value: 'neutral', child: Text('Neutral (Sage)')),
                      DropdownMenuItem(value: 'destructive', child: Text('Destructive (Rose)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedRole = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: AppFonts.ui(context, color: theme.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sageColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      await db.addCategory(name, selectedRole);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: Text('Add', style: AppFonts.ui(context, color: Colors.black, weight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- DATA BACKUP & RESTORE SECTION ---
  Widget _buildDataBackupSection(BuildContext context, AppDatabase db, UserSetting settings) {
    final theme = ThemeProvider.of(context);
    final copperColor = AppColors.getRoleColor('copper', theme.isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Data Backup & Restore', style: AppFonts.ui(context, size: 14, weight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            'Export your timeline entries, habit logs, and categories as JSON backup.',
            style: AppFonts.ui(context, size: 11.5, color: theme.textMuted),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.border, width: 0.8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    'Export Backup',
                    style: AppFonts.mono(context, size: 11, color: theme.text, weight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    final entries = await db.select(db.entries).get();
                    final todos = await db.getTodos();
                    final categories = await db.select(db.categories).get();
                    final projects = await db.select(db.projects).get();
                    final skills = await db.select(db.skills).get();
                    final goals = await db.select(db.goals).get();
                    final reflections = await db.select(db.reflections).get();
                    final milestones = await db.select(db.milestones).get();

                    final Map<int, Categorie> categoryMap = {for (var c in categories) c.id: c};

                    final backupData = {
                      'appName': 'Milestones',
                      'version': '1.0',
                      'exportedAt': DateTime.now().toIso8601String(),
                      'userName': settings.userName,
                      'categories': categories.map((c) => {
                        'id': c.id,
                        'name': c.name,
                        'role': c.role,
                        'weeklyTarget': c.weeklyTarget,
                      }).toList(),
                      'entries': entries.map((e) => {
                        'description': e.description,
                        'categoryId': e.categoryId,
                        'categoryName': categoryMap[e.categoryId]?.name ?? '',
                        'notes': e.notes,
                        'date': e.date.toIso8601String(),
                      }).toList(),
                      'todos': todos.map((t) => {
                        'title': t.title,
                        'isCompleted': t.isCompleted,
                        'categoryId': t.categoryId,
                        'categoryName': categoryMap[t.categoryId]?.name ?? '',
                        'dateCreated': t.dateCreated.toIso8601String(),
                        'dateCompleted': t.dateCompleted?.toIso8601String(),
                      }).toList(),
                      'projects': projects.map((p) => {
                        'name': p.name,
                        'stepsJson': p.stepsJson,
                        'achievementsJson': p.achievementsJson,
                      }).toList(),
                      'skills': skills.map((s) => {
                        'name': s.name,
                        'progressPercent': s.progressPercent,
                        'evidenceJson': s.evidenceJson,
                      }).toList(),
                      'goals': goals.map((g) => {
                        'name': g.name,
                        'currentStage': g.currentStage,
                        'targetStage': g.targetStage,
                      }).toList(),
                      'reflections': reflections.map((r) => {
                        'monthYear': r.monthYear,
                        'achieved': r.achieved,
                        'challenges': r.challenges,
                        'nextMonth': r.nextMonth,
                      }).toList(),
                      'milestones': milestones.map((m) => {
                        'year': m.year,
                        'label': m.label,
                      }).toList(),
                    };

                    final jsonStr = const JsonEncoder.withIndent('  ').convert(backupData);
                    Clipboard.setData(ClipboardData(text: jsonStr));

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Full backup JSON copied to clipboard!', style: AppFonts.ui(context, color: Colors.white)),
                          backgroundColor: AppColors.getRoleColor('sage', theme.isDark),
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.border, width: 0.8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    'Import / Restore',
                    style: AppFonts.mono(context, size: 11, color: theme.text, weight: FontWeight.bold),
                  ),
                  onPressed: () => _showImportDialog(context, db),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.redAccent.withOpacity(0.5), width: 0.8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(
                'Clear All Data',
                style: AppFonts.mono(context, size: 11, color: Colors.redAccent, weight: FontWeight.bold),
              ),
              onPressed: () => _showClearDataDialog(context, db),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, AppDatabase db) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = ThemeProvider.of(context);
        return AlertDialog(
          backgroundColor: theme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Clear All Data', style: AppFonts.heading(context, size: 16, color: Colors.redAccent)),
          content: Text(
            'Are you sure you want to delete all timeline entries, tasks, projects, and focus data? This action cannot be undone.',
            style: AppFonts.ui(context, size: 12.5, color: theme.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppFonts.ui(context, color: theme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () async {
                await (db.delete(db.entries)).go();
                await db.customStatement('DELETE FROM todos;');
                await (db.delete(db.projects)).go();
                await (db.delete(db.skills)).go();
                await (db.delete(db.goals)).go();
                await (db.delete(db.reflections)).go();
                await (db.delete(db.milestones)).go();
                await (db.delete(db.categories)).go();

                // Seed initial default category
                await db.into(db.categories).insert(CategoriesCompanion.insert(
                  name: 'General',
                  role: 'learning',
                ));

                ref.refresh(categoriesProvider);
                ref.refresh(timelineEntriesProvider);
                ref.refresh(todosProvider);
                ref.refresh(projectsProvider);
                ref.refresh(skillsProvider);
                ref.refresh(goalsProvider);
                ref.refresh(reflectionsProvider);
                ref.refresh(milestonesProvider);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('All data cleared successfully.', style: AppFonts.ui(context, color: Colors.white)),
                      backgroundColor: Colors.redAccent,
                      duration: const Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Text('Delete All', style: AppFonts.ui(context, color: Colors.white, weight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showImportDialog(BuildContext context, AppDatabase db) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final theme = ThemeProvider.of(context);
        final sageColor = AppColors.getRoleColor('sage', theme.isDark);

        return AlertDialog(
          backgroundColor: theme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Import / Restore Backup', style: AppFonts.heading(context, size: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paste your JSON backup text below to restore your timeline logs and tasks:',
                style: AppFonts.ui(context, size: 12, color: theme.textMuted),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                maxLines: 6,
                style: AppFonts.mono(context, size: 11),
                decoration: InputDecoration(
                  hintText: 'Paste backup JSON here...',
                  hintStyle: AppFonts.mono(context, size: 11, color: theme.textMuted),
                  filled: true,
                  fillColor: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.border, width: 0.8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppFonts.ui(context, color: theme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: sageColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () async {
                final rawText = controller.text.trim();
                if (rawText.isEmpty) return;

                try {
                  final data = jsonDecode(rawText) as Map<String, dynamic>;

                  final Map<int, int> oldToNewCatIdMap = {};
                  final Map<String, int> catNameToIdMap = {};

                  // 1. Restore Categories & build ID map
                  if (data.containsKey('categories')) {
                    final categoriesList = data['categories'] as List<dynamic>;
                    for (final item in categoriesList) {
                      final map = item as Map<String, dynamic>;
                      final oldId = (map['id'] as num?)?.toInt();
                      final name = map['name'] as String? ?? '';
                      final role = map['role'] as String? ?? 'learning';
                      final weeklyTarget = (map['weeklyTarget'] as num?)?.toInt() ?? 0;
                      if (name.isNotEmpty) {
                        final existing = await (db.select(db.categories)..where((c) => c.name.equals(name))).getSingleOrNull();
                        int newId;
                        if (existing != null) {
                          newId = existing.id;
                          await (db.update(db.categories)..where((c) => c.id.equals(newId))).write(
                            CategoriesCompanion(
                              role: Value(role),
                              weeklyTarget: Value(weeklyTarget),
                            ),
                          );
                        } else {
                          newId = await db.into(db.categories).insert(CategoriesCompanion.insert(
                            name: name,
                            role: role,
                            weeklyTarget: Value(weeklyTarget),
                          ));
                        }
                        if (oldId != null) oldToNewCatIdMap[oldId] = newId;
                        catNameToIdMap[name] = newId;
                      }
                    }
                  }

                  // Fetch current category mapping fallback
                  final allCurrentCats = await db.select(db.categories).get();
                  for (final c in allCurrentCats) {
                    catNameToIdMap.putIfAbsent(c.name, () => c.id);
                  }
                  final defaultCatId = allCurrentCats.isNotEmpty ? allCurrentCats.first.id : 1;

                  int resolveCatId(int oldCatId, String catName) {
                    if (oldToNewCatIdMap.containsKey(oldCatId)) {
                      return oldToNewCatIdMap[oldCatId]!;
                    }
                    if (catNameToIdMap.containsKey(catName)) {
                      return catNameToIdMap[catName]!;
                    }
                    return defaultCatId;
                  }

                  // 2. Restore Entries with mapped Category ID
                  if (data.containsKey('entries')) {
                    final entriesList = data['entries'] as List<dynamic>;
                    for (final item in entriesList) {
                      final map = item as Map<String, dynamic>;
                      final desc = map['description'] as String? ?? '';
                      final oldCatId = (map['categoryId'] as num?)?.toInt() ?? 1;
                      final catName = map['categoryName'] as String? ?? '';
                      final notes = map['notes'] as String?;
                      final date = DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now();

                      final targetCatId = resolveCatId(oldCatId, catName);
                      await db.saveQuickCapture(
                        description: desc,
                        categoryId: targetCatId,
                        notes: notes,
                        date: date,
                      );
                    }
                  }

                  // 3. Restore Todos with mapped Category ID
                  if (data.containsKey('todos')) {
                    final todosList = data['todos'] as List<dynamic>;
                    for (final item in todosList) {
                      final map = item as Map<String, dynamic>;
                      final title = map['title'] as String? ?? '';
                      final oldCatId = (map['categoryId'] as num?)?.toInt() ?? 1;
                      final catName = map['categoryName'] as String? ?? '';
                      final dateCreated = DateTime.tryParse(map['dateCreated'] as String? ?? '') ?? DateTime.now();

                      final targetCatId = resolveCatId(oldCatId, catName);
                      await db.addTodo(title, targetCatId, dateCreated: dateCreated);
                    }
                  }

                  // 4. Restore Projects
                  if (data.containsKey('projects')) {
                    final projectsList = data['projects'] as List<dynamic>;
                    for (final item in projectsList) {
                      final map = item as Map<String, dynamic>;
                      final name = map['name'] as String? ?? '';
                      final stepsJson = map['stepsJson'] as String? ?? '[]';
                      final achievementsJson = map['achievementsJson'] as String? ?? '[]';
                      if (name.isNotEmpty) {
                        await db.into(db.projects).insert(ProjectsCompanion.insert(
                          name: name,
                          stepsJson: stepsJson,
                          achievementsJson: achievementsJson,
                        ));
                      }
                    }
                  }

                  // 5. Restore Skills
                  if (data.containsKey('skills')) {
                    final skillsList = data['skills'] as List<dynamic>;
                    for (final item in skillsList) {
                      final map = item as Map<String, dynamic>;
                      final name = map['name'] as String? ?? '';
                      final progressPercent = (map['progressPercent'] as num?)?.toDouble() ?? 0.0;
                      final evidenceJson = map['evidenceJson'] as String? ?? '[]';
                      if (name.isNotEmpty) {
                        await db.into(db.skills).insert(SkillsCompanion.insert(
                          name: name,
                          progressPercent: progressPercent,
                          evidenceJson: evidenceJson,
                        ));
                      }
                    }
                  }

                  // 6. Restore Goals
                  if (data.containsKey('goals')) {
                    final goalsList = data['goals'] as List<dynamic>;
                    for (final item in goalsList) {
                      final map = item as Map<String, dynamic>;
                      final name = map['name'] as String? ?? '';
                      final currentStage = map['currentStage'] as String? ?? 'Idea';
                      final targetStage = map['targetStage'] as String? ?? 'Launch';
                      if (name.isNotEmpty) {
                        await db.into(db.goals).insert(GoalsCompanion.insert(
                          name: name,
                          currentStage: currentStage,
                          targetStage: targetStage,
                        ));
                      }
                    }
                  }

                  // 7. Restore Reflections
                  if (data.containsKey('reflections')) {
                    final reflectionsList = data['reflections'] as List<dynamic>;
                    for (final item in reflectionsList) {
                      final map = item as Map<String, dynamic>;
                      final monthYear = map['monthYear'] as String? ?? '';
                      final achieved = map['achieved'] as String? ?? '';
                      final challenges = map['challenges'] as String? ?? '';
                      final nextMonth = map['nextMonth'] as String? ?? '';
                      if (monthYear.isNotEmpty) {
                        await db.into(db.reflections).insert(ReflectionsCompanion.insert(
                          monthYear: monthYear,
                          achieved: achieved,
                          challenges: challenges,
                          nextMonth: nextMonth,
                        ));
                      }
                    }
                  }

                  // 8. Restore Milestones
                  if (data.containsKey('milestones')) {
                    final milestonesList = data['milestones'] as List<dynamic>;
                    for (final item in milestonesList) {
                      final map = item as Map<String, dynamic>;
                      final year = (map['year'] as num?)?.toInt() ?? DateTime.now().year;
                      final label = map['label'] as String? ?? '';
                      if (label.isNotEmpty) {
                        await db.into(db.milestones).insert(MilestonesCompanion.insert(
                          year: year,
                          label: label,
                        ));
                      }
                    }
                  }

                  ref.refresh(categoriesProvider);
                  ref.refresh(timelineEntriesProvider);
                  ref.refresh(todosProvider);
                  ref.refresh(projectsProvider);
                  ref.refresh(skillsProvider);
                  ref.refresh(goalsProvider);
                  ref.refresh(reflectionsProvider);
                  ref.refresh(milestonesProvider);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Backup data successfully restored!', style: AppFonts.ui(context, color: Colors.white)),
                        backgroundColor: sageColor,
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Invalid JSON backup format.', style: AppFonts.ui(context, color: Colors.white)),
                        backgroundColor: Colors.redAccent,
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: Text('Restore', style: AppFonts.ui(context, color: Colors.black, weight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showRenameCategoryDialog(BuildContext context, AppDatabase db, Categorie cat) {
    final controller = TextEditingController(text: cat.name);
    showDialog(
      context: context,
      builder: (context) {
        final theme = ThemeProvider.of(context);
        final sageColor = AppColors.getRoleColor('sage', theme.isDark);

        return AlertDialog(
          backgroundColor: theme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Rename Category', style: AppFonts.heading(context, size: 16)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: AppFonts.ui(context, size: 13.5),
            decoration: InputDecoration(
              hintText: 'New Name',
              hintStyle: AppFonts.ui(context, size: 12.5, color: theme.textMuted),
              filled: true,
              fillColor: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.border, width: 0.8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppFonts.ui(context, color: theme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: sageColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  await db.renameCategory(cat.id, newName);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: Text('Save', style: AppFonts.ui(context, color: Colors.black, weight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
