import 'dart:convert';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/state_providers.dart';
import '../widgets/common_widgets.dart';
import '../database/database.dart';
import '../services/notification_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  bool _profileInitialized = false;
  bool? _reminderEnabledState;
  String? _reminderTimeState;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveProfile(AppDatabase db, UserSetting settings) {
    db.updateSettings(
      userName: _nameController.text.trim(),
      isDarkMode: settings.isDarkMode,
      stagesJson: settings.stagesJson,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final settingsAsync = ref.watch(settingsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final db = ref.watch(databaseProvider);

    settingsAsync.whenData((settings) {
      if (!_profileInitialized) {
        _nameController.text = settings.userName;
        _profileInitialized = true;
      }
    });

    return Scaffold(
      backgroundColor: theme.bg,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              Text('Settings', style: AppFonts.heading(context, size: 18)),
              const SizedBox(height: 16),

              settingsAsync.when(
                data: (settings) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Appearance Section
                      _buildThemeSection(context, db, settings),
                      const SizedBox(height: 16),

                      // 2. Daily Reminders Section
                      _buildNotificationSection(context, db, settings),
                      const SizedBox(height: 16),

                      // 3. Profile Section
                      _buildProfileSection(context, db, settings),
                      const SizedBox(height: 16),

                      // 4. Category Management Section
                      _buildCategoriesSection(context, db, categoriesAsync),
                      const SizedBox(height: 16),

                      // 5. Data Backup & Restore Section
                      _buildDataBackupSection(context, db, settings),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                error: (err, stack) => Center(
                  child: Text('Error loading settings', style: AppFonts.ui(context, color: theme.textMuted)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- THEME TOGGLE SECTION ---
  Widget _buildThemeSection(BuildContext context, AppDatabase db, UserSetting settings) {
    final theme = ThemeProvider.of(context);
    final sageColor = AppColors.getRoleColor('sage', theme.isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.border, width: 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Theme Mode', style: AppFonts.ui(context, size: 14, weight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(
                settings.isDarkMode ? 'Dark' : 'Light',
                style: AppFonts.mono(context, size: 11, color: theme.textMuted),
              ),
            ],
          ),
          Switch(
            value: settings.isDarkMode,
            activeColor: sageColor,
            onChanged: (val) {
              db.updateSettings(
                userName: settings.userName,
                isDarkMode: val,
                stagesJson: settings.stagesJson,
              );
            },
          ),
        ],
      ),
    );
  }

  // --- DAILY REMINDER NOTIFICATIONS SECTION ---
  Widget _buildNotificationSection(BuildContext context, AppDatabase db, UserSetting settings) {
    final theme = ThemeProvider.of(context);
    final sageColor = AppColors.getRoleColor('sage', theme.isDark);
    final copperColor = AppColors.getRoleColor('copper', theme.isDark);

    return StatefulBuilder(
      builder: (context, setLocalState) {
        final isEnabled = _reminderEnabledState ?? settings.isReminderEnabled;
        final currentTime = _reminderTimeState ?? settings.reminderTime;

        final timeParts = currentTime.split(':');
        final hour = timeParts.isNotEmpty ? int.tryParse(timeParts[0]) ?? 20 : 20;
        final minute = timeParts.length > 1 ? int.tryParse(timeParts[1]) ?? 0 : 0;
        final timeOfDay = TimeOfDay(hour: hour, minute: minute);
        final formattedTime = timeOfDay.format(context);

        final presetTimes = [
          {'label': '8 AM', 'val': '08:00'},
          {'label': '12 PM', 'val': '12:00'},
          {'label': '6 PM', 'val': '18:00'},
          {'label': '8 PM', 'val': '20:00'},
          {'label': '10 PM', 'val': '22:00'},
        ];

        return Container(
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily Reminder', style: AppFonts.ui(context, size: 14, weight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          isEnabled ? 'Remind daily at $formattedTime' : 'Disabled',
                          key: ValueKey('${isEnabled}_$formattedTime'),
                          style: AppFonts.mono(context, size: 11, color: theme.textMuted),
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: isEnabled,
                    activeColor: sageColor,
                    onChanged: (val) {
                      setLocalState(() {
                        _reminderEnabledState = val;
                      });
                      setState(() {
                        _reminderEnabledState = val;
                      });

                      db.updateSettings(
                        userName: settings.userName,
                        isDarkMode: settings.isDarkMode,
                        stagesJson: settings.stagesJson,
                        isReminderEnabled: val,
                        reminderTime: currentTime,
                      ).then((_) => ref.refresh(settingsProvider));

                      // Schedule or cancel the OS-level daily notification
                      if (val) {
                        final parts = currentTime.split(':');
                        final h = int.tryParse(parts[0]) ?? 20;
                        final m = int.tryParse(parts[1]) ?? 0;
                        NotificationService().scheduleDailyReminder(h, m);
                      } else {
                        NotificationService().cancelDailyReminder();
                      }
                    },
                  ),
                ],
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 220),
                crossFadeState: isEnabled ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                firstChild: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            ...presetTimes.map((pt) {
                              final isSelected = currentTime == pt['val'];
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () {
                                    setLocalState(() {
                                      _reminderTimeState = pt['val'];
                                    });
                                    setState(() {
                                      _reminderTimeState = pt['val'];
                                    });

                                    db.updateSettings(
                                      userName: settings.userName,
                                      isDarkMode: settings.isDarkMode,
                                      stagesJson: settings.stagesJson,
                                      isReminderEnabled: true,
                                      reminderTime: pt['val'],
                                    ).then((_) => ref.refresh(settingsProvider));

                                    // Reschedule daily reminder at new time
                                    final parts = (pt['val'] ?? '20:00').split(':');
                                    final h = int.tryParse(parts[0]) ?? 20;
                                    final m = int.tryParse(parts[1]) ?? 0;
                                    NotificationService().scheduleDailyReminder(h, m);
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? copperColor.withOpacity(0.18)
                                          : (theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isSelected ? copperColor : theme.border,
                                        width: isSelected ? 1.2 : 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      pt['label']!,
                                      style: AppFonts.mono(
                                        context,
                                        size: 11,
                                        color: isSelected ? copperColor : theme.textMuted,
                                        weight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                            InkWell(
                              onTap: () async {
                                final picked = await showThemedTimePicker(
                                  context: context,
                                  initialTime: timeOfDay,
                                );
                                if (picked != null) {
                                  final h = picked.hour.toString().padLeft(2, '0');
                                  final m = picked.minute.toString().padLeft(2, '0');
                                  final newTimeStr = '$h:$m';
                                  setLocalState(() {
                                    _reminderTimeState = newTimeStr;
                                  });
                                  setState(() {
                                    _reminderTimeState = newTimeStr;
                                  });

                                  await db.updateSettings(
                                    userName: settings.userName,
                                    isDarkMode: settings.isDarkMode,
                                    stagesJson: settings.stagesJson,
                                    isReminderEnabled: true,
                                    reminderTime: newTimeStr,
                                  );
                                  ref.refresh(settingsProvider);

                                  // Reschedule daily reminder at new custom time
                                  NotificationService().scheduleDailyReminder(picked.hour, picked.minute);
                                }
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: theme.border, width: 0.8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.access_time_rounded, size: 12, color: theme.textMuted),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Custom',
                                      style: AppFonts.mono(context, size: 11, color: theme.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          InkWell(
                            onTap: () async {
                              final success = await NotificationService().showTestNotification();
                              if (mounted) {
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.notifications_active_rounded, color: copperColor, size: 18),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            success
                                                ? '🔔 Native Notification Sent! Check Notification Center.'
                                                : '🔔 Daily Reminder: Time to log progress!',
                                            style: AppFonts.ui(context, color: theme.text, weight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: theme.surface,
                                    elevation: 6,
                                    duration: const Duration(seconds: 4),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(color: copperColor, width: 1.2),
                                    ),
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: copperColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: copperColor.withOpacity(0.3), width: 0.8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.notifications_none_rounded, size: 13, color: copperColor),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Test Now',
                                    style: AppFonts.mono(context, size: 11, color: copperColor, weight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () async {
                              await NotificationService().showScheduledNotification(seconds: 5);
                              if (mounted) {
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.timer_rounded, color: copperColor, size: 18),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            '⏳ Scheduled in 5s! Go to Home Screen to watch banner pop up.',
                                            style: AppFonts.ui(context, color: theme.text, weight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: theme.surface,
                                    elevation: 6,
                                    duration: const Duration(seconds: 5),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(color: copperColor, width: 1.2),
                                    ),
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: theme.border, width: 0.8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.timer_outlined, size: 13, color: theme.textMuted),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Test 5s Delay',
                                    style: AppFonts.mono(context, size: 11, color: theme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                secondChild: const SizedBox(width: double.infinity),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- PROFILE SECTION ---
  Widget _buildProfileSection(BuildContext context, AppDatabase db, UserSetting settings) {
    final theme = ThemeProvider.of(context);
    final sageColor = AppColors.getRoleColor('sage', theme.isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile', style: AppFonts.ui(context, size: 14, weight: FontWeight.bold)),
          const SizedBox(height: 12),
          Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) {
                _saveProfile(db, settings);
              }
            },
            child: TextField(
              controller: _nameController,
              style: AppFonts.ui(context, size: 13.5),
              decoration: InputDecoration(
                labelText: 'User Name',
                labelStyle: AppFonts.ui(context, size: 12, color: theme.textMuted),
                filled: true,
                fillColor: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.border, width: 0.8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.border, width: 0.8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: sageColor, width: 1.2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CATEGORIES MANAGER SECTION ---
  Widget _buildCategoriesSection(
    BuildContext context,
    AppDatabase db,
    AsyncValue<List<Categorie>> categoriesAsync,
  ) {
    final theme = ThemeProvider.of(context);
    final sageColor = AppColors.getRoleColor('sage', theme.isDark);

    return Container(
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
              Text('Categories', style: AppFonts.ui(context, size: 14, weight: FontWeight.bold)),
              GestureDetector(
                onTap: () => _showAddCategoryDialog(context, db),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: sageColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: sageColor.withValues(alpha: 0.35), width: 0.8),
                  ),
                  child: Text(
                    '+ Category',
                    style: AppFonts.mono(context, size: 10.5, color: sageColor, weight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          categoriesAsync.when(
            data: (categories) {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.border, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        RoleBadge(text: cat.name, role: cat.role, isSmall: true),
                        const Spacer(),
                        InkWell(
                          onTap: () => _showRenameCategoryDialog(context, db, cat),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(Icons.edit_outlined, size: 15, color: theme.textMuted),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: categories.length > 1
                              ? () => db.deleteCategory(cat.id)
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Must keep at least 1 category.')),
                                  );
                                },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.delete_outline,
                              size: 15,
                              color: AppColors.getRoleColor('destructive', theme.isDark),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const SizedBox(
              height: 40,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (err, stack) => Text('Error: $err', style: AppFonts.ui(context, size: 12, color: theme.textMuted)),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, AppDatabase db) {
    final nameController = TextEditingController();
    String selectedRole = 'learning';

    showDialog(
      context: context,
      builder: (context) {
        final theme = ThemeProvider.of(context);
        final sageColor = AppColors.getRoleColor('sage', theme.isDark);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: theme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text('Add Category', style: AppFonts.heading(context, size: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    style: AppFonts.ui(context, size: 13.5),
                    decoration: InputDecoration(
                      hintText: 'Category Name',
                      hintStyle: AppFonts.ui(context, size: 12.5, color: theme.textMuted),
                      filled: true,
                      fillColor: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.border, width: 0.8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.border, width: 0.8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: sageColor, width: 1.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'ROLE COLOR',
                    style: AppFonts.mono(context, size: 9, color: theme.textMuted, weight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    dropdownColor: theme.surface,
                    style: AppFonts.ui(context, size: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.border, width: 0.8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'learning', child: Text('Learning (Copper)')),
                      DropdownMenuItem(value: 'achievement', child: Text('Achievement (Gold)')),
                      DropdownMenuItem(value: 'goal', child: Text('Goal (Plum)')),
                      DropdownMenuItem(value: 'neutral', child: Text('Neutral (Sage)')),
                      DropdownMenuItem(value: 'destructive', child: Text('Destructive (Rose)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedRole = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: AppFonts.ui(context, color: theme.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sageColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      await db.addCategory(name, selectedRole);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: Text('Add', style: AppFonts.ui(context, color: Colors.black, weight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- DATA BACKUP & RESTORE SECTION ---
  Widget _buildDataBackupSection(BuildContext context, AppDatabase db, UserSetting settings) {
    final theme = ThemeProvider.of(context);
    final copperColor = AppColors.getRoleColor('copper', theme.isDark);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Data Backup & Restore', style: AppFonts.ui(context, size: 14, weight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            'Export your timeline entries, habit logs, and categories as JSON backup.',
            style: AppFonts.ui(context, size: 11.5, color: theme.textMuted),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.border, width: 0.8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    'Export Backup',
                    style: AppFonts.mono(context, size: 11, color: theme.text, weight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    final entries = await db.select(db.entries).get();
                    final todos = await db.getTodos();
                    final categories = await db.select(db.categories).get();

                    final Map<int, Categorie> categoryMap = {for (var c in categories) c.id: c};

                    final backupData = {
                      'appName': 'Milestones',
                      'version': '1.0',
                      'exportedAt': DateTime.now().toIso8601String(),
                      'userName': settings.userName,
                      'categories': categories.map((c) => {
                        'id': c.id,
                        'name': c.name,
                        'role': c.role,
                        'weeklyTarget': c.weeklyTarget,
                      }).toList(),
                      'entries': entries.map((e) => {
                        'description': e.description,
                        'categoryId': e.categoryId,
                        'categoryName': categoryMap[e.categoryId]?.name ?? '',
                        'notes': e.notes,
                        'date': e.date.toIso8601String(),
                      }).toList(),
                      'todos': todos.map((t) => {
                        'title': t.title,
                        'isCompleted': t.isCompleted,
                        'categoryId': t.categoryId,
                        'categoryName': categoryMap[t.categoryId]?.name ?? '',
                        'dateCreated': t.dateCreated.toIso8601String(),
                        'dateCompleted': t.dateCompleted?.toIso8601String(),
                      }).toList(),
                    };

                    final jsonStr = const JsonEncoder.withIndent('  ').convert(backupData);
                    Clipboard.setData(ClipboardData(text: jsonStr));

                    if (context.mounted) {
                      final sageColor = AppColors.getRoleColor('sage', theme.isDark);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Full backup JSON copied to clipboard!', style: AppFonts.ui(context, color: theme.text, weight: FontWeight.w600)),
                          backgroundColor: theme.surface,
                          elevation: 4,
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: sageColor, width: 1.0),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.border, width: 0.8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    'Import / Restore',
                    style: AppFonts.mono(context, size: 11, color: theme.text, weight: FontWeight.bold),
                  ),
                  onPressed: () => _showImportDialog(context, db),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.redAccent.withOpacity(0.5), width: 0.8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(
                'Clear All Data',
                style: AppFonts.mono(context, size: 11, color: Colors.redAccent, weight: FontWeight.bold),
              ),
              onPressed: () => _showClearDataDialog(context, db),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, AppDatabase db) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = ThemeProvider.of(context);
        return AlertDialog(
          backgroundColor: theme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Clear All Data', style: AppFonts.heading(context, size: 16, color: Colors.redAccent)),
          content: Text(
            'Are you sure you want to delete all timeline entries, tasks, and focus categories? This action cannot be undone.',
            style: AppFonts.ui(context, size: 12.5, color: theme.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppFonts.ui(context, color: theme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () async {
                await (db.delete(db.entries)).go();
                await db.customStatement('DELETE FROM todos;');
                await (db.delete(db.categories)).go();

                // Seed initial default category
                await db.into(db.categories).insert(CategoriesCompanion.insert(
                  name: 'General',
                  role: 'learning',
                ));

                ref.refresh(categoriesProvider);
                ref.refresh(timelineEntriesProvider);
                ref.refresh(todosProvider);

                if (context.mounted) {
                  final roseColor = AppColors.getRoleColor('rose', theme.isDark);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('All data cleared successfully.', style: AppFonts.ui(context, color: theme.text, weight: FontWeight.w600)),
                      backgroundColor: theme.surface,
                      elevation: 4,
                      duration: const Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: roseColor, width: 1.0),
                      ),
                    ),
                  );
                }
              },
              child: Text('Delete All', style: AppFonts.ui(context, color: Colors.white, weight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showImportDialog(BuildContext context, AppDatabase db) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final theme = ThemeProvider.of(context);
        final sageColor = AppColors.getRoleColor('sage', theme.isDark);

        return AlertDialog(
          backgroundColor: theme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Import / Restore Backup', style: AppFonts.heading(context, size: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paste your JSON backup text below to restore your timeline logs and tasks:',
                style: AppFonts.ui(context, size: 12, color: theme.textMuted),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                maxLines: 6,
                style: AppFonts.mono(context, size: 11),
                decoration: InputDecoration(
                  hintText: 'Paste backup JSON here...',
                  hintStyle: AppFonts.mono(context, size: 11, color: theme.textMuted),
                  filled: true,
                  fillColor: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.border, width: 0.8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppFonts.ui(context, color: theme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: sageColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () async {
                final rawText = controller.text.trim();
                if (rawText.isEmpty) return;

                try {
                  final data = jsonDecode(rawText) as Map<String, dynamic>;

                  final Map<int, int> oldToNewCatIdMap = {};
                  final Map<String, int> catNameToIdMap = {};

                  // 1. Restore Categories & build ID map
                  if (data.containsKey('categories')) {
                    final categoriesList = data['categories'] as List<dynamic>;
                    for (final item in categoriesList) {
                      final map = item as Map<String, dynamic>;
                      final oldId = (map['id'] as num?)?.toInt();
                      final name = map['name'] as String? ?? '';
                      final role = map['role'] as String? ?? 'learning';
                      final weeklyTarget = (map['weeklyTarget'] as num?)?.toInt() ?? 0;
                      if (name.isNotEmpty) {
                        final existing = await (db.select(db.categories)..where((c) => c.name.equals(name))).getSingleOrNull();
                        int newId;
                        if (existing != null) {
                          newId = existing.id;
                          await (db.update(db.categories)..where((c) => c.id.equals(newId))).write(
                            CategoriesCompanion(
                              role: Value(role),
                              weeklyTarget: Value(weeklyTarget),
                            ),
                          );
                        } else {
                          newId = await db.into(db.categories).insert(CategoriesCompanion.insert(
                            name: name,
                            role: role,
                            weeklyTarget: Value(weeklyTarget),
                          ));
                        }
                        if (oldId != null) oldToNewCatIdMap[oldId] = newId;
                        catNameToIdMap[name] = newId;
                      }
                    }
                  }

                  // Fetch current category mapping fallback
                  final allCurrentCats = await db.select(db.categories).get();
                  for (final c in allCurrentCats) {
                    catNameToIdMap.putIfAbsent(c.name, () => c.id);
                  }
                  final defaultCatId = allCurrentCats.isNotEmpty ? allCurrentCats.first.id : 1;

                  int resolveCatId(int oldCatId, String catName) {
                    if (oldToNewCatIdMap.containsKey(oldCatId)) {
                      return oldToNewCatIdMap[oldCatId]!;
                    }
                    if (catNameToIdMap.containsKey(catName)) {
                      return catNameToIdMap[catName]!;
                    }
                    return defaultCatId;
                  }

                  // 2. Restore Entries with mapped Category ID
                  if (data.containsKey('entries')) {
                    final entriesList = data['entries'] as List<dynamic>;
                    for (final item in entriesList) {
                      final map = item as Map<String, dynamic>;
                      final desc = map['description'] as String? ?? '';
                      final oldCatId = (map['categoryId'] as num?)?.toInt() ?? 1;
                      final catName = map['categoryName'] as String? ?? '';
                      final notes = map['notes'] as String?;
                      final date = DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now();

                      final targetCatId = resolveCatId(oldCatId, catName);
                      await db.saveQuickCapture(
                        description: desc,
                        categoryId: targetCatId,
                        notes: notes,
                        date: date,
                      );
                    }
                  }

                  // 3. Restore Todos with mapped Category ID
                  if (data.containsKey('todos')) {
                    final todosList = data['todos'] as List<dynamic>;
                    for (final item in todosList) {
                      final map = item as Map<String, dynamic>;
                      final title = map['title'] as String? ?? '';
                      final oldCatId = (map['categoryId'] as num?)?.toInt() ?? 1;
                      final catName = map['categoryName'] as String? ?? '';
                      final dateCreated = DateTime.tryParse(map['dateCreated'] as String? ?? '') ?? DateTime.now();

                      final targetCatId = resolveCatId(oldCatId, catName);
                      await db.addTodo(title, targetCatId, dateCreated: dateCreated);
                    }
                  }

                  ref.refresh(categoriesProvider);
                  ref.refresh(timelineEntriesProvider);
                  ref.refresh(todosProvider);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Backup data successfully restored!', style: AppFonts.ui(context, color: theme.text, weight: FontWeight.w600)),
                        backgroundColor: theme.surface,
                        elevation: 4,
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: sageColor, width: 1.0),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    final roseColor = AppColors.getRoleColor('rose', theme.isDark);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Invalid JSON backup format.', style: AppFonts.ui(context, color: theme.text, weight: FontWeight.w600)),
                        backgroundColor: theme.surface,
                        elevation: 4,
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: roseColor, width: 1.0),
                        ),
                      ),
                    );
                  }
                }
              },
              child: Text('Restore', style: AppFonts.ui(context, color: Colors.black, weight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showRenameCategoryDialog(BuildContext context, AppDatabase db, Categorie cat) {
    final controller = TextEditingController(text: cat.name);
    showDialog(
      context: context,
      builder: (context) {
        final theme = ThemeProvider.of(context);
        final sageColor = AppColors.getRoleColor('sage', theme.isDark);

        return AlertDialog(
          backgroundColor: theme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Rename Category', style: AppFonts.heading(context, size: 16)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: AppFonts.ui(context, size: 13.5),
            decoration: InputDecoration(
              hintText: 'New Name',
              hintStyle: AppFonts.ui(context, size: 12.5, color: theme.textMuted),
              filled: true,
              fillColor: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.border, width: 0.8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppFonts.ui(context, color: theme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: sageColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  await db.renameCategory(cat.id, newName);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: Text('Save', style: AppFonts.ui(context, color: Colors.black, weight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
