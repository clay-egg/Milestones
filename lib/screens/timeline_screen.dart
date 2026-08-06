import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/state_providers.dart';
import '../widgets/common_widgets.dart';
import '../widgets/quick_capture.dart';
import '../database/database.dart';
import 'package:intl/intl.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({Key? key}) : super(key: key);

  int _calculateStreak(List<EntryWithCategory> entries) {
    if (entries.isEmpty) return 0;
    final dates = entries
        .map((e) => DateTime(e.entry.date.year, e.entry.date.month, e.entry.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (!dates.contains(today) && !dates.contains(yesterday)) {
      return 0;
    }

    int streak = 0;
    DateTime checkDate = dates.contains(today) ? today : yesterday;

    while (dates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(timelineEntriesProvider);
    final projectsAsync = ref.watch(projectsProvider);
    final goalsAsync = ref.watch(goalsProvider);
    final theme = ThemeProvider.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: entriesAsync.when(
        data: (entries) {
          final projectsCount = projectsAsync.value?.length ?? 0;
          final goalsCount = goalsAsync.value?.length ?? 0;
          
          // Calculate stats
          final streak = _calculateStreak(entries);
          final learningHours = entries.where((e) => e.category.role == 'learning').length;
          final achievementsCount = entries.where((e) => e.category.role == 'achievement').length;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stat Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatCard(context, 'Streak', '$streak days', 'neutral'),
                      const SizedBox(width: 12),
                      _buildStatCard(context, 'Projects', '$projectsCount active', 'sage'),
                      const SizedBox(width: 12),
                      _buildStatCard(context, 'Learning', '$learningHours hours', 'copper'),
                      const SizedBox(width: 12),
                      _buildStatCard(context, 'Goals', '$goalsCount tracked', 'plum'),
                      const SizedBox(width: 12),
                      _buildStatCard(context, 'Wins', '$achievementsCount logged', 'gold'),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                
                // Entries Feed Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Activity Feed',
                      style: AppFonts.heading(context, size: 18),
                    ),
                    // Only show inline capture trigger for desktop wide layout when FAB is not available
                    if (MediaQuery.of(context).size.width > 880)
                      TextButton.icon(
                        onPressed: () => QuickCapture.show(context),
                        icon: Icon(Icons.add_rounded, color: AppColors.getRoleColor('copper', theme.isDark)),
                        label: Text(
                          'Quick Capture',
                          style: AppFonts.ui(context, color: AppColors.getRoleColor('copper', theme.isDark), weight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Entries Feed
                Expanded(
                  child: entries.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_stories_outlined, size: 48, color: theme.textMuted),
                              const SizedBox(height: 12),
                              Text(
                                'No entries recorded yet.',
                                style: AppFonts.ui(context, color: theme.textMuted),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Use Quick Capture to record your first win!',
                                style: AppFonts.ui(context, color: theme.textMuted, size: 12),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final entryWithCat = entries[index];
                            final entry = entryWithCat.entry;
                            final category = entryWithCat.category;
                            
                            // Grouping dates visually
                            final dateStr = DateFormat('MMMM d, yyyy').format(entry.date);
                            final showHeader = index == 0 ||
                                DateFormat('yyyy-MM-dd').format(entries[index - 1].entry.date) !=
                                    DateFormat('yyyy-MM-dd').format(entry.date);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showHeader) ...[
                                  if (index > 0) const SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
                                    child: Text(
                                      dateStr,
                                      style: AppFonts.heading(context, size: 14, color: theme.textMuted),
                                    ),
                                  ),
                                ],
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: MilestoneCard(
                                    role: category.role,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                entry.description,
                                                style: AppFonts.ui(context, size: 15, color: theme.text),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              DateFormat('h:mm a').format(entry.date),
                                              style: AppFonts.mono(context, size: 11, color: theme.textMuted),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            RoleBadge(text: category.name, role: category.role, isSmall: true),
                                            if (entry.project != null) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBorder.withOpacity(0.3),
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(color: theme.border, width: 0.5),
                                                ),
                                                child: Text(
                                                  '→ ${entry.project}',
                                                  style: AppFonts.mono(
                                                    context,
                                                    size: 10,
                                                    color: theme.text,
                                                    weight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                            if (entry.tags.isNotEmpty) ...[
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: SingleChildScrollView(
                                                  scrollDirection: Axis.horizontal,
                                                  child: Row(
                                                    children: entry.tags.split(',').map((t) {
                                                      return Padding(
                                                        padding: const EdgeInsets.only(right: 6),
                                                        child: Text(
                                                          '#$t',
                                                          style: AppFonts.mono(
                                                            context,
                                                            size: 11,
                                                            color: theme.textMuted,
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading feed: $err')),
      ),
      floatingActionButton: MediaQuery.of(context).size.width <= 880
          ? FloatingActionButton(
              onPressed: () => QuickCapture.show(context),
              backgroundColor: AppColors.getRoleColor('copper', theme.isDark),
              elevation: 4,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            )
          : null,
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, String role) {
    final theme = ThemeProvider.of(context);
    final color = AppColors.getRoleColor(role, theme.isDark);

    return Container(
      width: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppFonts.ui(context, size: 11, color: theme.textMuted).copyWith(
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppFonts.heading(context, size: 24, color: color, weight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
