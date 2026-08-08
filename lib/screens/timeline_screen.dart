import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/state_providers.dart';
import '../widgets/common_widgets.dart';
import '../widgets/quick_capture.dart';
import '../widgets/recap_modal.dart';
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
  int _weekOffset = 0; // 0 = Current Week, -1 = Prev Week, etc.

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

          final settingsAsync = ref.watch(settingsProvider);
          final userName = settingsAsync.value?.userName ?? '';

          final hour = DateTime.now().hour;
          String greeting;
          if (hour >= 5 && hour < 12) {
            greeting = 'Good morning';
          } else if (hour >= 12 && hour < 17) {
            greeting = 'Good afternoon';
          } else if (hour >= 17 && hour < 22) {
            greeting = 'Good evening';
          } else {
            greeting = 'Good night';
          }

          final greetingText = (userName.isNotEmpty && userName.toLowerCase() != 'user')
              ? '$greeting, $userName'
              : greeting;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 0. Personalized Greeting Banner
                Text(
                  greetingText,
                  style: AppFonts.heading(context, size: 18),
                ),
                const SizedBox(height: 16),

                // 1. Sleek Weekly Activity Bar Chart with Week Switcher
                _buildWeeklyChartCard(context, allEntries, theme),
                const SizedBox(height: 26),

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
                          color: theme.surface,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: theme.border, width: 0.8),
                          ),
                          onSelected: (val) {
                            setState(() => _selectedMonthKey = val);
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem<String>(
                              value: 'ALL',
                              height: 34,
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              child: Container(
                                height: 32,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: _selectedMonthKey == 'ALL'
                                      ? copperColor.withOpacity(0.12)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.all_inclusive_rounded,
                                          size: 13,
                                          color: _selectedMonthKey == 'ALL' ? copperColor : theme.textMuted,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'All Time',
                                          style: AppFonts.mono(
                                            context,
                                            size: 11,
                                            color: _selectedMonthKey == 'ALL' ? copperColor : theme.text,
                                            weight: _selectedMonthKey == 'ALL' ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_selectedMonthKey == 'ALL')
                                      Icon(Icons.check_rounded, size: 13, color: copperColor),
                                  ],
                                ),
                              ),
                            ),
                            ...sortedMonthKeys.map((mKey) {
                              final dateObj = DateFormat('yyyy-MM').parse(mKey);
                              final monthLabel = DateFormat('MMMM yyyy').format(dateObj);
                              final isSel = _selectedMonthKey == mKey;

                              return PopupMenuItem<String>(
                                value: mKey,
                                height: 34,
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                child: Container(
                                  height: 32,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: isSel ? copperColor.withOpacity(0.12) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_month_rounded,
                                            size: 13,
                                            color: isSel ? copperColor : theme.textMuted,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            monthLabel,
                                            style: AppFonts.mono(
                                              context,
                                              size: 11,
                                              color: isSel ? copperColor : theme.text,
                                              weight: isSel ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (isSel)
                                        Icon(Icons.check_rounded, size: 13, color: copperColor),
                                    ],
                                  ),
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
                const SizedBox(height: 14),

                // 3. Focus Category Filter Chips (Compact Micro Chips)
                categoriesAsync.when(
                  data: (categories) {
                    if (categories.isEmpty) return const SizedBox.shrink();
                    return Container(
                      height: 28,
                      margin: const EdgeInsets.only(bottom: 18),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          // "All" Filter Chip
                          GestureDetector(
                            onTap: () => setState(() => _selectedFilterCategoryId = null),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                              margin: const EdgeInsets.only(right: 6),
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
                                    size: 9.5,
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
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                margin: const EdgeInsets.only(right: 6),
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
                                        size: 9.5,
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
          ? GestureDetector(
              onTap: () => QuickCapture.show(context),
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(21),
                  border: Border.all(color: copperColor.withOpacity(0.4), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: theme.isDark ? Colors.black.withOpacity(0.35) : copperColor.withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 18, color: copperColor),
                    const SizedBox(width: 6),
                    Text(
                      'LOG ENTRY',
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
            )
          : null,
    );
  }

  // --- SLEEK WEEKLY ACTIVITY BAR CHART WITH WEEK SWITCHER ---
  Widget _buildWeeklyChartCard(BuildContext context, List<EntryWithCategory> allEntries, ThemeDetails theme) {
    final copperColor = AppColors.getRoleColor('copper', theme.isDark);
    final now = DateTime.now();

    // Determine target week's Monday based on _weekOffset (0 = Current Week, -1 = Last Week, etc.)
    final currentMonday = now.subtract(Duration(days: now.weekday - 1));
    final targetMonday = currentMonday.add(Duration(days: _weekOffset * 7));
    final targetSunday = targetMonday.add(const Duration(days: 6));

    final weekDays = List.generate(7, (i) {
      final day = targetMonday.add(Duration(days: i));
      return DateTime(day.year, day.month, day.day);
    });

    // Count entries per day
    final Map<String, int> weekCounts = {};
    int weekTotal = 0;

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
      weekTotal += count;
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

    // Label text for badge
    String badgeLabel;
    if (_weekOffset == 0) {
      badgeLabel = '$weekTotal logged this week';
    } else if (_weekOffset == -1) {
      badgeLabel = 'Last week ($weekTotal)';
    } else {
      badgeLabel = '${DateFormat('MMM d').format(targetMonday)} - ${DateFormat('MMM d').format(targetSunday)} ($weekTotal)';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

              // Week Switcher Controls (< Badge >)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Previous Week (<)
                  GestureDetector(
                    onTap: () => setState(() => _weekOffset--),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        size: 18,
                        color: theme.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),

                  // Week Badge / Date Range
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: copperColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badgeLabel,
                      style: AppFonts.mono(context, size: 9, color: copperColor, weight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 2),

                  // Next Week (>)
                  GestureDetector(
                    onTap: _weekOffset < 0 ? () => setState(() => _weekOffset++) : null,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: _weekOffset < 0 ? theme.textMuted : theme.textMuted.withOpacity(0.25),
                      ),
                    ),
                  ),
                ],
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
    final Map<String, List<EntryWithCategory>> groupedByDate = {};
    for (final item in entries) {
      final dateKey = DateFormat('yyyy-MM-dd').format(item.entry.date);
      groupedByDate.putIfAbsent(dateKey, () => []).add(item);
    }

    final dayKeys = groupedByDate.keys.toList();
    final copperColor = AppColors.getRoleColor('copper', theme.isDark);
    final db = ref.read(databaseProvider);

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dayKeys.length,
      itemBuilder: (context, dayIndex) {
        final dateKey = dayKeys[dayIndex];
        final dayEntries = groupedByDate[dateKey]!;
        final firstDate = dayEntries.first.entry.date;

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final entryDay = DateTime(firstDate.year, firstDate.month, firstDate.day);
        final diff = today.difference(entryDay).inDays;

        // Group dayEntries by Focus Category ID so same date + same focus sit in ONE card box!
        final Map<int, List<EntryWithCategory>> catGrouped = {};
        for (final item in dayEntries) {
          catGrouped.putIfAbsent(item.category.id, () => []).add(item);
        }

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
        final categoryGroupsList = catGrouped.values.toList();

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

                  // Cards Grouped by Focus Category (One Card Per Focus Per Day)
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: categoryGroupsList.asMap().entries.map((catGroupItem) {
                        final catIdx = catGroupItem.key;
                        final catEntries = catGroupItem.value;
                        final category = catEntries.first.category;
                        final catColor = AppColors.getRoleColor(category.role, theme.isDark);
                        final isLastCatCard = catIdx == categoryGroupsList.length - 1;

                        return Container(
                          margin: EdgeInsets.only(bottom: isLastCatCard ? 0 : 8),
                          decoration: BoxDecoration(
                            color: theme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.border.withOpacity(0.4), width: 0.5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            child: catEntries.length == 1
                                // --- SINGLE ENTRY: Sleek 1-Row Inline Layout ---
                                ? InkWell(
                                    onTap: () => QuickCapture.show(context, existingEntry: catEntries.first.entry),
                                    onLongPress: () => _confirmDeleteEntry(context, db, catEntries.first.entry),
                                    borderRadius: BorderRadius.circular(6),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Focus Category Badge Pill
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
                                                catEntries.first.entry.description,
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
                                        if (catEntries.first.entry.notes != null && catEntries.first.entry.notes!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 2),
                                            child: Text(
                                              catEntries.first.entry.notes!,
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
                                  )
                                // --- MULTI-ENTRY: Grouped Card with Header Pill & Bullets ---
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Focus Category Header Pill at top of Card Box
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
                                      const SizedBox(height: 6),

                                      // Bulleted Entries List
                                      ...catEntries.asMap().entries.map((eMap) {
                                        final entryIdx = eMap.key;
                                        final item = eMap.value;
                                        final entry = item.entry;
                                        final isLastEntry = entryIdx == catEntries.length - 1;

                                        return InkWell(
                                          onTap: () => QuickCapture.show(context, existingEntry: entry),
                                          onLongPress: () => _confirmDeleteEntry(context, db, entry),
                                          borderRadius: BorderRadius.circular(6),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                                            margin: EdgeInsets.only(bottom: isLastEntry ? 0 : 3),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '• ',
                                                  style: AppFonts.ui(
                                                    context,
                                                    size: 13,
                                                    color: catColor.withOpacity(0.7),
                                                    weight: FontWeight.bold,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        entry.description,
                                                        style: AppFonts.ui(
                                                          context,
                                                          size: 13,
                                                          color: theme.text,
                                                          weight: FontWeight.w500,
                                                        ),
                                                      ),
                                                      if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          entry.notes!,
                                                          style: AppFonts.ui(
                                                            context,
                                                            size: 12,
                                                            color: theme.textMuted,
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ],
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
                await db.deleteEntry(entry.id);
                ref.refresh(todosProvider);
                ref.refresh(timelineEntriesProvider);
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
            'Tap + LOG ENTRY to record your progress.',
            style: AppFonts.ui(context, size: 13, color: theme.textMuted),
          ),
        ],
      ),
    );
  }
}
