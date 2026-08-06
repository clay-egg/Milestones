import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/state_providers.dart';
import '../widgets/common_widgets.dart';
import '../database/database.dart';

class QuickCapture extends ConsumerStatefulWidget {
  const QuickCapture({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 880) {
      showDialog(
        context: context,
        builder: (context) => const QuickCapture(),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const QuickCapture(),
      );
    }
  }

  @override
  ConsumerState<QuickCapture> createState() => _QuickCaptureState();
}

class _QuickCaptureState extends ConsumerState<QuickCapture> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);
    final db = ref.watch(databaseProvider);

    final isDesktop = MediaQuery.of(context).size.width > 880;
    final copperColor = AppColors.getRoleColor('copper', theme.isDark);

    final formWidget = Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Log Entry', style: AppFonts.heading(context, size: 18)),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                color: theme.textMuted,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Date selector row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date',
                style: AppFonts.ui(context, size: 12, color: theme.textMuted, weight: FontWeight.w600),
              ),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: theme.isDark
                              ? ColorScheme.dark(
                                  primary: copperColor,
                                  surface: theme.surface,
                                )
                              : ColorScheme.light(
                                  primary: copperColor,
                                  surface: theme.surface,
                                ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() {
                      // Preserve time of day if picking date
                      final now = DateTime.now();
                      _selectedDate = DateTime(
                        picked.year,
                        picked.month,
                        picked.day,
                        now.hour,
                        now.minute,
                        now.second,
                      );
                    });
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: copperColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: copperColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 13, color: copperColor),
                      const SizedBox(width: 6),
                      Text(
                        _formatSelectedDate(_selectedDate),
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
              ),
            ],
          ),
          const SizedBox(height: 16),

          // What did you do?
          Text(
            'What did you do?',
            style: AppFonts.ui(context, size: 12, color: theme.textMuted, weight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            autofocus: true,
            style: AppFonts.ui(context, size: 15),
            maxLines: 2,
            minLines: 1,
            decoration: InputDecoration(
              hintText: 'e.g. Ran 5k in the morning',
              hintStyle: AppFonts.ui(context, color: theme.textMuted),
              filled: true,
              fillColor: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: theme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: theme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: copperColor, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please describe what you did';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Focus selector
          Text(
            'Focus',
            style: AppFonts.ui(context, size: 12, color: theme.textMuted, weight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          categoriesAsync.when(
            data: (categories) {
              if (categories.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.border),
                  ),
                  child: Text(
                    'No focuses yet — add one in the Focus tab first.',
                    style: AppFonts.ui(context, size: 13, color: theme.textMuted),
                  ),
                );
              }

              if (!categories.any((c) => c.id == _selectedCategoryId)) {
                _selectedCategoryId = categories.first.id;
              }

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  final isSelected = _selectedCategoryId == cat.id;
                  final roleColor = AppColors.getRoleColor(cat.role, theme.isDark);

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategoryId = cat.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? roleColor : roleColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? roleColor : roleColor.withOpacity(0.25),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : roleColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat.name,
                            style: AppFonts.mono(
                              context,
                              size: 11,
                              color: isSelected ? Colors.white : roleColor,
                              weight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Error: $err'),
          ),
          const SizedBox(height: 20),

          // Notes (optional)
          Text(
            'Notes  (optional)',
            style: AppFonts.ui(context, size: 12, color: theme.textMuted, weight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            style: AppFonts.ui(context, size: 14),
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
              hintText: 'Any additional context or reflections…',
              hintStyle: AppFonts.ui(context, color: theme.textMuted, size: 13),
              filled: true,
              fillColor: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: theme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: theme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: copperColor, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 28),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: copperColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () => _save(db, context),
              child: Text(
                'Save Entry',
                style: AppFonts.ui(context, weight: FontWeight.bold, color: Colors.white, size: 15),
              ),
            ),
          ),
        ],
      ),
    );

    if (isDesktop) {
      return Dialog(
        backgroundColor: theme.surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(28),
          child: formWidget,
        ),
      );
    } else {
      return AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: formWidget,
        ),
      );
    }
  }

  String _formatSelectedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(selectedDay).inDays;

    if (diff == 0) {
      return 'Today, ${DateFormat('MMM d').format(date)}';
    } else if (diff == 1) {
      return 'Yesterday';
    } else if (diff == -1) {
      return 'Tomorrow';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  void _save(AppDatabase db, BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) return;

    try {
      await db.saveQuickCapture(
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategoryId!,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        date: _selectedDate,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Entry saved!', style: AppFonts.ui(context, color: Colors.white)),
            backgroundColor: AppColors.getRoleColor('sage', ThemeProvider.of(context).isDark),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving entry: $e', style: AppFonts.ui(context, color: Colors.white)),
            backgroundColor: AppColors.getRoleColor('rose', ThemeProvider.of(context).isDark),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
