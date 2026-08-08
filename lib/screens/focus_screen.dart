import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/state_providers.dart';
import '../widgets/common_widgets.dart';
import '../database/database.dart';
import 'package:intl/intl.dart';

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

    final entries = timelineAsync.value ?? [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentMonday = today.subtract(Duration(days: today.weekday - 1));

    // Compute entry counts: total logged & unique active days this week per focus category
    final Map<int, int> totalCounts = {};
    final Map<int, Set<String>> weeklyActiveDaysMap = {};

    for (final e in entries) {
      final catId = e.category.id;
      totalCounts[catId] = (totalCounts[catId] ?? 0) + 1;

      final entryDate = DateTime(e.entry.date.year, e.entry.date.month, e.entry.date.day);
      if (!entryDate.isBefore(currentMonday)) {
        final dateKey = DateFormat('yyyy-MM-dd').format(entryDate);
        weeklyActiveDaysMap.putIfAbsent(catId, () => {}).add(dateKey);
      }
    }

    return Scaffold(
      backgroundColor: theme.bg,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Minimalist Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Focus Areas', style: AppFonts.heading(context, size: 18)),
                GestureDetector(
                  onTap: () => _showFocusDialog(context, db, existingCount: categoriesAsync.value?.length ?? 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: copperColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: copperColor.withOpacity(0.4), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 14, color: copperColor),
                        const SizedBox(width: 4),
                        Text(
                          'Add Focus',
                          style: AppFonts.mono(
                            context,
                            size: 11,
                            color: copperColor,
                            weight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

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
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: focuses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final focus = focuses[index];
                          final totalCount = totalCounts[focus.id] ?? 0;
                          final activeDays = weeklyActiveDaysMap[focus.id]?.length ?? 0;
                          return _buildFocusCard(context, db, focus, totalCount, activeDays, theme);
                        },
                      );
                    }

                    return GridView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        mainAxisExtent: 105,
                      ),
                      itemCount: focuses.length,
                      itemBuilder: (context, index) {
                        final focus = focuses[index];
                        final totalCount = totalCounts[focus.id] ?? 0;
                        final activeDays = weeklyActiveDaysMap[focus.id]?.length ?? 0;
                        return _buildFocusCard(context, db, focus, totalCount, activeDays, theme);
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
            'Create your first focus category (e.g. Fitness, Coding, Language) to set goals and categorize your progress.',
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
    int totalCount,
    int activeDays,
    ThemeDetails theme,
  ) {
    final color = AppColors.getRoleColor(focus.role, theme.isDark);
    final targetDays = focus.weeklyTarget;
    final hasTarget = targetDays > 0;
    final ratio = hasTarget ? (activeDays / targetDays).clamp(0.0, 1.0) : 0.0;
    final isGoalReached = hasTarget && activeDays >= targetDays;

    return GestureDetector(
      onTap: () => _showFocusDialog(context, db, category: focus),
      child: Container(
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
            // Header Row: Role Color Dot + Name
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: color.withOpacity(0.4), blurRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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

            // Middle: Weekly Goal Progress by Active Days (if target set)
            if (hasTarget) ...[
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'WEEKLY GOAL',
                        style: AppFonts.mono(
                          context,
                          size: 9,
                          color: theme.textMuted,
                          weight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isGoalReached
                            ? 'Goal Met! 🎉'
                            : '$activeDays / $targetDays days (${(ratio * 100).toInt()}%)',
                        style: AppFonts.mono(
                          context,
                          size: 9,
                          color: isGoalReached ? AppColors.getRoleColor('sage', theme.isDark) : color,
                          weight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 5,
                      backgroundColor: color.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isGoalReached ? AppColors.getRoleColor('sage', theme.isDark) : color,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
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
    final nameController = TextEditingController(text: category?.name ?? '');
    final targetController = TextEditingController(
      text: category != null && category.weeklyTarget > 0 ? '${category.weeklyTarget}' : '',
    );
    String selectedRole = category?.role ?? colorRoles[existingCount % colorRoles.length]['role']!;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final theme = ThemeProvider.of(context);
            final activeColor = AppColors.getRoleColor(selectedRole, theme.isDark);

            return Dialog(
              backgroundColor: theme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                width: 380,
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Modal Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEditing ? 'Customize Focus' : 'New Focus Area',
                          style: AppFonts.heading(context, size: 17),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.close_rounded, size: 18, color: theme.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Input 1: Focus Name
                    Text(
                      'NAME',
                      style: AppFonts.mono(
                        context,
                        size: 9.5,
                        color: theme.textMuted,
                        weight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      autofocus: !isEditing,
                      style: AppFonts.ui(context, size: 14),
                      decoration: InputDecoration(
                        hintText: 'e.g. Coding, Fitness, Language',
                        hintStyle: AppFonts.ui(context, color: theme.textMuted, size: 13),
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
                          borderSide: BorderSide(color: activeColor, width: 1.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input 2: Weekly Goal (Active Days / Week)
                    Text(
                      'WEEKLY GOAL',
                      style: AppFonts.mono(
                        context,
                        size: 9.5,
                        color: theme.textMuted,
                        weight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: targetController,
                      keyboardType: TextInputType.number,
                      style: AppFonts.ui(context, size: 14),
                      decoration: InputDecoration(
                        hintText: 'Days per week (1–7)',
                        hintStyle: AppFonts.ui(context, color: theme.textMuted, size: 13),
                        suffixText: 'days / week',
                        suffixStyle: AppFonts.mono(context, size: 11, color: theme.textMuted),
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
                          borderSide: BorderSide(color: activeColor, width: 1.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input 3: Theme Color Swatches
                    Text(
                      'THEME COLOR',
                      style: AppFonts.mono(
                        context,
                        size: 9.5,
                        color: theme.textMuted,
                        weight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: roleColor.withOpacity(isSelected ? 0.22 : 0.08),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? roleColor : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 12,
                                height: 12,
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
                    const SizedBox(height: 22),

                    // Actions Bar
                    Row(
                      children: [
                        if (isEditing)
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              _confirmDelete(context, db, category);
                            },
                            child: Text(
                              'Delete',
                              style: AppFonts.ui(
                                context,
                                size: 13,
                                color: AppColors.getRoleColor('rose', theme.isDark),
                                weight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: AppFonts.ui(context, size: 13, color: theme.textMuted),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: activeColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                            final name = nameController.text.trim();
                            if (name.isEmpty) return;

                            final weeklyTarget = int.tryParse(targetController.text.trim()) ?? 0;

                            if (isEditing) {
                              await db.updateCategory(category.id, name: name, role: selectedRole, weeklyTarget: weeklyTarget);
                            } else {
                              await db.addCategory(name, selectedRole, weeklyTarget: weeklyTarget);
                            }

                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          child: Text(
                            isEditing ? 'Save' : 'Create',
                            style: AppFonts.ui(context, size: 13, weight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, AppDatabase db, Categorie category) {
    showDialog(
      context: context,
      builder: (ctx) {
        final t = ThemeProvider.of(ctx);
        final roseColor = AppColors.getRoleColor('rose', t.isDark);
        return AlertDialog(
          backgroundColor: t.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Delete Focus Category?', style: AppFonts.heading(ctx, size: 16)),
          content: Text(
            'Are you sure you want to delete "${category.name}"? Existing logged entries will stay in your timeline.',
            style: AppFonts.ui(ctx, size: 13, color: t.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: AppFonts.ui(ctx, color: t.textMuted)),
            ),
            TextButton(
              onPressed: () async {
                await db.deleteCategory(category.id);
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
