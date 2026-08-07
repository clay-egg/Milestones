import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/state_providers.dart';
import '../widgets/common_widgets.dart';
import '../database/database.dart';

enum RecapType { weekly, monthly }

class RecapModal extends ConsumerStatefulWidget {
  const RecapModal({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 880) {
      showDialog(
        context: context,
        builder: (context) => const RecapModal(),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const RecapModal(),
      );
    }
  }

  @override
  ConsumerState<RecapModal> createState() => _RecapModalState();
}

class _RecapModalState extends ConsumerState<RecapModal> {
  RecapType _recapType = RecapType.weekly;
  late DateTime _referenceDate;

  @override
  void initState() {
    super.initState();
    _referenceDate = DateTime.now();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Get Monday of current reference week
  DateTime _getWeekStart(DateTime date) {
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: date.weekday - 1));
  }

  // Get Sunday of current reference week
  DateTime _getWeekEnd(DateTime date) {
    final start = _getWeekStart(date);
    return DateTime(start.year, start.month, start.day, 23, 59, 59).add(const Duration(days: 6));
  }

  DateTime _getMonthStart(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  DateTime _getMonthEnd(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  void _navigatePeriod(int delta) {
    setState(() {
      if (_recapType == RecapType.weekly) {
        _referenceDate = _referenceDate.add(Duration(days: delta * 7));
      } else {
        _referenceDate = DateTime(_referenceDate.year, _referenceDate.month + delta, 15);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 880;
    final copperColor = AppColors.getRoleColor('copper', theme.isDark);
    final categoriesAsync = ref.watch(categoriesProvider);
    final entriesAsync = ref.watch(timelineEntriesProvider);
    final todosAsync = ref.watch(todosProvider);

    final categories = categoriesAsync.value ?? [];
    final allEntries = entriesAsync.value ?? [];
    final allTodos = todosAsync.value ?? [];

    // Calculate start & end bounds
    late DateTime startDate;
    late DateTime endDate;
    late String periodLabel;

    if (_recapType == RecapType.weekly) {
      startDate = _getWeekStart(_referenceDate);
      endDate = _getWeekEnd(_referenceDate);
      final startFmt = DateFormat('MMM d').format(startDate);
      final endFmt = DateFormat('MMM d, yyyy').format(endDate);
      periodLabel = '$startFmt – $endFmt'.toUpperCase();
    } else {
      startDate = _getMonthStart(_referenceDate);
      endDate = _getMonthEnd(_referenceDate);
      periodLabel = DateFormat('MMMM yyyy').format(startDate).toUpperCase();
    }

    // Filter data inside range
    final periodEntries = allEntries.where((e) {
      return e.entry.date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
          e.entry.date.isBefore(endDate.add(const Duration(seconds: 1)));
    }).toList();

    final periodCompletedTodos = allTodos.where((t) {
      if (!t.isCompleted || t.dateCompleted == null) return false;
      return t.dateCompleted!.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
          t.dateCompleted!.isBefore(endDate.add(const Duration(seconds: 1)));
    }).toList();

    // Calculate Active Days Consistency
    final Set<String> activeDayKeys = {};
    for (var e in periodEntries) {
      activeDayKeys.add(DateFormat('yyyy-MM-dd').format(e.entry.date));
    }
    for (var t in periodCompletedTodos) {
      if (t.dateCompleted != null) {
        activeDayKeys.add(DateFormat('yyyy-MM-dd').format(t.dateCompleted!));
      }
    }

    final totalPeriodDays = _recapType == RecapType.weekly
        ? 7
        : DateTime(startDate.year, startDate.month + 1, 0).day;
    final activeCount = activeDayKeys.length;
    final consistencyPercent = (activeCount / totalPeriodDays * 100).round();

    // Category Breakdown map
    final Map<int, int> catCounts = {};
    for (var e in periodEntries) {
      catCounts[e.entry.categoryId] = (catCounts[e.entry.categoryId] ?? 0) + 1;
    }
    for (var t in periodCompletedTodos) {
      catCounts[t.categoryId] = (catCounts[t.categoryId] ?? 0) + 1;
    }

    final totalItems = periodEntries.length + periodCompletedTodos.length;

    // Calculate Top Focus Category
    Categorie? topCategory;
    int topCatCount = 0;
    if (catCounts.isNotEmpty) {
      int maxCount = -1;
      int topCatId = -1;
      catCounts.forEach((catId, count) {
        if (count > maxCount) {
          maxCount = count;
          topCatId = catId;
        }
      });
      topCategory = categories.firstWhere(
        (c) => c.id == topCatId,
        orElse: () => Categorie(id: 0, name: 'General', role: 'copper', weeklyTarget: 0),
      );
      topCatCount = maxCount;
    }

    // Calculate Peak Activity Day
    final Map<String, int> dayCounts = {};
    for (var e in periodEntries) {
      final dayName = DateFormat('EEEE').format(e.entry.date);
      dayCounts[dayName] = (dayCounts[dayName] ?? 0) + 1;
    }
    for (var t in periodCompletedTodos) {
      if (t.dateCompleted != null) {
        final dayName = DateFormat('EEEE').format(t.dateCompleted!);
        dayCounts[dayName] = (dayCounts[dayName] ?? 0) + 1;
      }
    }

    String peakDayName = '—';
    int peakDayCount = 0;
    if (dayCounts.isNotEmpty) {
      int maxDayLogs = -1;
      dayCounts.forEach((day, count) {
        if (count > maxDayLogs) {
          maxDayLogs = count;
          peakDayName = day;
        }
      });
      peakDayCount = maxDayLogs;
    }

    Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Modal Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.auto_graph_rounded, size: 18, color: copperColor),
                const SizedBox(width: 8),
                Text('Recap Digest', style: AppFonts.heading(context, size: 17)),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: theme.textMuted,
              onPressed: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Type Switcher Pill (WEEKLY vs MONTHLY)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.border, width: 0.8),
              ),
              child: Row(
                children: [
                  _buildTypeChip(RecapType.weekly, 'WEEKLY', copperColor, theme),
                  const SizedBox(width: 4),
                  _buildTypeChip(RecapType.monthly, 'MONTHLY', copperColor, theme),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Period Navigator (< AUG 3 – AUG 9, 2026 >)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.border, width: 0.8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => _navigatePeriod(-1),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(Icons.chevron_left_rounded, size: 18, color: theme.textMuted),
                ),
              ),
              Text(
                periodLabel,
                style: AppFonts.mono(context, size: 11, color: theme.text, weight: FontWeight.bold),
              ),
              InkWell(
                onTap: () => _navigatePeriod(1),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(Icons.chevron_right_rounded, size: 18, color: theme.textMuted),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Key Metrics Summary Cards Row 1
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                title: 'LOGGED',
                value: '${periodEntries.length}',
                unit: 'ENTRIES',
                color: copperColor,
                theme: theme,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                context,
                title: 'CONSISTENCY',
                value: '$consistencyPercent%',
                unit: '$activeCount/$totalPeriodDays DAYS',
                color: AppColors.getRoleColor('gold', theme.isDark),
                theme: theme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Key Metrics Summary Cards Row 2 (Top Area + Peak Day)
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                title: 'MOST ACTIVE AREA',
                value: topCategory != null ? topCategory.name : '—',
                unit: topCategory != null ? '$topCatCount ITEMS (${(topCatCount / (totalItems > 0 ? totalItems : 1) * 100).round()}%)' : 'NO DATA',
                color: topCategory != null ? AppColors.getRoleColor(topCategory.role, theme.isDark) : theme.textMuted,
                theme: theme,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricCard(
                context,
                title: 'PEAK DAY',
                value: peakDayName,
                unit: peakDayCount > 0 ? '$peakDayCount ${peakDayCount == 1 ? 'LOG' : 'LOGS'}' : 'NO DATA',
                color: AppColors.getRoleColor('plum', theme.isDark),
                theme: theme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Category Breakdown Horizontal Bar Chart
        Text(
          'CATEGORY DISTRIBUTION',
          style: AppFonts.mono(context, size: 9.5, color: theme.textMuted, weight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        if (totalItems == 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.border, width: 0.6),
            ),
            child: Center(
              child: Text(
                'No activity data for distribution.',
                style: AppFonts.ui(context, size: 11.5, color: theme.textMuted),
              ),
            ),
          )
        else ...[
          Builder(
            builder: (context) {
              final activeCategories = categories.where((cat) => (catCounts[cat.id] ?? 0) > 0).toList();
              activeCategories.sort((a, b) => (catCounts[b.id] ?? 0).compareTo(catCounts[a.id] ?? 0));

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeCategories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final cat = activeCategories[index];
                  final count = catCounts[cat.id] ?? 0;
                  final ratio = (count / totalItems).clamp(0.0, 1.0);
                  final percent = (ratio * 100).round();
                  final roleColor = AppColors.getRoleColor(cat.role, theme.isDark);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(color: roleColor, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                cat.name,
                                style: AppFonts.mono(
                                  context,
                                  size: 11,
                                  color: theme.text,
                                  weight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$count ${count == 1 ? 'item' : 'items'} · $percent%',
                            style: AppFonts.mono(
                              context,
                              size: 10,
                              color: roleColor,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Stack(
                        children: [
                          Container(
                            height: 7,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: ratio,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 7,
                              decoration: BoxDecoration(
                                color: roleColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
        const SizedBox(height: 18),

        // Highlights List
        Text(
          'PERIOD HIGHLIGHTS',
          style: AppFonts.mono(context, size: 9.5, color: theme.textMuted, weight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        if (totalItems == 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.border, width: 0.6),
            ),
            child: Center(
              child: Text(
                'No activity logged for this timeframe.',
                style: AppFonts.ui(context, size: 12, color: theme.textMuted),
              ),
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: periodEntries.length + periodCompletedTodos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                if (index < periodEntries.length) {
                  final entryWithCat = periodEntries[index];
                  return _buildHighlightRow(
                    context,
                    title: entryWithCat.entry.description,
                    dateLabel: DateFormat('MMM d').format(entryWithCat.entry.date),
                    catName: entryWithCat.category.name,
                    catRole: entryWithCat.category.role,
                    isTask: false,
                    theme: theme,
                  );
                } else {
                  final todo = periodCompletedTodos[index - periodEntries.length];
                  final cat = categories.firstWhere(
                    (c) => c.id == todo.categoryId,
                    orElse: () => Categorie(id: 0, name: 'General', role: 'copper', weeklyTarget: 0),
                  );
                  return _buildHighlightRow(
                    context,
                    title: todo.title,
                    dateLabel: todo.dateCompleted != null ? DateFormat('MMM d').format(todo.dateCompleted!) : 'Done',
                    catName: cat.name,
                    catRole: cat.role,
                    isTask: true,
                    theme: theme,
                  );
                }
              },
            ),
          ),
      ],
    );

    if (isDesktop) {
      return Dialog(
        backgroundColor: theme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.border, width: 0.8),
        ),
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: body,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(color: theme.border, width: 0.8)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: body,
      ),
    );
  }

  Widget _buildTypeChip(RecapType type, String label, Color accentColor, ThemeDetails theme) {
    final isSelected = _recapType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _recapType = type;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: AppFonts.mono(
            context,
            size: 10,
            color: isSelected ? Colors.black : theme.textMuted,
            weight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String unit,
    required Color color,
    required ThemeDetails theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppFonts.mono(context, size: 8.5, color: color, weight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppFonts.heading(context, size: 18),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: AppFonts.mono(context, size: 8, color: theme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightRow(
    BuildContext context, {
    required String title,
    required String dateLabel,
    required String catName,
    required String catRole,
    required bool isTask,
    required ThemeDetails theme,
  }) {
    final roleColor = AppColors.getRoleColor(catRole, theme.isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.border, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(
            isTask ? Icons.check_circle_outline_rounded : Icons.bubble_chart_outlined,
            size: 13,
            color: isTask ? AppColors.getRoleColor('sage', theme.isDark) : roleColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: AppFonts.ui(context, size: 12.5, color: theme.text),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            dateLabel,
            style: AppFonts.mono(context, size: 9, color: theme.textMuted),
          ),
          const SizedBox(width: 6),
          RoleBadge(text: catName, role: catRole, isSmall: true),
        ],
      ),
    );
  }
}
