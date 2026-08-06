import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final _projectController = TextEditingController();
  final _tagInputController = TextEditingController();
  
  int? _selectedCategoryId;
  final List<String> _tags = [];
  List<String> _projectSuggestions = [];
  bool _showSuggestions = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _projectController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);
    final projectsAsync = ref.watch(projectsProvider);
    final db = ref.watch(databaseProvider);
    
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 880;

    // Filter project suggestions based on user input
    final allProjects = projectsAsync.value ?? [];
    final inputText = _projectController.text.trim();
    if (inputText.isNotEmpty) {
      _projectSuggestions = allProjects
          .map((p) => p.name)
          .where((name) => name.toLowerCase().contains(inputText.toLowerCase()))
          .toList();
    } else {
      _projectSuggestions = [];
    }

    final formWidget = Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Capture Win',
                style: AppFonts.heading(context, size: 18),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Description (autofocus, required)
          TextFormField(
            controller: _descriptionController,
            autofocus: true,
            style: AppFonts.ui(context),
            decoration: InputDecoration(
              hintText: 'What win did you achieve today?',
              hintStyle: AppFonts.ui(context, color: theme.textMuted),
              filled: true,
              fillColor: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.getRoleColor('copper', theme.isDark))),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Description is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Category Chips Selector (single select, built from live category list)
          Text('Select Category', style: AppFonts.ui(context, size: 12, color: theme.textMuted, weight: FontWeight.bold)),
          const SizedBox(height: 8),
          categoriesAsync.when(
            data: (categories) {
              if (categories.isEmpty) {
                return Text('Create categories in Settings first.', style: AppFonts.ui(context, color: theme.textMuted));
              }
              
              // Set default selection if not already selected
              _selectedCategoryId ??= categories.first.id;

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  final isSelected = _selectedCategoryId == cat.id;
                  final roleColor = AppColors.getRoleColor(cat.role, theme.isDark);
                  
                  return ChoiceChip(
                    label: Text(cat.name),
                    selected: isSelected,
                    labelStyle: AppFonts.mono(
                      context,
                      size: 11,
                      color: isSelected ? Colors.white : roleColor,
                      weight: FontWeight.bold,
                    ),
                    selectedColor: roleColor,
                    backgroundColor: roleColor.withOpacity(0.12),
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: BorderSide(color: isSelected ? roleColor : roleColor.withOpacity(0.3)),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategoryId = cat.id);
                      }
                    },
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Error: $err'),
          ),
          const SizedBox(height: 16),

          // Optional Project Text Field (autocompletes existing)
          Text('Associate Project (Optional)', style: AppFonts.ui(context, size: 12, color: theme.textMuted, weight: FontWeight.bold)),
          const SizedBox(height: 8),
          Stack(
            clipBehavior: Clip.none,
            children: [
              TextFormField(
                controller: _projectController,
                style: AppFonts.ui(context),
                decoration: InputDecoration(
                  hintText: 'e.g. Flutter App, French Study',
                  hintStyle: AppFonts.ui(context, color: theme.textMuted),
                  filled: true,
                  fillColor: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.border)),
                ),
                onChanged: (text) {
                  setState(() {
                    _showSuggestions = text.trim().isNotEmpty && _projectSuggestions.isNotEmpty;
                  });
                },
              ),
              if (_showSuggestions && _projectSuggestions.isNotEmpty)
                Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Material(
                    elevation: 4,
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(maxHeight: 120),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _projectSuggestions.length,
                        itemBuilder: (context, idx) {
                          final suggestion = _projectSuggestions[idx];
                          return ListTile(
                            dense: true,
                            title: Text(suggestion, style: AppFonts.ui(context)),
                            onTap: () {
                              setState(() {
                                _projectController.text = suggestion;
                                _showSuggestions = false;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Tag input (enter/comma to add, tap to remove)
          Text('Tags', style: AppFonts.ui(context, size: 12, color: theme.textMuted, weight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tagInputController,
                  style: AppFonts.ui(context),
                  decoration: InputDecoration(
                    hintText: 'Type tag and hit comma/enter',
                    hintStyle: AppFonts.ui(context, color: theme.textMuted),
                    filled: true,
                    fillColor: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.border)),
                  ),
                  onSubmitted: (val) => _addTag(val),
                  onChanged: (val) {
                    if (val.endsWith(',')) {
                      _addTag(val.replaceAll(',', ''));
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle, size: 28),
                color: AppColors.getRoleColor('copper', theme.isDark),
                onPressed: () => _addTag(_tagInputController.text),
              ),
            ],
          ),
          
          if (_tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _tags.map((tag) {
                return Chip(
                  label: Text('#$tag'),
                  labelStyle: AppFonts.mono(context, size: 11, color: theme.text),
                  backgroundColor: theme.isDark ? AppColors.darkSurface : AppColors.lightBorder.withOpacity(0.3),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () {
                    setState(() {
                      _tags.remove(tag);
                    });
                  },
                );
              }).toList(),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.getRoleColor('copper', theme.isDark),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.all(20),
          child: formWidget,
        ),
      );
    }
  }

  void _addTag(String val) {
    final cleaned = val.trim();
    if (cleaned.isNotEmpty && !_tags.contains(cleaned)) {
      setState(() {
        _tags.add(cleaned);
        _tagInputController.clear();
      });
    }
  }

  void _save(AppDatabase db, BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) return;

    final desc = _descriptionController.text.trim();
    final proj = _projectController.text.trim();

    await db.saveQuickCapture(
      description: desc,
      categoryId: _selectedCategoryId!,
      projectName: proj.isNotEmpty ? proj : null,
      tags: _tags,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Win captured successfully!', style: AppFonts.ui(context, color: Colors.white)),
          backgroundColor: AppColors.getRoleColor('sage', ThemeProvider.of(context).isDark),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
