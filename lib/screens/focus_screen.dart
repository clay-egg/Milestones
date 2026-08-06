import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/state_providers.dart';
import '../widgets/common_widgets.dart';
import '../database/database.dart';

class FocusScreen extends ConsumerWidget {
  const FocusScreen({Key? key}) : super(key: key);

  static const List<Map<String, String>> colorRoles = [
    {'role': 'copper', 'name': 'Copper'},
    {'role': 'gold', 'name': 'Gold'},
    {'role': 'plum', 'name': 'Plum'},
    {'role': 'sage', 'name': 'Sage'},
    {'role': 'rose', 'name': 'Rose'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ThemeProvider.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);
    final timelineAsync = ref.watch(timelineEntriesProvider);
    final db = ref.watch(databaseProvider);
    final copperColor = AppColors.getRoleColor('copper', theme.isDark);

    // Compute entry counts per focus category
    final entries = timelineAsync.value ?? [];
    final Map<int, int> focusEntryCounts = {};
    for (final e in entries) {
      focusEntryCounts[e.category.id] = (focusEntryCounts[e.category.id] ?? 0) + 1;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Focus Categories', style: AppFonts.heading(context, size: 22)),
                      const SizedBox(height: 4),
                      Text(
                        'Manage your primary areas of momentum.',
                        style: AppFonts.ui(context, size: 13, color: theme.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showFocusDialog(context, db, existingCount: categoriesAsync.value?.length ?? 0),
                  icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                  label: Text(
                    'Add Focus',
                    style: AppFonts.ui(context, color: Colors.white, weight: FontWeight.bold, size: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: copperColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Focus Cards Grid / List
            categoriesAsync.when(
              data: (focuses) {
                if (focuses.isEmpty) {
                  return _buildEmptyState(context, theme, db);
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 880 ? 3 : (constraints.maxWidth > 550 ? 2 : 1);
                    if (crossAxisCount == 1) {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: focuses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final focus = focuses[index];
                          final count = focusEntryCounts[focus.id] ?? 0;
                          return _buildFocusCard(context, db, focus, count, theme);
                        },
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 120,
                      ),
                      itemCount: focuses.length,
                      itemBuilder: (context, index) {
                        final focus = focuses[index];
                        final count = focusEntryCounts[focus.id] ?? 0;
                        return _buildFocusCard(context, db, focus, count, theme);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              )),
              error: (err, stack) => Center(child: Text('Error loading focuses: $err')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeDetails theme, AppDatabase db) {
    final copperColor = AppColors.getRoleColor('copper', theme.isDark);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.border, width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.center_focus_strong_rounded, size: 48, color: copperColor),
          const SizedBox(height: 16),
          Text(
            'No Focus Categories Yet',
            style: AppFonts.heading(context, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first focus category (e.g. Fitness, Coding, Language) to categorize your log entries.',
            textAlign: TextAlign.center,
            style: AppFonts.ui(context, size: 13, color: theme.textMuted),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => _showFocusDialog(context, db, existingCount: 0),
            icon: Icon(Icons.add, color: copperColor),
            label: Text('Create Focus', style: AppFonts.ui(context, color: copperColor, weight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: copperColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusCard(
    BuildContext context,
    AppDatabase db,
    Categorie focus,
    int entryCount,
    ThemeDetails theme,
  ) {
    final color = AppColors.getRoleColor(focus.role, theme.isDark);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Role Color Dot + Name
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: color.withOpacity(0.4), blurRadius: 4),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        focus.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.ui(context, size: 16, weight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              // Menu (Edit / Delete)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, size: 18, color: theme.textMuted),
                color: theme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onSelected: (val) {
                  if (val == 'edit') {
                    _showFocusDialog(context, db, category: focus);
                  } else if (val == 'delete') {
                    _confirmDelete(context, db, focus);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded, size: 16, color: theme.text),
                        const SizedBox(width: 8),
                        Text('Edit', style: AppFonts.ui(context, size: 13)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.getRoleColor('rose', theme.isDark)),
                        const SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: AppFonts.ui(
                            context,
                            size: 13,
                            color: AppColors.getRoleColor('rose', theme.isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Entry count footer badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$entryCount ${entryCount == 1 ? 'entry' : 'entries'}',
                  style: AppFonts.mono(context, size: 10, color: color, weight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onTap: () => _showFocusDialog(context, db, category: focus),
                child: Icon(Icons.tune_rounded, size: 16, color: color.withOpacity(0.7)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFocusDialog(
    BuildContext context,
    AppDatabase db, {
    Categorie? category,
    int existingCount = 0,
  }) {
    final isEditing = category != null;
    final controller = TextEditingController(text: category?.name ?? '');
    String selectedRole = category?.role ?? colorRoles[existingCount % colorRoles.length]['role']!;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final theme = ThemeProvider.of(context);
            final activeColor = AppColors.getRoleColor(selectedRole, theme.isDark);

            return AlertDialog(
              backgroundColor: theme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                isEditing ? 'Customize Focus' : 'New Focus Category',
                style: AppFonts.heading(context, size: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Focus Name',
                    style: AppFonts.ui(context, size: 12, color: theme.textMuted, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    style: AppFonts.ui(context, size: 15),
                    decoration: InputDecoration(
                      hintText: 'e.g. Fitness, Coding, Writing',
                      hintStyle: AppFonts.ui(context, color: theme.textMuted, size: 14),
                      filled: true,
                      fillColor: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: theme.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: theme.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: activeColor, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Color / Theme Role Picker
                  Text(
                    'Theme Color',
                    style: AppFonts.ui(context, size: 12, color: theme.textMuted, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: colorRoles.map((r) {
                      final roleKey = r['role']!;
                      final isSelected = selectedRole == roleKey;
                      final roleColor = AppColors.getRoleColor(roleKey, theme.isDark);

                      return GestureDetector(
                        onTap: () => setState(() => selectedRole = roleKey),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: roleColor.withOpacity(isSelected ? 0.25 : 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? roleColor : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: roleColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
                    backgroundColor: activeColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final name = controller.text.trim();
                    if (name.isEmpty) return;

                    if (isEditing) {
                      await db.updateCategory(category.id, name: name, role: selectedRole);
                    } else {
                      await db.addCategory(name, selectedRole);
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    isEditing ? 'Save Changes' : 'Create Focus',
                    style: AppFonts.ui(context, weight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, AppDatabase db, Categorie focus) {
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = ThemeProvider.of(ctx);
        final roseColor = AppColors.getRoleColor('rose', theme.isDark);
        return AlertDialog(
          backgroundColor: theme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text('Delete Focus?', style: AppFonts.heading(ctx, size: 16)),
          content: Text(
            'Are you sure you want to delete "${focus.name}"? Entries in this focus will remain in your timeline.',
            style: AppFonts.ui(ctx, size: 13, color: theme.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: AppFonts.ui(ctx, color: theme.textMuted)),
            ),
            TextButton(
              onPressed: () async {
                await db.deleteCategory(focus.id);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text('Delete', style: AppFonts.ui(ctx, color: roseColor, weight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
