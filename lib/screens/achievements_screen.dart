import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/state_providers.dart';
import '../widgets/common_widgets.dart';
import '../database/database.dart';
import 'package:intl/intl.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  final _achievedController = TextEditingController();
  final _challengesController = TextEditingController();
  final _nextMonthController = TextEditingController();
  String _currentMonthYear = '';
  bool _controllersInitialized = false;

  @override
  void dispose() {
    _achievedController.dispose();
    _challengesController.dispose();
    _nextMonthController.dispose();
    super.dispose();
  }

  void _saveReflections(AppDatabase db) {
    if (_currentMonthYear.isEmpty) return;
    db.updateReflection(
      _currentMonthYear,
      achieved: _achievedController.text.trim(),
      challenges: _challengesController.text.trim(),
      nextMonth: _nextMonthController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final entriesAsync = ref.watch(timelineEntriesProvider);
    final reflectionsAsync = ref.watch(reflectionsProvider);
    final milestonesAsync = ref.watch(milestonesProvider);
    final summariesAsync = ref.watch(summariesProvider);
    final projectsAsync = ref.watch(projectsProvider);
    final db = ref.watch(databaseProvider);

    // Get current month
    final now = DateTime.now();
    _currentMonthYear = DateFormat('yyyy-MM').format(now);
    final currentMonthLabel = DateFormat('MMMM yyyy').format(now);

    // Initialize text controllers with current month reflection once loaded
    reflectionsAsync.whenData((reflections) {
      if (!_controllersInitialized) {
        final currentRef = reflections.firstWhere(
          (r) => r.monthYear == _currentMonthYear,
          orElse: () => Reflection(id: -1, monthYear: _currentMonthYear, achieved: '', challenges: '', nextMonth: ''),
        );
        _achievedController.text = currentRef.achieved;
        _challengesController.text = currentRef.challenges;
        _nextMonthController.text = currentRef.nextMonth;
        _controllersInitialized = true;
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Layout builder for responsiveness
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 880;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAchievementsSection(context, entriesAsync),
                              const SizedBox(height: 32),
                              _buildReflectionsSection(context, db, currentMonthLabel),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 2,
                          child: _buildFutureMeSection(context, db, milestonesAsync, summariesAsync, entriesAsync, projectsAsync),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAchievementsSection(context, entriesAsync),
                        const SizedBox(height: 32),
                        _buildReflectionsSection(context, db, currentMonthLabel),
                        const SizedBox(height: 32),
                        _buildFutureMeSection(context, db, milestonesAsync, summariesAsync, entriesAsync, projectsAsync),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 1. BADGE GRID SECTION ---
  Widget _buildAchievementsSection(BuildContext context, AsyncValue<List<EntryWithCategory>> entriesAsync) {
    final theme = ThemeProvider.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Milestone Wins', style: AppFonts.heading(context, size: 18)),
        const SizedBox(height: 12),
        entriesAsync.when(
          data: (entries) {
            final achievements = entries.where((e) => e.category.role == 'achievement').toList();
            if (achievements.isEmpty) {
              return Text('No achievements logged yet. Capture wins with "achievement" role category.', style: AppFonts.ui(context, color: theme.textMuted));
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                childAspectRatio: 1.3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final item = achievements[index];
                return MilestoneCard(
                  role: 'gold',
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.stars, color: Color(0xffdda63f), size: 24),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          item.entry.description,
                          style: AppFonts.ui(context, size: 12, weight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        DateFormat('MMM d, yyyy').format(item.entry.date),
                        style: AppFonts.mono(context, size: 10, color: theme.textMuted),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => Text('Error: $err'),
        ),
      ],
    );
  }

  // --- 2. REFLECTIONS SECTION ---
  Widget _buildReflectionsSection(BuildContext context, AppDatabase db, String currentMonthLabel) {
    final theme = ThemeProvider.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Monthly Reflections', style: AppFonts.heading(context, size: 18)),
        const SizedBox(height: 12),
        MilestoneCard(
          role: 'neutral',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentMonthLabel,
                    style: AppFonts.ui(context, size: 15, weight: FontWeight.bold),
                  ),
                  Icon(Icons.rate_review_outlined, color: theme.textMuted, size: 20),
                ],
              ),
              const SizedBox(height: 16),
              _buildReflectionField(
                context,
                'What was achieved:',
                _achievedController,
                'Reflect on your successes...',
                () => _saveReflections(db),
              ),
              const SizedBox(height: 12),
              _buildReflectionField(
                context,
                'Key challenges faced:',
                _challengesController,
                'What was difficult or held you back...',
                () => _saveReflections(db),
              ),
              const SizedBox(height: 12),
              _buildReflectionField(
                context,
                'Plans for next month:',
                _nextMonthController,
                'Set direction for the upcoming weeks...',
                () => _saveReflections(db),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReflectionField(
    BuildContext context,
    String label,
    TextEditingController controller,
    String hint,
    VoidCallback onSave,
  ) {
    final theme = ThemeProvider.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFonts.ui(context, size: 12, color: theme.textMuted, weight: FontWeight.bold)),
        const SizedBox(height: 4),
        Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus) {
              onSave();
            }
          },
          child: TextField(
            controller: controller,
            maxLines: null,
            style: AppFonts.ui(context, size: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppFonts.ui(context, size: 13, color: theme.textMuted),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              filled: true,
              fillColor: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: theme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: theme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: AppColors.getRoleColor('sage', theme.isDark)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- 3. FUTURE ME SECTION ---
  Widget _buildFutureMeSection(
    BuildContext context,
    AppDatabase db,
    AsyncValue<List<Milestone>> milestonesAsync,
    AsyncValue<List<Summarie>> summariesAsync,
    AsyncValue<List<EntryWithCategory>> entriesAsync,
    AsyncValue<List<Project>> projectsAsync,
  ) {
    final theme = ThemeProvider.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Future Me', style: AppFonts.heading(context, size: 18)),
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: AppColors.getRoleColor('plum', theme.isDark)),
              onPressed: () => _showAddMilestoneDialog(context, db),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Milestone list
        milestonesAsync.when(
          data: (milestones) {
            if (milestones.isEmpty) {
              return Text('No future milestones added.', style: AppFonts.ui(context, color: theme.textMuted));
            }
            return Column(
              children: milestones.map((m) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.surface,
                  border: Border.all(color: theme.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.getRoleColor('plum', theme.isDark).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${m.year}',
                        style: AppFonts.mono(context, size: 11, color: AppColors.getRoleColor('plum', theme.isDark), weight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(m.label, style: AppFonts.ui(context, size: 13))),
                    IconButton(
                      icon: Icon(Icons.close, size: 16, color: theme.textMuted),
                      onPressed: () => db.deleteMilestone(m.id),
                    ),
                  ],
                ),
              )).toList(),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => Text('Error: $err'),
        ),
        
        const SizedBox(height: 20),
        
        // Generate summary button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.getRoleColor('plum', theme.isDark),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => _generateThisYearsSummary(db, entriesAsync.value ?? [], projectsAsync.value ?? []),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, size: 18),
              const SizedBox(width: 8),
              Text('Write this year\'s summary', style: AppFonts.ui(context, weight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Past summaries list
        Text('Annual Summaries', style: AppFonts.ui(context, size: 14, weight: FontWeight.bold)),
        const SizedBox(height: 8),
        summariesAsync.when(
          data: (summaries) {
            if (summaries.isEmpty) {
              return Text('No summaries compiled yet. Tap above to generate one.', style: AppFonts.ui(context, size: 12, color: theme.textMuted));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: summaries.length,
              itemBuilder: (context, index) {
                final s = summaries[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${s.year} Summary', style: AppFonts.ui(context, size: 13, weight: FontWeight.bold)),
                          Text(
                            DateFormat('MMM d, yyyy').format(s.dateCreated),
                            style: AppFonts.mono(context, size: 10, color: theme.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(s.content, style: AppFonts.ui(context, size: 13, color: theme.text)),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => Text('Error: $err'),
        ),
      ],
    );
  }

  void _showAddMilestoneDialog(BuildContext context, AppDatabase db) {
    final yearController = TextEditingController(text: DateTime.now().year.toString());
    final labelController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final theme = ThemeProvider.of(context);
        return AlertDialog(
          backgroundColor: theme.surface,
          title: Text('New Future Milestone', style: AppFonts.heading(context, size: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: yearController,
                keyboardType: TextInputType.number,
                style: AppFonts.ui(context),
                decoration: InputDecoration(
                  labelText: 'Target Year',
                  labelStyle: AppFonts.ui(context, color: theme.textMuted),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.border)),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: labelController,
                autofocus: true,
                style: AppFonts.ui(context),
                decoration: InputDecoration(
                  labelText: 'Milestone Goal',
                  labelStyle: AppFonts.ui(context, color: theme.textMuted),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.border)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppFonts.ui(context, color: theme.textMuted)),
            ),
            TextButton(
              onPressed: () async {
                final year = int.tryParse(yearController.text.trim()) ?? DateTime.now().year;
                final label = labelController.text.trim();
                if (label.isNotEmpty) {
                  await db.createMilestone(year, label);
                  Navigator.pop(context);
                }
              },
              child: Text('Add', style: AppFonts.ui(context, color: AppColors.getRoleColor('plum', theme.isDark), weight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _generateThisYearsSummary(AppDatabase db, List<EntryWithCategory> entries, List<Project> projects) async {
    final year = DateTime.now().year;
    
    // Filter this year's entries
    final thisYearsEntries = entries.where((e) => e.entry.date.year == year).toList();
    final totalWins = thisYearsEntries.length;
    final learningHours = thisYearsEntries.where((e) => e.category.role == 'learning').length;
    final milestones = thisYearsEntries.where((e) => e.category.role == 'achievement').length;
    final projectsCount = projects.length;

    final content = 'In $year, you successfully recorded $totalWins wins on your growth timeline. '
        'You dedicated approximately $learningHours hours to active learning and registered $milestones major achievements. '
        'Additionally, you managed $projectsCount personal projects and stayed committed to tracking your milestones. '
        'Keep up the dedication to continuous growth!';

    await db.createSummary(year, content);
    
    // Trigger toast using overlay to avoid ScaffoldMessenger dependency in a dialog/sheet context
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Generated summary for $year', style: AppFonts.ui(context, color: Colors.white)),
          backgroundColor: AppColors.getRoleColor('sage', ThemeProvider.of(context).isDark),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
