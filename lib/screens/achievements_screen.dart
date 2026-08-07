import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/state_providers.dart';
import '../widgets/common_widgets.dart';
import '../widgets/recap_modal.dart';
import '../database/database.dart';
import 'package:intl/intl.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  int _calculateActiveStreak(List<EntryWithCategory> entries) {
    if (entries.isEmpty) return 0;
    final Set<String> loggedDates = {};
    for (final e in entries) {
      loggedDates.add(DateFormat('yyyy-MM-dd').format(e.entry.date));
    }

    final now = DateTime.now();
    var checkDate = DateTime(now.year, now.month, now.day);
    var streak = 0;

    final todayStr = DateFormat('yyyy-MM-dd').format(checkDate);
    final yesterdayStr = DateFormat('yyyy-MM-dd').format(checkDate.subtract(const Duration(days: 1)));

    if (!loggedDates.contains(todayStr) && !loggedDates.contains(yesterdayStr)) {
      return 0;
    }

    if (!loggedDates.contains(todayStr) && loggedDates.contains(yesterdayStr)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (loggedDates.contains(DateFormat('yyyy-MM-dd').format(checkDate))) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  void _showAddWinDialog(BuildContext context, AppDatabase db, List<Categorie> categories) {
    final controller = TextEditingController();
    int? selectedCatId = categories.isNotEmpty ? categories.first.id : null;

    showDialog(
      context: context,
      builder: (ctx) {
        final t = ThemeProvider.of(ctx);
        final goldColor = AppColors.getRoleColor('gold', t.isDark);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: t.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text('Log Win', style: AppFonts.heading(ctx, size: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    style: AppFonts.ui(ctx, size: 14),
                    decoration: InputDecoration(
                      hintText: 'e.g. 120 days in Duolingo, First job interview',
                      hintStyle: AppFonts.ui(ctx, size: 12.5, color: t.textMuted),
                      filled: true,
                      fillColor: t.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: t.border, width: 0.8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: t.border, width: 0.8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: goldColor, width: 1.2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'CATEGORY',
                    style: AppFonts.mono(ctx, size: 9, color: t.textMuted, weight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((cat) {
                      final isSelected = selectedCatId == cat.id;
                      final catColor = AppColors.getRoleColor(cat.role, t.isDark);
                      return ChoiceChip(
                        label: Text(cat.name),
                        selected: isSelected,
                        selectedColor: catColor.withValues(alpha: 0.2),
                        backgroundColor: t.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                        labelStyle: AppFonts.ui(
                          ctx,
                          size: 11.5,
                          color: isSelected ? catColor : t.textMuted,
                          weight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected ? catColor : t.border,
                          width: isSelected ? 1.0 : 0.5,
                        ),
                        onSelected: (val) {
                          if (val) setDialogState(() => selectedCatId = cat.id);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancel', style: AppFonts.ui(ctx, color: t.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goldColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () async {
                    final text = controller.text.trim();
                    if (text.isNotEmpty && selectedCatId != null) {
                      await db.saveQuickCapture(
                        description: text,
                        categoryId: selectedCatId!,
                        date: DateTime.now(),
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                    }
                  },
                  child: Text('Save', style: AppFonts.ui(ctx, color: Colors.black, weight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final entriesAsync = ref.watch(timelineEntriesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final db = ref.watch(databaseProvider);
    final goldColor = AppColors.getRoleColor('gold', theme.isDark);
    final copperColor = AppColors.getRoleColor('copper', theme.isDark);

    final entries = entriesAsync.value ?? [];
    final categories = categoriesAsync.value ?? [];
    final streak = _calculateActiveStreak(entries);

    // Filter win/achievement entries
    final winEntries = entries.where((e) {
      final isGold = e.category.role == 'gold' || e.category.role == 'achievement';
      final descLower = e.entry.description.toLowerCase();
      final hasWinKeyword = descLower.contains('win') ||
          descLower.contains('streak') ||
          descLower.contains('interview') ||
          descLower.contains('duolingo') ||
          descLower.contains('first') ||
          descLower.contains('passed') ||
          descLower.contains('hired') ||
          descLower.contains('completed');
      return isGold || hasWinKeyword;
    }).toList();

    // Calculate Active Days this month
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final Set<String> activeMonthDays = {};
    for (final e in entries) {
      if (e.entry.date.isAfter(currentMonthStart.subtract(const Duration(seconds: 1)))) {
        activeMonthDays.add(DateFormat('yyyy-MM-dd').format(e.entry.date));
      }
    }
    final activeDaysThisMonth = activeMonthDays.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Clean Minimalist Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Wins & Streaks', style: AppFonts.heading(context, size: 18)),
                  GestureDetector(
                    onTap: () => _showAddWinDialog(context, db, categories),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: goldColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: goldColor.withValues(alpha: 0.35), width: 0.8),
                      ),
                      child: Text(
                        '+ Log Win',
                        style: AppFonts.mono(context, size: 10.5, color: goldColor, weight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Pure Minimalist Numbers Banner
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: copperColor.withValues(alpha: 0.3), width: 0.8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$streak',
                            style: AppFonts.mono(context, size: 26, color: copperColor, weight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'DAY STREAK',
                            style: AppFonts.mono(context, size: 9.5, color: theme.textMuted, weight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: goldColor.withValues(alpha: 0.3), width: 0.8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$activeDaysThisMonth',
                            style: AppFonts.mono(context, size: 26, color: goldColor, weight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ACTIVE DAYS THIS MONTH',
                            style: AppFonts.mono(context, size: 9.5, color: theme.textMuted, weight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // 3. Clean Wins Timeline Feed
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Wins Feed', style: AppFonts.heading(context, size: 15)),
                  Text(
                    '${winEntries.length} TOTAL WINS',
                    style: AppFonts.mono(context, size: 9.5, color: theme.textMuted, weight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (winEntries.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.border, width: 0.5),
                  ),
                  child: Center(
                    child: Text(
                      'No wins logged yet. Tap "+ Log Win" to add one.',
                      style: AppFonts.ui(context, size: 13, color: theme.textMuted),
                    ),
                  ),
                )
              else
                ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: winEntries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = winEntries[index];
                    final catColor = AppColors.getRoleColor(item.category.role, theme.isDark);

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: theme.border, width: 0.8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Date Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: theme.border, width: 0.6),
                            ),
                            child: Text(
                              DateFormat('MMM d').format(item.entry.date).toUpperCase(),
                              style: AppFonts.mono(context, size: 9, color: theme.textMuted, weight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Win Description
                          Expanded(
                            child: Text(
                              item.entry.description,
                              style: AppFonts.ui(context, size: 13, color: theme.text, weight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Category Badge
                          RoleBadge(
                            text: item.category.name,
                            role: item.category.role,
                            isSmall: true,
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
