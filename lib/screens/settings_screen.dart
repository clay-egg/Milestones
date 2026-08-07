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
  bool _profileInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveProfile(AppDatabase db, UserSetting settings) {
    db.updateSettings(
      userName: _nameController.text.trim(),
      currentChapterGoal: settings.currentChapterGoal,
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

                      // 2. Profile Section
                      _buildProfileSection(context, db, settings),
                      const SizedBox(height: 16),

                      // 3. Category Management Section
                      _buildCategoriesSection(context, db, categoriesAsync),
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
