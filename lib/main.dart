import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database/database.dart';
import 'providers/state_providers.dart';
import 'widgets/common_widgets.dart';
import 'screens/timeline_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/recap_screen.dart';
import 'screens/focus_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/quick_capture.dart';

import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;
  runApp(
    const ProviderScope(
      child: MilestoneApp(),
    ),
  );
}

class MilestoneApp extends ConsumerWidget {
  const MilestoneApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      data: (settings) {
        final isDark = settings.isDarkMode;
        final theme = isDark ? ThemeDetails.dark() : ThemeDetails.light();

        return ThemeProvider(
          theme: theme,
          child: MaterialApp(
            title: 'Milestones',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: isDark ? Brightness.dark : Brightness.light,
              primaryColor: AppColors.getRoleColor('copper', isDark),
              scaffoldBackgroundColor: theme.bg,
              canvasColor: theme.surface,
              cardColor: theme.surface,
              dialogBackgroundColor: theme.surface,
              popupMenuTheme: PopupMenuThemeData(
                color: theme.surface,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
                menuPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: theme.border, width: 0.8),
                ),
              ),
            ),
            home: const AppShell(),
          ),
        );
      },
      loading: () => const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (err, stack) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error loading settings: $err'),
          ),
        ),
      ),
    );
  }
}

class AppShell extends ConsumerWidget {
  const AppShell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIndex = ref.watch(navigationIndexProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final theme = ThemeProvider.of(context);

    final List<Widget> pages = const [
      TimelineScreen(),
      TasksScreen(),
      RecapScreen(),
      FocusScreen(),
      AchievementsScreen(),
      SettingsScreen(),
    ];

    final pageIcons = const [
      Icons.history_rounded,
      Icons.check_box_outlined,
      Icons.auto_graph_rounded,
      Icons.center_focus_strong_rounded,
      Icons.military_tech_rounded,
      Icons.tune_rounded,
    ];
    final pageSubtitles = const [
      'Timeline',
      'To-Do',
      'Recap & Insights',
      'Focus',
      'Wins & Streaks',
      'Settings',
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 880;

            if (isWide) {
              return Row(
                children: [
                  // Wide Mode: Sidebar Navigation
                  _buildSidebar(context, ref, activeIndex, settingsAsync),
                  
                  // Hairline divider
                  Container(
                    width: 1,
                    color: theme.border,
                  ),
                  
                  // Content Pane
                  Expanded(
                    child: SafeArea(
                      child: pages[activeIndex],
                    ),
                  ),
                ],
              );
            } else {
              // Narrow Mode: Top Bar + Bottom Navigation
              return Column(
                children: [
                  _buildTopBar(context, pageSubtitles[activeIndex], pageIcons[activeIndex]),
                  Container(height: 0.5, color: theme.border),
                  Expanded(
                    child: pages[activeIndex],
                  ),
                ],
              );
            }
          },
        ),
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width <= 880
          ? _buildBottomNavBar(context, ref, activeIndex)
          : null,
    );
  }

  Widget _buildTopBar(BuildContext context, String subtitle, IconData pageIcon) {
    final theme = ThemeProvider.of(context);
    final copperColor = AppColors.getRoleColor('copper', theme.isDark);
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      color: theme.surface,
      padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: copperColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: copperColor.withValues(alpha: 0.3), width: 1),
                ),
                child: Icon(Icons.timeline_rounded, size: 18, color: copperColor),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Milestones',
                    style: AppFonts.heading(context, size: 17),
                  ),
                  Row(
                    children: [
                      Icon(pageIcon, size: 10, color: copperColor),
                      const SizedBox(width: 3),
                      Text(
                        subtitle,
                        style: AppFonts.mono(context, size: 9, color: copperColor),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- BOTTOM NAV BAR FOR MOBILE ---
  Widget _buildBottomNavBar(BuildContext context, WidgetRef ref, int activeIndex) {
    final theme = ThemeProvider.of(context);
    final activeColor = AppColors.getRoleColor('copper', theme.isDark);

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(top: BorderSide(color: theme.border, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: activeIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: activeColor,
          unselectedItemColor: theme.textMuted,
          selectedLabelStyle: AppFonts.mono(context, size: 10, weight: FontWeight.bold),
          unselectedLabelStyle: AppFonts.mono(context, size: 10),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'Timeline',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_box_outlined),
              label: 'To-Do',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_graph_rounded),
              label: 'Recap',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.center_focus_strong_rounded),
              label: 'Focus',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.military_tech_rounded),
              label: 'Wins',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tune_rounded),
              label: 'Settings',
            ),
          ],
          onTap: (index) {
            ref.read(navigationIndexProvider.notifier).state = index;
          },
        ),
      ),
    );
  }

  // --- SIDEBAR FOR DESKTOP ---
  Widget _buildSidebar(
    BuildContext context,
    WidgetRef ref,
    int activeIndex,
    AsyncValue<UserSetting> settingsAsync,
  ) {
    final theme = ThemeProvider.of(context);
    final settings = settingsAsync.value;
    final userName = settings?.userName ?? 'Explorer';

    return Container(
      width: 240,
      color: theme.surface,
      child: SafeArea(
        right: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.getRoleColor('copper', theme.isDark).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: AppColors.getRoleColor('copper', theme.isDark).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.timeline_rounded,
                      size: 16,
                      color: AppColors.getRoleColor('copper', theme.isDark),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Milestones',
                    style: AppFonts.heading(context, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.getRoleColor('copper', theme.isDark).withValues(alpha: 0.2),
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: AppFonts.heading(
                        context,
                        size: 16,
                        color: AppColors.getRoleColor('copper', theme.isDark),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: AppFonts.heading(context, size: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Personal Growth',
                          style: AppFonts.mono(context, size: 9.5, color: theme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Navigation Menu Options
              SidebarNavItem(
                label: 'Timeline',
                icon: Icons.history_rounded,
                isSelected: activeIndex == 0,
                onTap: () => ref.read(navigationIndexProvider.notifier).state = 0,
              ),
              const SizedBox(height: 6),
              SidebarNavItem(
                label: 'To-Do',
                icon: Icons.check_box_outlined,
                isSelected: activeIndex == 1,
                onTap: () => ref.read(navigationIndexProvider.notifier).state = 1,
              ),
              const SizedBox(height: 6),
              SidebarNavItem(
                label: 'Recap & Insights',
                icon: Icons.auto_graph_rounded,
                isSelected: activeIndex == 2,
                onTap: () => ref.read(navigationIndexProvider.notifier).state = 2,
              ),
              const SizedBox(height: 6),
              SidebarNavItem(
                label: 'Focus Area',
                icon: Icons.center_focus_strong_rounded,
                isSelected: activeIndex == 3,
                onTap: () => ref.read(navigationIndexProvider.notifier).state = 3,
              ),
              const SizedBox(height: 6),
              SidebarNavItem(
                label: 'Wins & Streaks',
                icon: Icons.military_tech_rounded,
                isSelected: activeIndex == 4,
                onTap: () => ref.read(navigationIndexProvider.notifier).state = 4,
              ),
              const SizedBox(height: 6),
              SidebarNavItem(
                label: 'Settings',
                icon: Icons.tune_rounded,
                isSelected: activeIndex == 5,
                onTap: () => ref.read(navigationIndexProvider.notifier).state = 5,
              ),
              
              const Spacer(),
              
              // Quick Capture Trigger Button
              GestureDetector(
                onTap: () => QuickCapture.show(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.getRoleColor('copper', theme.isDark),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_rounded, size: 18, color: Colors.black),
                      const SizedBox(width: 6),
                      Text(
                        'Quick Log',
                        style: AppFonts.ui(
                          context,
                          size: 13,
                          color: Colors.black,
                          weight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
