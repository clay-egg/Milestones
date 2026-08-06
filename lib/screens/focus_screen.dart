import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/state_providers.dart';
import '../widgets/common_widgets.dart';
import '../database/database.dart';

class FocusScreen extends ConsumerWidget {
  const FocusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ThemeProvider.of(context);
    final projectsAsync = ref.watch(projectsProvider);
    final skillsAsync = ref.watch(skillsProvider);
    final goalsAsync = ref.watch(goalsProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final db = ref.watch(databaseProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Responsive Layout Breakpoint for Grid (Multi-column on wide screens)
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
                              _buildProjectsSection(context, db, projectsAsync),
                              const SizedBox(height: 32),
                              _buildGoalsSection(context, db, goalsAsync, settingsAsync),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 2,
                          child: _buildSkillsSection(context, db, skillsAsync),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProjectsSection(context, db, projectsAsync),
                        const SizedBox(height: 32),
                        _buildSkillsSection(context, db, skillsAsync),
                        const SizedBox(height: 32),
                        _buildGoalsSection(context, db, goalsAsync, settingsAsync),
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

  // --- PROJECTS SECTION ---
  Widget _buildProjectsSection(BuildContext context, AppDatabase db, AsyncValue<List<Project>> projectsAsync) {
    final theme = ThemeProvider.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Projects', style: AppFonts.heading(context, size: 18)),
            TextButton.icon(
              onPressed: () => _showAddProjectDialog(context, db),
              icon: Icon(Icons.add, color: AppColors.getRoleColor('sage', theme.isDark)),
              label: Text(
                '+ New project',
                style: AppFonts.ui(context, color: AppColors.getRoleColor('sage', theme.isDark), weight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        projectsAsync.when(
          data: (projects) {
            if (projects.isEmpty) {
              return Text('No active projects. Create one above.', style: AppFonts.ui(context, color: theme.textMuted));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProjectCardWidget(project: project, db: db),
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

  void _showAddProjectDialog(BuildContext context, AppDatabase db) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final theme = ThemeProvider.of(context);
        return AlertDialog(
          backgroundColor: theme.surface,
          title: Text('New Project', style: AppFonts.heading(context, size: 18)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: AppFonts.ui(context),
            decoration: InputDecoration(
              hintText: 'Project Name',
              hintStyle: AppFonts.ui(context, color: theme.textMuted),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.border)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.getRoleColor('sage', theme.isDark))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppFonts.ui(context, color: theme.textMuted)),
            ),
            TextButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  await db.createProject(name);
                  Navigator.pop(context);
                }
              },
              child: Text('Create', style: AppFonts.ui(context, color: AppColors.getRoleColor('sage', theme.isDark), weight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // --- SKILLS SECTION ---
  Widget _buildSkillsSection(BuildContext context, AppDatabase db, AsyncValue<List<Skill>> skillsAsync) {
    final theme = ThemeProvider.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Skills', style: AppFonts.heading(context, size: 18)),
            TextButton.icon(
              onPressed: () => _showAddSkillDialog(context, db),
              icon: Icon(Icons.add, color: AppColors.getRoleColor('copper', theme.isDark)),
              label: Text(
                '+ add a skill',
                style: AppFonts.ui(context, color: AppColors.getRoleColor('copper', theme.isDark), weight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        skillsAsync.when(
          data: (skills) {
            if (skills.isEmpty) {
              return Text('No skills tracked yet.', style: AppFonts.ui(context, color: theme.textMuted));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: skills.length,
              itemBuilder: (context, index) {
                final skill = skills[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SkillCardWidget(skill: skill, db: db),
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

  void _showAddSkillDialog(BuildContext context, AppDatabase db) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final theme = ThemeProvider.of(context);
        return AlertDialog(
          backgroundColor: theme.surface,
          title: Text('Add Skill', style: AppFonts.heading(context, size: 18)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: AppFonts.ui(context),
            decoration: InputDecoration(
              hintText: 'Skill Name (e.g. Design, German)',
              hintStyle: AppFonts.ui(context, color: theme.textMuted),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.border)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.getRoleColor('copper', theme.isDark))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppFonts.ui(context, color: theme.textMuted)),
            ),
            TextButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  await db.createSkill(name);
                  Navigator.pop(context);
                }
              },
              child: Text('Add', style: AppFonts.ui(context, color: AppColors.getRoleColor('copper', theme.isDark), weight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // --- GOALS SECTION ---
  Widget _buildGoalsSection(
    BuildContext context,
    AppDatabase db,
    AsyncValue<List<Goal>> goalsAsync,
    AsyncValue<UserSetting> settingsAsync,
  ) {
    final theme = ThemeProvider.of(context);
    final stages = settingsAsync.value?.stagesJson.split(',') ?? ['Idea', 'Research', 'Prototype', 'Launch'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Goals', style: AppFonts.heading(context, size: 18)),
            TextButton.icon(
              onPressed: () => _showAddGoalDialog(context, db, stages),
              icon: Icon(Icons.add, color: AppColors.getRoleColor('plum', theme.isDark)),
              label: Text(
                '+ New goal',
                style: AppFonts.ui(context, color: AppColors.getRoleColor('plum', theme.isDark), weight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        goalsAsync.when(
          data: (goals) {
            // Stage stat row generated dynamically (cumulative count)
            final stageCounts = <String, int>{};
            for (int i = 0; i < stages.length; i++) {
              final stage = stages[i];
              stageCounts[stage] = goals.where((g) {
                final gIdx = stages.indexOf(g.currentStage);
                return gIdx >= i;
              }).length;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dynamic Stage Stat Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: stages.map((stage) {
                      final count = stageCounts[stage] ?? 0;
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 120,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.surface,
                          border: Border.all(color: theme.border),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stage,
                              style: AppFonts.ui(context, size: 11, color: theme.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$count',
                              style: AppFonts.heading(context, size: 24, color: AppColors.getRoleColor('plum', theme.isDark), weight: FontWeight.w500),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                if (goals.isEmpty)
                  Text('No active goals.', style: AppFonts.ui(context, color: theme.textMuted))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      final goal = goals[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MilestoneCard(
                          role: 'plum',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(goal.name, style: AppFonts.ui(context, size: 15, weight: FontWeight.w600)),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Target: ${goal.targetStage}',
                                          style: AppFonts.mono(context, size: 10, color: theme.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  RoleBadge(text: goal.currentStage, role: 'plum', isSmall: true),
                                ],
                              ),
                              _buildGoalStageTrack(context, goal, stages),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStageNudge(context, db, goal, stages),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline, size: 18, color: AppColors.getRoleColor('destructive', theme.isDark)),
                                    onPressed: () => db.deleteGoal(goal.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => Text('Error: $err'),
        ),
      ],
    );
  }

  Widget _buildGoalStageTrack(BuildContext context, Goal goal, List<String> stages) {
    final theme = ThemeProvider.of(context);
    final plumColor = AppColors.getRoleColor('plum', theme.isDark);
    final currentIndex = stages.indexOf(goal.currentStage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        // Segmented Track
        Row(
          children: List.generate(stages.length, (idx) {
            final isCompleted = idx <= currentIndex;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.only(
                  right: idx == stages.length - 1 ? 0 : 4,
                ),
                height: 5,
                decoration: BoxDecoration(
                  color: isCompleted ? plumColor : (theme.isDark ? AppColors.darkSurface2 : AppColors.lightBorder.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        // Stage Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: stages.map((st) {
            final isCurrent = st == goal.currentStage;
            return Text(
              st,
              style: AppFonts.mono(
                context,
                size: 8,
                color: isCurrent ? plumColor : theme.textMuted,
              ).copyWith(
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStageNudge(BuildContext context, AppDatabase db, Goal goal, List<String> stages) {
    final theme = ThemeProvider.of(context);
    final currentIndex = stages.indexOf(goal.currentStage);
    final nextIndex = currentIndex + 1;
    final prevIndex = currentIndex - 1;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prevIndex >= 0)
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: () => db.updateGoalStage(goal.id, stages[prevIndex]),
          ),
        if (nextIndex < stages.length)
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: () => db.updateGoalStage(goal.id, stages[nextIndex]),
          ),
      ],
    );
  }

  void _showAddGoalDialog(BuildContext context, AppDatabase db, List<String> stages) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final theme = ThemeProvider.of(context);
        return AlertDialog(
          backgroundColor: theme.surface,
          title: Text('New Goal', style: AppFonts.heading(context, size: 18)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: AppFonts.ui(context),
            decoration: InputDecoration(
              hintText: 'Goal description (e.g. Run 10k)',
              hintStyle: AppFonts.ui(context, color: theme.textMuted),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.border)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.getRoleColor('plum', theme.isDark))),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppFonts.ui(context, color: theme.textMuted)),
            ),
            TextButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  final first = stages.isNotEmpty ? stages.first : 'Idea';
                  final last = stages.isNotEmpty ? stages.last : 'Launch';
                  await db.createGoal(name, first, last);
                  Navigator.pop(context);
                }
              },
              child: Text('Track', style: AppFonts.ui(context, color: AppColors.getRoleColor('plum', theme.isDark), weight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

// Custom Stateful Expandable Card Widget for Projects
class ProjectCardWidget extends StatefulWidget {
  final Project project;
  final AppDatabase db;

  const ProjectCardWidget({Key? key, required this.project, required this.db}) : super(key: key);

  @override
  State<ProjectCardWidget> createState() => _ProjectCardWidgetState();
}

class _ProjectCardWidgetState extends State<ProjectCardWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final steps = jsonDecode(widget.project.stepsJson) as List;
    final achievements = jsonDecode(widget.project.achievementsJson) as List;
    
    final completedSteps = steps.where((s) => s['completed'] == true).length;
    final progress = steps.isEmpty ? 0.0 : completedSteps / steps.length;

    return MilestoneCard(
      role: 'sage',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.project.name, style: AppFonts.ui(context, size: 16, weight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      '$completedSteps of ${steps.length} steps completed',
                      style: AppFonts.mono(context, size: 11, color: theme.textMuted),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 22),
                onPressed: () => setState(() => _expanded = !_expanded),
              ),
            ],
          ),
          
          // Progress bar
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (context, val, _) {
                return LinearProgressIndicator(
                  value: val,
                  backgroundColor: theme.border,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.getRoleColor('sage', theme.isDark)),
                  minHeight: 6,
                );
              },
            ),
          ),
          
          if (_expanded) ...[
            const Divider(height: 24, thickness: 1),
            
            // Steps Journey
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Journey Steps', style: AppFonts.ui(context, size: 13, weight: FontWeight.w600)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  onPressed: () => _addStepDialog(),
                ),
              ],
            ),
            if (steps.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('No steps added yet. Add a step or log via Quick Capture.', style: AppFonts.ui(context, size: 12, color: theme.textMuted)),
              ),
            ...steps.asMap().entries.map((entry) {
              final idx = entry.key;
              final val = entry.value;
              return Row(
                children: [
                  Checkbox(
                    activeColor: AppColors.getRoleColor('sage', theme.isDark),
                    checkColor: theme.bg,
                    value: val['completed'] == true,
                    onChanged: (bool? checked) {
                      steps[idx]['completed'] = checked ?? false;
                      widget.db.updateProjectSteps(widget.project.id, steps);
                    },
                  ),
                  Expanded(
                    child: Text(
                      val['title'] ?? '',
                      style: AppFonts.ui(
                        context,
                        size: 13,
                        color: val['completed'] == true ? theme.textMuted : theme.text,
                        weight: val['completed'] == true ? FontWeight.normal : FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 16, color: theme.textMuted),
                    onPressed: () {
                      steps.removeAt(idx);
                      widget.db.updateProjectSteps(widget.project.id, steps);
                    },
                  ),
                ],
              );
            }).toList(),

            const SizedBox(height: 12),
            // Achievements checklist
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Achievements Checklist', style: AppFonts.ui(context, size: 13, weight: FontWeight.w600)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  onPressed: () => _addAchievementDialog(),
                ),
              ],
            ),
            if (achievements.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('No achievements listed yet.', style: AppFonts.ui(context, size: 12, color: theme.textMuted)),
              ),
            ...achievements.asMap().entries.map((entry) {
              final idx = entry.key;
              final val = entry.value;
              return Row(
                children: [
                  Checkbox(
                    activeColor: AppColors.getRoleColor('gold', theme.isDark),
                    checkColor: theme.bg,
                    value: val['completed'] == true,
                    onChanged: (bool? checked) {
                      achievements[idx]['completed'] = checked ?? false;
                      widget.db.updateProjectAchievements(widget.project.id, achievements);
                    },
                  ),
                  Expanded(
                    child: Text(
                      val['title'] ?? '',
                      style: AppFonts.ui(
                        context,
                        size: 13,
                        color: val['completed'] == true ? theme.textMuted : theme.text,
                        weight: val['completed'] == true ? FontWeight.normal : FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 16, color: theme.textMuted),
                    onPressed: () {
                      achievements.removeAt(idx);
                      widget.db.updateProjectAchievements(widget.project.id, achievements);
                    },
                  ),
                ],
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  void _addStepDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final theme = ThemeProvider.of(context);
        return AlertDialog(
          backgroundColor: theme.surface,
          title: Text('Add Step', style: AppFonts.ui(context, weight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: AppFonts.ui(context),
            decoration: InputDecoration(
              hintText: 'Step name',
              hintStyle: AppFonts.ui(context, color: theme.textMuted),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppFonts.ui(context, color: theme.textMuted)),
            ),
            TextButton(
              onPressed: () {
                final txt = controller.text.trim();
                if (txt.isNotEmpty) {
                  final steps = jsonDecode(widget.project.stepsJson) as List;
                  steps.add({'title': txt, 'completed': false});
                  widget.db.updateProjectSteps(widget.project.id, steps);
                  Navigator.pop(context);
                }
              },
              child: Text('Add', style: AppFonts.ui(context, color: AppColors.getRoleColor('sage', theme.isDark))),
            ),
          ],
        );
      },
    );
  }

  void _addAchievementDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final theme = ThemeProvider.of(context);
        return AlertDialog(
          backgroundColor: theme.surface,
          title: Text('Add Achievement Requirement', style: AppFonts.ui(context, weight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: AppFonts.ui(context),
            decoration: InputDecoration(
              hintText: 'Requirement description',
              hintStyle: AppFonts.ui(context, color: theme.textMuted),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppFonts.ui(context, color: theme.textMuted)),
            ),
            TextButton(
              onPressed: () {
                final txt = controller.text.trim();
                if (txt.isNotEmpty) {
                  final achievements = jsonDecode(widget.project.achievementsJson) as List;
                  achievements.add({'title': txt, 'completed': false});
                  widget.db.updateProjectAchievements(widget.project.id, achievements);
                  Navigator.pop(context);
                }
              },
              child: Text('Add', style: AppFonts.ui(context, color: AppColors.getRoleColor('gold', theme.isDark))),
            ),
          ],
        );
      },
    );
  }
}

// Custom Stateful Skill Widget with nudges
class SkillCardWidget extends StatelessWidget {
  final Skill skill;
  final AppDatabase db;

  const SkillCardWidget({Key? key, required this.skill, required this.db}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final evidence = jsonDecode(skill.evidenceJson) as List;

    return MilestoneCard(
      role: 'copper',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(skill.name, style: AppFonts.ui(context, size: 16, weight: FontWeight.bold)),
              Text(
                '${skill.progressPercent.round()}%',
                style: AppFonts.mono(context, size: 13, color: AppColors.getRoleColor('copper', theme.isDark), weight: FontWeight.bold),
              ),
            ],
          ),
          
          // Manual Nudge slider row
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 18),
                onPressed: () {
                  final val = (skill.progressPercent - 10.0).clamp(0.0, 100.0);
                  db.updateSkillProgress(skill.id, val);
                },
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: skill.progressPercent / 100.0),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    builder: (context, val, _) {
                      return LinearProgressIndicator(
                        value: val,
                        backgroundColor: theme.border,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.getRoleColor('copper', theme.isDark)),
                        minHeight: 6,
                      );
                    },
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 18),
                onPressed: () {
                  final val = (skill.progressPercent + 10.0).clamp(0.0, 100.0);
                  db.updateSkillProgress(skill.id, val);
                },
              ),
            ],
          ),
          
          // Evidence bullets
          if (evidence.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Evidence:', style: AppFonts.ui(context, size: 12, color: theme.textMuted, weight: FontWeight.w600)),
            const SizedBox(height: 4),
            ...evidence.map((bullet) => Padding(
                  padding: const EdgeInsets.only(left: 6, bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ', style: AppFonts.ui(context, size: 12, color: theme.textMuted)),
                      Expanded(
                        child: Text(
                          bullet.toString(),
                          style: AppFonts.ui(context, size: 12, color: theme.textMuted),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
