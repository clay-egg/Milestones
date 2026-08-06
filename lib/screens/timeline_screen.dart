import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/state_providers.dart';
import '../widgets/common_widgets.dart';
import '../widgets/quick_capture.dart';
import '../database/database.dart';
import 'package:intl/intl.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  int? _selectedFilterCategoryId;
  String _selectedMonthKey = 'ALL'; // 'ALL' or 'YYYY-MM'

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(timelineEntriesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final theme = ThemeProvider.of(context);
    final copperColor = AppColors.getRoleColor('copper', theme.isDark);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: entriesAsync.when(
        data: (allEntries) {
          // Extract unique months from all logged entries (DESC order)
          final Set<String> monthKeysSet = {};
          for (final e in allEntries) {
            monthKeysSet.add(DateFormat('yyyy-MM').format(e.entry.date));
          }
          final sortedMonthKeys = monthKeysSet.toList()..sort((a, b) => b.compareTo(a));

          // Filter entries by Focus Category and Month
          final entries = allEntries.where((e) {
            final matchesFocus = _selectedFilterCategoryId == null || e.category.id == _selectedFilterCategoryId;
            final mKey = DateFormat('yyyy-MM').format(e.entry.date);
            final matchesMonth = _selectedMonthKey == 'ALL' || mKey == _selectedMonthKey;
            return matchesFocus && matchesMonth;
          }).toList();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Sleek Weekly Activity Bar Chart
                _buildWeeklyChartCard(context, allEntries, theme),
                const SizedBox(height: 20),

                // 2. Section Header + Month Selector Dropdown + Entry Count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Timeline Feed', style: AppFonts.heading(context, size: 17)),
                        const SizedBox(width: 8),

                        // Month & Year Picker Dropdown Menu
                        PopupMenuButton<String>(
                          initialValue: _selectedMonthKey,
                          color: theme.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onSelected: (val) {
                            setState(() => _selectedMonthKey = val);
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'ALL',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.all_inclusive_rounded,
                                    size: 14,
                                    color: _selectedMonthKey == 'ALL' ? copperColor : theme.textMuted,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'All Time',
                                    style: AppFonts.ui(
                                      context,
                                      size: 12,
                                      color: _selectedMonthKey == 'ALL' ? copperColor : theme.text,
                                      weight: _selectedMonthKey == 'ALL' ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...sortedMonthKeys.map((mKey) {
                              final dateObj = DateFormat('yyyy-MM').parse(mKey);
                              final monthLabel = DateFormat('MMMM yyyy').format(dateObj);
                              final isSel = _selectedMonthKey == mKey;

                              return PopupMenuItem(
                                value: mKey,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_month_rounded,
                                      size: 14,
                                      color: isSel ? copperColor : theme.textMuted,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      monthLabel,
                                      style: AppFonts.ui(
                                        context,
                                        size: 12,
                                        color: isSel ? copperColor : theme.text,
                                        weight: isSel ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _selectedMonthKey != 'ALL'
                                  ? copperColor.withOpacity(0.12)
                                  : (theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _selectedMonthKey != 'ALL'
                                    ? copperColor.withOpacity(0.5)
                                    : theme.border,
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 11,
                                  color: _selectedMonthKey != 'ALL' ? copperColor : theme.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _selectedMonthKey == 'ALL'
                                      ? 'All Time'
                                      : DateFormat('MMM yyyy').format(DateFormat('yyyy-MM').parse(_selectedMonthKey)),
                                  style: AppFonts.mono(
                                    context,
                                    size: 10,
                                    color: _selectedMonthKey != 'ALL' ? copperColor : theme.text,
                                    weight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 13,
                                  color: _selectedMonthKey != 'ALL' ? copperColor : theme.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (entries.isNotEmpty)
                      Text(
                        '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'}',
                        style: AppFonts.mono(context, size: 10, color: theme.textMuted),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // 3. Focus Category Filter Chips (Compact Micro Chips)
                categoriesAsync.when(
                  data: (categories) {
                    if (categories.isEmpty) return const SizedBox.shrink();
                    return Container(
                      height: 24,
                      margin: const EdgeInsets.only(bottom: 6),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          // "All" Filter Chip
                          GestureDetector(
                            onTap: () => setState(() => _selectedFilterCategoryId = null),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              margin: const EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                color: _selectedFilterCategoryId == null
                                    ? copperColor
                                    : copperColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedFilterCategoryId == null
                                      ? copperColor
                                      : copperColor.withOpacity(0.2),
                                  width: 0.8,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'All Focuses',
                                  style: AppFonts.mono(
                                    context,
                                    size: 9,
                                    color: _selectedFilterCategoryId == null ? Colors.white : copperColor,
                                    weight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Individual Focus Chips with Micro Dots
                          ...categories.map((cat) {
                            final isSelected = _selectedFilterCategoryId == cat.id;
                            final catColor = AppColors.getRoleColor(cat.role, theme.isDark);

                            return GestureDetector(
                              onTap: () => setState(() {
                                _selectedFilterCategoryId = isSelected ? null : cat.id;
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                margin: const EdgeInsets.only(right: 5),
                                decoration: BoxDecoration(
                                  color: isSelected ? catColor : catColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? catColor : catColor.withOpacity(0.2),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Micro Color Dot (3.5px x 3.5px)
                                    Container(
                                      width: 3.5,
                                      height: 3.5,
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.white : catColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      cat.name,
                                      style: AppFonts.mono(
                                        context,
                                        size: 9,
                                        color: isSelected ? Colors.white : catColor,
                                        weight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // 4. Linear / Notion Style Vertical Timeline Spine
                if (entries.isEmpty)
                  _buildEmptyState(context, theme)
                else
                  _buildVerticalSpineTimeline(context, entries, theme),
              ],
            ),
          );
        },
        loading: () => const Center(child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        )),
        error: (err, stack) => Center(child: Text('Error loading timeline: $err')),
      ),
      floatingActionButton: MediaQuery.of(context).size.width <= 880
          ? FloatingActionButton(
              onPressed: () => QuickCapture.show(context),
              backgroundColor: copperColor,
              elevation: 2,
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            )
          : null,
    );
  }

  // --- SLEEK WEEKLY ACTIVITY BAR CHART ---
  Widget _buildWeeklyChartCard(BuildContext context, List<EntryWithCategory> allEntries, ThemeDetails theme) {
    final copperColor = AppColors.getRoleColor('copper', theme.isDark);
    final now = DateTime.now();

    // Determine current week's Monday (Mon=1, Sun=7)
    final currentMonday = now.subtract(Duration(days: now.weekday - 1));
    final weekDays = List.generate(7, (i) {
      final day = currentMonday.add(Duration(days: i));
      return DateTime(day.year, day.month, day.day);
    });

    // Count entries per day of current week
    final Map<String, int> weekCounts = {};
    int thisWeekTotal = 0;

    for (final e in allEntries) {
      final d = e.entry.date;
      final key = DateFormat('yyyy-MM-dd').format(d);
      weekCounts[key] = (weekCounts[key] ?? 0) + 1;
    }

    final List<Map<String, dynamic>> dayData = [];
    int maxCount = 1;

    for (final day in weekDays) {
      final key = DateFormat('yyyy-MM-dd').format(day);
      final count = weekCounts[key] ?? 0;
      thisWeekTotal += count;
      if (count > maxCount) maxCount = count;

      final isToday = day.year == now.year && day.month == now.month && day.day == now.day;
      final dayLabel = DateFormat('EEE').format(day);

      dayData.add({
        'date': day,
        'label': dayLabel,
        'count': count,
        'isToday': isToday,
      });
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: theme.isDark ? Colors.black.withOpacity(0.12) : Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.bar_chart_rounded, size: 15, color: copperColor),
                  const SizedBox(width: 5),
                  Text(
                    'WEEKLY ACTIVITY',
                    style: AppFonts.mono(
                      context,
                      size: 10,
                      color: theme.text,
                      weight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: copperColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$thisWeekTotal logged this week',
                  style: AppFonts.mono(context, size: 9, color: copperColor, weight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 7 Minimalist Bar Columns
          SizedBox(
            height: 72,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: dayData.map((d) {
                final count = d['count'] as int;
                final isToday = d['isToday'] as bool;
                final label = d['label'] as String;
                final double heightRatio = maxCount > 0 ? (count / maxCount) : 0.0;
                final double barHeight = (heightRatio * 32).clamp(4.0, 32.0);

                final barColor = count > 0
                    ? (isToday ? copperColor : copperColor.withOpacity(0.7))
                    : theme.border.withOpacity(0.35);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      count > 0 ? '$count' : '',
                      style: AppFonts.mono(
                        context,
                        size: 9,
                        color: isToday ? copperColor : theme.textMuted,
                        weight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: isToday ? 14 : 10,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(3),
                        border: isToday ? Border.all(color: copperColor, width: 1) : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: AppFonts.mono(
                        context,
                        size: 9,
                        color: isToday ? copperColor : theme.textMuted,
                        weight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // --- LINEAR / NOTION STYLE VERTICAL SPINE TIMELINE ---
  Widget _buildVerticalSpineTimeline(
    BuildContext context,
    List<EntryWithCategory> entries,
    ThemeDetails theme,
  ) {
    // Group entries by Date (YYYY-MM-DD) preserving DESC order
    final Map<String, List<EntryWithCategory>> grouped = {};
    for (final item in entries) {
      final dateKey = DateFormat('yyyy-MM-dd').format(item.entry.date);
      grouped.putIfAbsent(dateKey, () => []).add(item);
    }

    final dayKeys = grouped.keys.toList();
    final copperColor = AppColors.getRoleColor('copper', theme.isDark);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dayKeys.length,
      itemBuilder: (context, dayIndex) {
        final dateKey = dayKeys[dayIndex];
        final dayEntries = grouped[dateKey]!;
        final firstDate = dayEntries.first.entry.date;

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final entryDay = DateTime(firstDate.year, firstDate.month, firstDate.day);
        final diff = today.difference(entryDay).inDays;

        // Consistent & Minimalist Date Formatting (TODAY · AUG 6 / YESTERDAY · AUG 5 / AUG 3, 2026)
        String dateLabel;
        if (diff == 0) {
          dateLabel = 'TODAY · ${DateFormat('MMM d').format(firstDate).toUpperCase()}';
        } else if (diff == 1) {
          dateLabel = 'YESTERDAY · ${DateFormat('MMM d').format(firstDate).toUpperCase()}';
        } else {
          dateLabel = DateFormat('MMM d, yyyy').format(firstDate).toUpperCase();
        }

        final isLastGroup = dayIndex == dayKeys.length - 1;

        return Stack(
          children: [
            // Vertical Spine Thread Line (Precisely Centered at x = 11.0px)
            Positioned(
              left: 10.25,
              top: 11,
              bottom: isLastGroup ? 0 : 0,
              child: Container(
                width: 1.5,
                color: theme.border.withOpacity(0.5),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Minimalist Date Node Header Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Date Node Micro Dot on Thread
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        child: Container(
                          width: diff == 0 ? 10 : 8,
                          height: diff == 0 ? 10 : 8,
                          decoration: BoxDecoration(
                            color: diff == 0 ? copperColor : theme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: diff == 0 ? copperColor : theme.border,
                              width: diff == 0 ? 2 : 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Consistent Minimalist Date Label
                      Text(
                        dateLabel,
                        style: AppFonts.mono(
                          context,
                          size: 10,
                          color: diff == 0 ? copperColor : theme.textMuted,
                          weight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Count Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: theme.isDark
                              ? AppColors.darkSurface2
                              : AppColors.lightBorder.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${dayEntries.length}',
                          style: AppFonts.mono(
                            context,
                            size: 9,
                            color: theme.textMuted,
                            weight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // List of Entries under this Date Node
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: dayEntries.asMap().entries.map((entryItem) {
                        final idx = entryItem.key;
                        final item = entryItem.value;
                        final entry = item.entry;
                        final category = item.category;
                        final db = ref.read(databaseProvider);
                        final catColor = AppColors.getRoleColor(category.role, theme.isDark);

                        return Container(
                          margin: EdgeInsets.only(bottom: idx == dayEntries.length - 1 ? 0 : 8),
                          decoration: BoxDecoration(
                            color: theme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.border.withOpacity(0.4), width: 0.5),
                          ),
                          child: InkWell(
                            onTap: () => QuickCapture.show(context, existingEntry: entry),
                            onLongPress: () => _confirmDeleteEntry(context, db, entry),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Focus Category Badge Pill with Micro Dot (4px)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: catColor.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: catColor.withOpacity(0.2), width: 0.7),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 4,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color: catColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              category.name.toUpperCase(),
                                              style: AppFonts.mono(
                                                context,
                                                size: 9,
                                                color: catColor,
                                                weight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // Description Text
                                      Expanded(
                                        child: Text(
                                          entry.description,
                                          style: AppFonts.ui(
                                            context,
                                            size: 13,
                                            color: theme.text,
                                            weight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Optional Notes (if present)
                                  if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 2),
                                      child: Text(
                                        entry.notes!,
                                        style: AppFonts.ui(
                                          context,
                                          size: 12,
                                          color: theme.textMuted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteEntry(BuildContext context, AppDatabase db, Entrie entry) {
    showDialog(
      context: context,
      builder: (ctx) {
        final t = ThemeProvider.of(ctx);
        final roseColor = AppColors.getRoleColor('rose', t.isDark);
        return AlertDialog(
          backgroundColor: t.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Delete Entry?', style: AppFonts.heading(ctx, size: 15)),
          content: Text(
            'Are you sure you want to remove this log entry?',
            style: AppFonts.ui(ctx, size: 13, color: t.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: AppFonts.ui(ctx, color: t.textMuted)),
            ),
            TextButton(
              onPressed: () async {
                await (db.delete(db.entries)..where((e) => e.id.equals(entry.id))).go();
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text('Delete', style: AppFonts.ui(ctx, color: roseColor, weight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeDetails theme) {
    final copperColor = AppColors.getRoleColor('copper', theme.isDark);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.border, width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timeline_rounded, size: 32, color: copperColor),
          const SizedBox(height: 12),
          Text(
            'Your timeline is empty',
            style: AppFonts.heading(context, size: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap Capture or + to log an entry.',
            style: AppFonts.ui(context, size: 13, color: theme.textMuted),
          ),
        ],
      ),
    );
  }
}
