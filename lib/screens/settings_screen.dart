import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final _chapterController = TextEditingController();
  bool _profileInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _chapterController.dispose();
    super.dispose();
  }

  void _saveProfile(AppDatabase db, UserSetting settings) {
    db.updateSettings(
      userName: _nameController.text.trim(),
      currentChapterGoal: _chapterController.text.trim(),
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
        _chapterController.text = settings.currentChapterGoal;
        _profileInitialized = true;
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              settingsAsync.when(
                data: (settings) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 880;
                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  _buildProfileSection(context, db, settings),
                                  const SizedBox(height: 24),
                                  _buildThemeSection(context, db, settings),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                children: [
                                  _buildCategoriesSection(context, db, categoriesAsync),
                                  const SizedBox(height: 24),
                                  _buildStagesSection(context, db, settings),
                                ],
                              ),
                            )
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildProfileSection(context, db, settings),
                            const SizedBox(height: 24),
                            _buildThemeSection(context, db, settings),
                            const SizedBox(height: 24),
                            _buildCategoriesSection(context, db, categoriesAsync),
                            const SizedBox(height: 24),
                            _buildStagesSection(context, db, settings),
                          ],
                        );
                      }
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- PROFILE SECTION ---
  Widget _buildProfileSection(BuildContext context, AppDatabase db, UserSetting settings) {
    final theme = ThemeProvider.of(context);
    return MilestoneCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile Settings', style: AppFonts.ui(context, size: 16, weight: FontWeight.bold)),
          const SizedBox(height: 16),
          Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) {
                _saveProfile(db, settings);
              }
            },
            child: TextField(
              controller: _nameController,
              style: AppFonts.ui(context),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: AppFonts.ui(context, color: theme.textMuted),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.border)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.getRoleColor('sage', theme.isDark))),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) {
                _saveProfile(db, settings);
              }
            },
            child: TextField(
              controller: _chapterController,
              style: AppFonts.ui(context),
              decoration: InputDecoration(
                labelText: 'Current Chapter Goal',
                labelStyle: AppFonts.ui(context, color: theme.textMuted),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.border)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.getRoleColor('plum', theme.isDark))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- THEME TOGGLE SECTION ---
  Widget _buildThemeSection(BuildContext context, AppDatabase db, UserSetting settings) {
    final theme = ThemeProvider.of(context);
    return MilestoneCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Theme Mode', style: AppFonts.ui(context, size: 16, weight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                settings.isDarkMode ? 'Dark Theme (Default)' : 'Light Theme',
                style: AppFonts.ui(context, size: 12, color: theme.textMuted),
              ),
            ],
          ),
          Switch(
            value: settings.isDarkMode,
            activeColor: AppColors.getRoleColor('sage', theme.isDark),
            inactiveThumbColor: AppColors.getRoleColor('copper', theme.isDark),
            onChanged: (val) {
              db.updateSettings(
                userName: settings.userName,
                currentChapterGoal: settings.currentChapterGoal,
                isDarkMode: val,
                stagesJson: settings.stagesJson,
              );
            },
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
    return MilestoneCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Manage Categories', style: AppFonts.ui(context, size: 16, weight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: AppColors.getRoleColor('sage', theme.isDark)),
                onPressed: () => _showAddCategoryDialog(context, db),
              ),
            ],
          ),
          const SizedBox(height: 12),
          categoriesAsync.when(
            data: (categories) {
              return Column(
                children: categories.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        RoleBadge(text: cat.name, role: cat.role, isSmall: true),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 16),
                          onPressed: () => _showRenameCategoryDialog(context, db, cat),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: 16, color: AppColors.getRoleColor('destructive', theme.isDark)),
                          onPressed: categories.length > 1
                              ? () => db.deleteCategory(cat.id)
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Must have at least 1 category.')),
                                  );
                                },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (err, stack) => Text('Error: $err'),
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
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: theme.surface,
              title: Text('Add Category', style: AppFonts.heading(context, size: 18)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    style: AppFonts.ui(context),
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      labelStyle: AppFonts.ui(context, color: theme.textMuted),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Role Color Mapping:', style: AppFonts.ui(context, size: 12, color: theme.textMuted)),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: selectedRole,
                    dropdownColor: theme.surface,
                    style: AppFonts.ui(context),
                    underline: Container(height: 1, color: theme.border),
                    items: const [
                      DropdownMenuItem(value: 'learning', child: Text('Learning (Copper)')),
                      DropdownMenuItem(value: 'achievement', child: Text('Achievement (Gold)')),
                      DropdownMenuItem(value: 'goal', child: Text('Goal (Plum)')),
                      DropdownMenuItem(value: 'neutral', child: Text('Neutral (Sage)')),
                      DropdownMenuItem(value: 'destructive', child: Text('Destructive (Rose)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedRole = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: AppFonts.ui(context, color: theme.textMuted)),
                ),
                TextButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      await db.addCategory(name, selectedRole);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Add', style: AppFonts.ui(context, color: AppColors.getRoleColor('sage', theme.isDark), weight: FontWeight.bold)),
                ),
              ],
            );
          },
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
        return AlertDialog(
          backgroundColor: theme.surface,
          title: Text('Rename Category', style: AppFonts.heading(context, size: 18)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: AppFonts.ui(context),
            decoration: InputDecoration(
              labelText: 'New Name',
              labelStyle: AppFonts.ui(context, color: theme.textMuted),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppFonts.ui(context, color: theme.textMuted)),
            ),
            TextButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  await db.renameCategory(cat.id, newName);
                  Navigator.pop(context);
                }
              },
              child: Text('Save', style: AppFonts.ui(context, color: AppColors.getRoleColor('sage', theme.isDark), weight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // --- STAGES MANAGER SECTION ---
  Widget _buildStagesSection(BuildContext context, AppDatabase db, UserSetting settings) {
    final theme = ThemeProvider.of(context);
    final stages = settings.stagesJson.split(',');

    return MilestoneCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Goal Stages Journey', style: AppFonts.ui(context, size: 16, weight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: AppColors.getRoleColor('sage', theme.isDark)),
                onPressed: () => _showAddStageDialog(context, db, settings, stages),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Order represents staged progress for Goals',
            style: AppFonts.ui(context, size: 11, color: theme.textMuted),
          ),
          const SizedBox(height: 12),
          Column(
            children: stages.asMap().entries.map((entry) {
              final idx = entry.key;
              final stageName = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBorder.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${idx + 1}. $stageName',
                        style: AppFonts.mono(context, size: 12, color: theme.text, weight: FontWeight.w600),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 16),
                      onPressed: () => _showRenameStageDialog(context, db, settings, stages, idx),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 16, color: AppColors.getRoleColor('destructive', theme.isDark)),
                      onPressed: stages.length > 2
                          ? () {
                              final updated = List<String>.from(stages)..removeAt(idx);
                              db.updateSettings(
                                userName: settings.userName,
                                currentChapterGoal: settings.currentChapterGoal,
                                isDarkMode: settings.isDarkMode,
                                stagesJson: updated.join(','),
                              );
                            }
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Must have at least 2 stages.')),
                              );
                            },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showAddStageDialog(BuildContext context, AppDatabase db, UserSetting settings, List<String> stages) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final theme = ThemeProvider.of(context);
        return AlertDialog(
          backgroundColor: theme.surface,
          title: Text('Add Journey Stage', style: AppFonts.heading(context, size: 18)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: AppFonts.ui(context),
            decoration: InputDecoration(
              labelText: 'Stage Name (e.g. Test, Review)',
              labelStyle: AppFonts.ui(context, color: theme.textMuted),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppFonts.ui(context, color: theme.textMuted)),
            ),
            TextButton(
              onPressed: () async {
                final txt = controller.text.trim();
                if (txt.isNotEmpty) {
                  final updated = List<String>.from(stages)..add(txt);
                  await db.updateSettings(
                    userName: settings.userName,
                    currentChapterGoal: settings.currentChapterGoal,
                    isDarkMode: settings.isDarkMode,
                    stagesJson: updated.join(','),
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Add', style: AppFonts.ui(context, color: AppColors.getRoleColor('sage', theme.isDark), weight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showRenameStageDialog(
    BuildContext context,
    AppDatabase db,
    UserSetting settings,
    List<String> stages,
    int idx,
  ) {
    final controller = TextEditingController(text: stages[idx]);
    showDialog(
      context: context,
      builder: (context) {
        final theme = ThemeProvider.of(context);
        return AlertDialog(
          backgroundColor: theme.surface,
          title: Text('Rename Journey Stage', style: AppFonts.heading(context, size: 18)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: AppFonts.ui(context),
            decoration: InputDecoration(
              labelText: 'New Name',
              labelStyle: AppFonts.ui(context, color: theme.textMuted),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppFonts.ui(context, color: theme.textMuted)),
            ),
            TextButton(
              onPressed: () async {
                final txt = controller.text.trim();
                if (txt.isNotEmpty) {
                  final updated = List<String>.from(stages);
                  updated[idx] = txt;
                  await db.updateSettings(
                    userName: settings.userName,
                    currentChapterGoal: settings.currentChapterGoal,
                    isDarkMode: settings.isDarkMode,
                    stagesJson: updated.join(','),
                  );
                  Navigator.pop(context);
                }
              },
              child: Text(
                'Save',
                style: AppFonts.ui(
                  context,
                  color: AppColors.getRoleColor('sage', theme.isDark),
                  weight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
