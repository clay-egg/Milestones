import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/state_providers.dart';
import '../widgets/common_widgets.dart';
import '../widgets/quick_capture.dart';
import '../database/database.dart';
import 'package:intl/intl.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(timelineEntriesProvider);
    final theme = ThemeProvider.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: entriesAsync.when(
        data: (entries) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Minimalist Weekly Activity Comparison Bar Chart
                _buildWeeklyChartCard(context, entries, theme),
                const SizedBox(height: 18),

                // 2. Timeline Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Timeline', style: AppFonts.heading(context, size: 18)),
                    if (entries.isNotEmpty)
                      Text(
                        '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'} total',
                        style: AppFonts.mono(context, size: 11, color: theme.textMuted),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // 3. Daily Cards or Empty State
                if (entries.isEmpty)
                  _buildEmptyState(context, theme)
                else
                  _buildDailyCards(context, ref, entries, theme),
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
              backgroundColor: AppColors.getRoleColor('copper', theme.isDark),
              elevation: 2,
              mini: false,
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            )
          : null,
    );
  }

  // --- MINIMALIST WEEKLY ACTIVITY BAR CHART ---
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.bar_chart_rounded, size: 18, color: copperColor),
                  const SizedBox(width: 6),
                  Text('Weekly Activity', style: AppFonts.heading(context, size: 15)),
                ],
              ),
              Text(
                '$thisWeekTotal logged this week',
                style: AppFonts.mono(context, size: 10, color: copperColor, weight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 7 Minimalist Bar Columns
          SizedBox(
            height: 75,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: dayData.map((d) {
                final count = d['count'] as int;
                final isToday = d['isToday'] as bool;
                final label = d['label'] as String;
                final double heightRatio = maxCount > 0 ? (count / maxCount) : 0.0;
                final double barHeight = (heightRatio * 42).clamp(4.0, 42.0);

                final barColor = count > 0
                    ? (isToday ? copperColor : copperColor.withOpacity(0.7))
                    : theme.border.withOpacity(0.4);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Count on top
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

                    // Bar Graphic
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: isToday ? 16 : 12,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(4),
                        border: isToday ? Border.all(color: copperColor, width: 1) : null,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Day Label
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

  // --- DAILY GROUPED CARDS ---
  Widget _buildDailyCards(
    BuildContext context,
    WidgetRef ref,
    List<EntryWithCategory> entries,
    ThemeDetails theme,
  ) {
    final Map<String, List<EntryWithCategory>> grouped = {};
    for (final item in entries) {
      final dateKey = DateFormat('yyyy-MM-dd').format(item.entry.date);
      grouped.putIfAbsent(dateKey, () => []).add(item);
    }

    final dayKeys = grouped.keys.toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dayKeys.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final dateKey = dayKeys[index];
        final dayEntries = grouped[dateKey]!;
        final firstDate = dayEntries.first.entry.date;

        return _buildSingleDailyCard(context, ref, firstDate, dayEntries, theme);
      },
    );
  }

  Widget _buildSingleDailyCard(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
    List<EntryWithCategory> dayEntries,
    ThemeDetails theme,
  ) {
    final db = ref.read(databaseProvider);
    final copperColor = AppColors.getRoleColor('copper', theme.isDark);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(entryDay).inDays;

    String dateTitle;
    if (diff == 0) {
      dateTitle = 'Today, ${DateFormat('MMM d').format(date)}';
    } else if (diff == 1) {
      dateTitle = 'Yesterday, ${DateFormat('MMM d').format(date)}';
    } else {
      dateTitle = DateFormat('EEEE, MMM d, yyyy').format(date);
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: diff == 0 ? copperColor.withOpacity(0.35) : theme.border,
          width: diff == 0 ? 1 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header (Compact Date + Count)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: diff == 0
                  ? copperColor.withOpacity(0.06)
                  : (theme.isDark ? AppColors.darkSurface2.withOpacity(0.4) : AppColors.lightBg),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      diff == 0 ? Icons.today_rounded : Icons.calendar_today_rounded,
                      size: 14,
                      color: diff == 0 ? copperColor : theme.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateTitle,
                      style: AppFonts.heading(context, size: 14),
                    ),
                  ],
                ),
                Text(
                  '${dayEntries.length} ${dayEntries.length == 1 ? 'entry' : 'entries'}',
                  style: AppFonts.mono(
                    context,
                    size: 10,
                    color: theme.textMuted,
                    weight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),

          // Minimalist Compact List of Entries
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dayEntries.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              thickness: 0.5,
              indent: 14,
              endIndent: 14,
              color: theme.border.withOpacity(0.4),
            ),
            itemBuilder: (context, idx) {
              final item = dayEntries[idx];
              final entry = item.entry;
              final category = item.category;
              final catColor = AppColors.getRoleColor(category.role, theme.isDark);

              return Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Small Category Pill Dot Badge
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: catColor.withOpacity(0.25), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(color: catColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            category.name,
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
                    const SizedBox(width: 10),

                    // Description & Notes
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.description,
                            style: AppFonts.ui(context, size: 14, color: theme.text),
                          ),
                          if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              entry.notes!,
                              style: AppFonts.ui(context, size: 12, color: theme.textMuted),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Compact Delete button
                    InkWell(
                      onTap: () => _confirmDeleteEntry(context, db, entry),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(Icons.close_rounded, size: 14, color: theme.textMuted),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
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
