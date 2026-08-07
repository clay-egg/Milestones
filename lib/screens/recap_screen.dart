import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/state_providers.dart';
import '../widgets/common_widgets.dart';
import '../database/database.dart';

enum RecapType { weekly, monthly }

class RecapScreen extends ConsumerStatefulWidget {
  const RecapScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RecapScreen> createState() => _RecapScreenState();
}

class _RecapScreenState extends ConsumerState<RecapScreen> {
  RecapType _recapType = RecapType.weekly;
  late DateTime _referenceDate;

  @override
  void initState() {
    super.initState();
    _referenceDate = DateTime.now();
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recap & Insights', style: AppFonts.heading(context, size: 20)),
                  const SizedBox(height: 2),
                  Text(
                    'WEEKLY & MONTHLY PRODUCTIVITY DIGEST',
                    style: AppFonts.mono(context, size: 9.5, color: theme.textMuted, weight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Control Bar Card (Balanced Switcher & Navigator)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.border, width: 0.8),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 520;
                    final switcherWidget = Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.border, width: 0.6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTypeChip(RecapType.weekly, 'WEEKLY', copperColor, theme),
                          const SizedBox(width: 4),
                          _buildTypeChip(RecapType.monthly, 'MONTHLY', copperColor, theme),
                        ],
                      ),
                    );

                    final navigatorWidget = Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.border, width: 0.6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => _navigatePeriod(-1),
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Icon(Icons.chevron_left_rounded, size: 18, color: theme.textMuted),
                            ),
                          ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  periodLabel,
                                  style: AppFonts.mono(context, size: 11, color: theme.text, weight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _navigatePeriod(1),
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Icon(Icons.chevron_right_rounded, size: 18, color: theme.textMuted),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (isWide) {
                      return Row(
                        children: [
                          switcherWidget,
                          const SizedBox(width: 14),
                          Expanded(child: navigatorWidget),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        Center(child: switcherWidget),
                        const SizedBox(height: 10),
                        navigatorWidget,
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // 3. Key Metrics Cards Grid (Uniform 95px height)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: 'LOGGED ENTRIES',
                      value: '${periodEntries.length}',
                      unit: 'TOTAL LOGS',
                      color: copperColor,
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      title: 'CONSISTENCY',
                      value: '$consistencyPercent%',
                      unit: '$activeCount/$totalPeriodDays DAYS ACTIVE',
                      color: AppColors.getRoleColor('gold', theme.isDark),
                      theme: theme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

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
                  const SizedBox(width: 12),
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
              const SizedBox(height: 20),

              // 4. Category Breakdown Horizontal Bar Chart Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.border, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CATEGORY DISTRIBUTION',
                      style: AppFonts.mono(context, size: 9.5, color: theme.textMuted, weight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    if (totalItems == 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'No activity logged for this timeframe.',
                            style: AppFonts.ui(context, size: 12, color: theme.textMuted),
                          ),
                        ),
                      )
                    else
                      Builder(
                        builder: (context) {
                          final activeCategories = categories.where((cat) => (catCounts[cat.id] ?? 0) > 0).toList();
                          activeCategories.sort((a, b) => (catCounts[b.id] ?? 0).compareTo(catCounts[a.id] ?? 0));

                          return ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: activeCategories.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
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
                                  const SizedBox(height: 5),
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
                ),
              ),
              const SizedBox(height: 24),

              // 5. GitHub-Style Activity Matrix Card
              _buildActivityMatrixCard(
                context,
                startDate: startDate,
                endDate: endDate,
                recapType: _recapType,
                periodEntries: periodEntries,
                periodCompletedTodos: periodCompletedTodos,
                copperColor: copperColor,
                theme: theme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityMatrixCard(
    BuildContext context, {
    required DateTime startDate,
    required DateTime endDate,
    required RecapType recapType,
    required List<EntryWithCategory> periodEntries,
    required List<TodoItem> periodCompletedTodos,
    required Color copperColor,
    required ThemeDetails theme,
  }) {
    // 1. Build map of yyyy-MM-dd -> count
    final Map<String, int> dailyCounts = {};
    for (var e in periodEntries) {
      final key = DateFormat('yyyy-MM-dd').format(e.entry.date);
      dailyCounts[key] = (dailyCounts[key] ?? 0) + 1;
    }
    for (var t in periodCompletedTodos) {
      if (t.dateCompleted != null) {
        final key = DateFormat('yyyy-MM-dd').format(t.dateCompleted!);
        dailyCounts[key] = (dailyCounts[key] ?? 0) + 1;
      }
    }

    // 2. Generate list of Days
    final List<DateTime> days = [];
    var curr = DateTime(startDate.year, startDate.month, startDate.day);
    final endLimit = DateTime(endDate.year, endDate.month, endDate.day);
    while (!curr.isAfter(endLimit)) {
      days.add(curr);
      curr = curr.add(const Duration(days: 1));
    }

    final dayHeaders = const ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];

    return Container(
      width: double.infinity,
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
              Row(
                children: [
                  Text(
                    'ACTIVITY MATRIX',
                    style: AppFonts.mono(context, size: 9.5, color: theme.textMuted, weight: FontWeight.bold),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: copperColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: copperColor.withOpacity(0.35), width: 0.6),
                    ),
                    child: Text(
                      '${periodEntries.length + periodCompletedTodos.length} LOGS',
                      style: AppFonts.mono(context, size: 8.5, color: copperColor, weight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('Less', style: AppFonts.mono(context, size: 8.5, color: theme.textMuted)),
                  const SizedBox(width: 4),
                  _buildMatrixLegendSquare(theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg, theme),
                  const SizedBox(width: 2),
                  _buildMatrixLegendSquare(copperColor.withOpacity(0.35), theme),
                  const SizedBox(width: 2),
                  _buildMatrixLegendSquare(copperColor.withOpacity(0.70), theme),
                  const SizedBox(width: 2),
                  _buildMatrixLegendSquare(copperColor, theme),
                  const SizedBox(width: 4),
                  Text('More', style: AppFonts.mono(context, size: 8.5, color: theme.textMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Day of week headers (MO TU WE TH FR SA SU)
          Row(
            children: dayHeaders.map((h) {
              return Expanded(
                child: Center(
                  child: Text(
                    h,
                    style: AppFonts.mono(context, size: 8.5, color: theme.textMuted, weight: FontWeight.bold),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),

          // Grid of activity squares with day numbers
          Builder(
            builder: (context) {
              final firstWeekday = days.isNotEmpty ? days.first.weekday : 1;
              final emptyOffsetCount = firstWeekday - 1;
              final totalGridCount = days.length + emptyOffsetCount;

              return GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: totalGridCount,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  if (index < emptyOffsetCount) {
                    return const SizedBox.shrink();
                  }

                  final dayIndex = index - emptyOffsetCount;
                  final day = days[dayIndex];
                  final dateStr = DateFormat('yyyy-MM-dd').format(day);
                  final count = dailyCounts[dateStr] ?? 0;

                  Color squareColor;
                  Color textColor;
                  if (count == 0) {
                    squareColor = theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg;
                    textColor = theme.textMuted.withOpacity(0.7);
                  } else if (count == 1) {
                    squareColor = copperColor.withOpacity(0.35);
                    textColor = theme.text;
                  } else if (count <= 3) {
                    squareColor = copperColor.withOpacity(0.70);
                    textColor = theme.isDark ? Colors.white : Colors.black;
                  } else {
                    squareColor = copperColor;
                    textColor = Colors.black;
                  }

                  final dateLabel = DateFormat('EEE, MMM d').format(day);
                  final tooltipMsg = count == 0
                      ? '$dateLabel · No logs'
                      : '$dateLabel · $count ${count == 1 ? 'log' : 'logs'}';

                  return Tooltip(
                    message: tooltipMsg,
                    preferBelow: false,
                    verticalOffset: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: squareColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: count == 0 ? theme.border.withOpacity(0.5) : Colors.transparent,
                          width: 0.5,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${day.day}',
                              style: AppFonts.mono(
                                context,
                                size: count > 0 ? 10.5 : 10,
                                color: textColor,
                                weight: count > 0 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            if (count > 0) ...[
                              const SizedBox(height: 1),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0.5),
                                decoration: BoxDecoration(
                                  color: (count >= 4 ? Colors.black : copperColor).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  '${count}x',
                                  style: AppFonts.mono(
                                    context,
                                    size: 7.5,
                                    color: textColor,
                                    weight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixLegendSquare(Color color, ThemeDetails theme) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: theme.border.withOpacity(0.4), width: 0.5),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  style: AppFonts.mono(
                    context,
                    size: 9,
                    color: color,
                    weight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: AppFonts.heading(context, size: 20),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            unit,
            style: AppFonts.mono(context, size: 8.5, color: theme.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
        borderRadius: BorderRadius.circular(8),
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
