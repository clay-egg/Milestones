import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/state_providers.dart';
import '../widgets/common_widgets.dart';
import '../database/database.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final _inputController = TextEditingController();
  int? _selectedCatId;
  DateTime _selectedDate = DateTime.now();

  // Date Filter State (Defaults to Today)
  DateTime? _filterDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  void _submitTask(AppDatabase db, List<Categorie> categories) async {
    final title = _inputController.text.trim();
    if (title.isEmpty) return;

    final catId = _selectedCatId ?? (categories.isNotEmpty ? categories.first.id : 1);
    await db.addTodo(title, catId, dateCreated: _selectedDate);
    _inputController.clear();

    // Ensure filter includes the added task date
    setState(() {
      _filterDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      _selectedDate = DateTime.now();
    });
    ref.refresh(todosProvider);
  }

  void _pickDate(BuildContext context) async {
    final picked = await showThemedDatePicker(
      context: context,
      initialDate: _selectedDate,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // --- MINIMALIST DELETE CONFIRMATION POPUP ---
  void _confirmDeleteTodo(BuildContext context, AppDatabase db, TodoItem item) {
    showDialog(
      context: context,
      builder: (ctx) {
        final t = ThemeProvider.of(ctx);
        final roseColor = AppColors.getRoleColor('rose', t.isDark);
        return AlertDialog(
          backgroundColor: t.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: t.border, width: 0.8),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          title: Text('Delete Task', style: AppFonts.heading(ctx, size: 15)),
          content: Text(
            'Remove "${item.title}"?',
            style: AppFonts.ui(ctx, size: 12.5, color: t.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: AppFonts.ui(ctx, size: 12, color: t.textMuted)),
            ),
            TextButton(
              onPressed: () async {
                await db.deleteTodo(item);
                ref.refresh(todosProvider);
                ref.refresh(timelineEntriesProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text('Delete', style: AppFonts.ui(ctx, size: 12, color: roseColor, weight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // --- MINIMALIST EDIT TASK POPUP ---
  void _showEditTodoDialog(BuildContext context, AppDatabase db, TodoItem item, List<Categorie> categories) {
    final titleController = TextEditingController(text: item.title);
    int selectedCatId = item.categoryId;
    DateTime editDate = item.dateCreated;
    bool showInlineCalendar = false;

    showDialog(
      context: context,
      builder: (ctx) {
        final t = ThemeProvider.of(ctx);
        final copperColor = AppColors.getRoleColor('copper', t.isDark);
        final roseColor = AppColors.getRoleColor('rose', t.isDark);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: t.surface,
              elevation: 0,
              scrollable: true,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: t.border, width: 0.8),
              ),
              titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              title: Text('Edit Task', style: AppFonts.heading(ctx, size: 15)),
              content: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    style: AppFonts.ui(ctx, size: 13.5),
                    decoration: InputDecoration(
                      hintText: 'Task Title',
                      hintStyle: AppFonts.ui(ctx, size: 12.5, color: t.textMuted),
                      filled: true,
                      fillColor: t.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: t.border, width: 0.8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: t.border, width: 0.8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: copperColor, width: 1.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'DATE & CATEGORY',
                    style: AppFonts.mono(ctx, size: 8.5, color: t.textMuted, weight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setDialogState(() => showInlineCalendar = !showInlineCalendar);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: showInlineCalendar ? copperColor.withOpacity(0.2) : (t.isDark ? AppColors.darkSurface2 : AppColors.lightBg),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: showInlineCalendar ? copperColor : t.border, width: 0.8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_outlined, size: 11, color: copperColor),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM d, yyyy').format(editDate),
                                style: AppFonts.mono(ctx, size: 10.5, color: t.text),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                showInlineCalendar ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                size: 13,
                                color: copperColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox(width: double.infinity),
                    secondChild: InlineCalendarPicker(
                      initialDate: editDate,
                      onClose: () {
                        setDialogState(() {
                          showInlineCalendar = false;
                        });
                      },
                      onDateSelected: (picked) {
                        setDialogState(() {
                          editDate = picked;
                          showInlineCalendar = false;
                        });
                      },
                    ),
                    crossFadeState: showInlineCalendar ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: categories.map((cat) {
                      final isSelected = selectedCatId == cat.id;
                      final catColor = AppColors.getRoleColor(cat.role, t.isDark);
                      return ChoiceChip(
                        label: Text(cat.name),
                        selected: isSelected,
                        selectedColor: catColor.withValues(alpha: 0.2),
                        backgroundColor: t.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                        labelStyle: AppFonts.ui(
                          ctx,
                          size: 10.5,
                          color: isSelected ? catColor : t.textMuted,
                          weight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        visualDensity: VisualDensity.compact,
                        side: BorderSide(
                          color: isSelected ? catColor : t.border,
                          width: isSelected ? 1.0 : 0.5,
                        ),
                        onSelected: (val) {
                          if (val) setDialogState(() => selectedCatId = cat.id);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _confirmDeleteTodo(context, db, item);
                  },
                  child: Text(
                    'Delete',
                    style: AppFonts.ui(ctx, size: 12, color: roseColor, weight: FontWeight.bold),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Cancel', style: AppFonts.ui(ctx, size: 12, color: t.textMuted)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: copperColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () async {
                        final newTitle = titleController.text.trim();
                        if (newTitle.isNotEmpty) {
                          await db.updateTodo(
                            item,
                            title: newTitle,
                            categoryId: selectedCatId,
                            dateCreated: editDate,
                          );
                          ref.refresh(todosProvider);
                          ref.refresh(timelineEntriesProvider);
                          if (ctx.mounted) Navigator.pop(ctx);
                        }
                      },
                      child: Text('Save', style: AppFonts.ui(ctx, size: 12, color: Colors.black, weight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final todosAsync = ref.watch(todosProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final db = ref.watch(databaseProvider);
    final copperColor = AppColors.getRoleColor('copper', theme.isDark);

    final categories = categoriesAsync.value ?? [];

    if (_selectedCatId == null && categories.isNotEmpty) {
      _selectedCatId = categories.first.id;
    }

    final dateLabel = _isToday(_selectedDate)
        ? 'Today'
        : DateFormat('MMM d').format(_selectedDate);

    // Filter Label
    String filterLabel;
    if (_filterDate == null) {
      filterLabel = 'All Tasks';
    } else if (_isToday(_filterDate!)) {
      filterLabel = 'Today';
    } else {
      filterLabel = DateFormat('MMM d').format(_filterDate!);
    }

    // Section Title above list
    String listSectionTitle;
    if (_filterDate == null) {
      listSectionTitle = 'ALL TASKS';
    } else if (_isToday(_filterDate!)) {
      listSectionTitle = "TODAY'S TASKS";
    } else {
      listSectionTitle = 'TASKS (${DateFormat('MMM d').format(_filterDate!).toUpperCase()})';
    }

    return Scaffold(
      backgroundColor: theme.bg,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Clean Top Header (Minimalist)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('To-Do', style: AppFonts.heading(context, size: 18)),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Fast Inline Task Input Bar with Date Picker
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.border, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            style: AppFonts.ui(context, size: 13.5),
                            decoration: InputDecoration(
                              hintText: '+ Add a task...',
                              hintStyle: AppFonts.ui(context, size: 13, color: theme.textMuted),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _submitTask(db, categories),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _submitTask(db, categories),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: copperColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Add',
                              style: AppFonts.ui(context, size: 12, color: Colors.black, weight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // Date Picker Chip
                          InkWell(
                            onTap: () => _pickDate(context),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _isToday(_selectedDate)
                                    ? (theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg)
                                    : copperColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _isToday(_selectedDate) ? theme.border : copperColor,
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 11,
                                    color: _isToday(_selectedDate) ? theme.textMuted : copperColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    dateLabel,
                                    style: AppFonts.mono(
                                      context,
                                      size: 10.5,
                                      color: _isToday(_selectedDate) ? theme.textMuted : copperColor,
                                      weight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(width: 1, height: 16, color: theme.border),
                          const SizedBox(width: 8),

                          // Category Chips
                          ...categories.map((cat) {
                            final isSelected = _selectedCatId == cat.id;
                            final catColor = AppColors.getRoleColor(cat.role, theme.isDark);
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(cat.name),
                                selected: isSelected,
                                selectedColor: catColor.withValues(alpha: 0.2),
                                backgroundColor: theme.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                                labelStyle: AppFonts.ui(
                                  context,
                                  size: 11,
                                  color: isSelected ? catColor : theme.textMuted,
                                  weight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                visualDensity: VisualDensity.compact,
                                side: BorderSide(
                                  color: isSelected ? catColor : theme.border,
                                  width: isSelected ? 1.0 : 0.5,
                                ),
                                onSelected: (val) {
                                  if (val) setState(() => _selectedCatId = cat.id);
                                },
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Section Header Row: Title + ACTIVE Badge on Left, Date Filter on Right
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        listSectionTitle,
                        style: AppFonts.mono(context, size: 9.5, color: theme.textMuted, weight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      todosAsync.maybeWhen(
                        data: (todos) {
                          final filtered = _filterDate == null
                              ? todos
                              : todos.where((t) => _isSameDay(t.dateCreated, _filterDate!)).toList();
                          final activeCount = filtered.where((t) => !t.isCompleted).length;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: copperColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: copperColor.withValues(alpha: 0.35), width: 0.8),
                            ),
                            child: Text(
                              '$activeCount ACTIVE',
                              style: AppFonts.mono(context, size: 9, color: copperColor, weight: FontWeight.bold),
                            ),
                          );
                        },
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ],
                  ),

                  // Themed Date Filter Switcher Pill
                  PopupMenuButton<String>(
                    color: theme.surface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: theme.border, width: 0.8),
                    ),
                    onSelected: (value) async {
                      if (value == 'TODAY') {
                        setState(() {
                          _filterDate = DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                          );
                        });
                      } else if (value == 'ALL') {
                        setState(() {
                          _filterDate = null;
                        });
                      } else if (value == 'PICK') {
                        final picked = await showThemedDatePicker(
                          context: context,
                          initialDate: _filterDate ?? DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _filterDate = DateTime(picked.year, picked.month, picked.day);
                          });
                        }
                      }
                    },
                    itemBuilder: (context) {
                      final isTodaySel = _filterDate != null && _isToday(_filterDate!);
                      final isAllSel = _filterDate == null;
                      final isPickSel = _filterDate != null && !_isToday(_filterDate!);

                      return [
                        PopupMenuItem<String>(
                          value: 'TODAY',
                          height: 34,
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          child: Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: isTodaySel ? copperColor.withOpacity(0.12) : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.today_rounded, size: 13, color: isTodaySel ? copperColor : theme.textMuted),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Today',
                                      style: AppFonts.mono(
                                        context,
                                        size: 11,
                                        color: isTodaySel ? copperColor : theme.text,
                                        weight: isTodaySel ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                                if (isTodaySel)
                                  Icon(Icons.check_rounded, size: 13, color: copperColor),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'PICK',
                          height: 34,
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          child: Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: isPickSel ? copperColor.withOpacity(0.12) : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.calendar_month_rounded, size: 13, color: isPickSel ? copperColor : theme.textMuted),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Pick Date...',
                                      style: AppFonts.mono(
                                        context,
                                        size: 11,
                                        color: isPickSel ? copperColor : theme.text,
                                        weight: isPickSel ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                                if (isPickSel)
                                  Icon(Icons.check_rounded, size: 13, color: copperColor),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'ALL',
                          height: 34,
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          child: Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: isAllSel ? copperColor.withOpacity(0.12) : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.all_inbox_rounded, size: 13, color: isAllSel ? copperColor : theme.textMuted),
                                    const SizedBox(width: 8),
                                    Text(
                                      'All Tasks',
                                      style: AppFonts.mono(
                                        context,
                                        size: 11,
                                        color: isAllSel ? copperColor : theme.text,
                                        weight: isAllSel ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                                if (isAllSel)
                                  Icon(Icons.check_rounded, size: 13, color: copperColor),
                              ],
                            ),
                          ),
                        ),
                      ];
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: theme.border, width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.filter_alt_outlined,
                            size: 11,
                            color: _filterDate != null ? copperColor : theme.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            filterLabel.toUpperCase(),
                            style: AppFonts.mono(
                              context,
                              size: 9.5,
                              color: _filterDate != null ? copperColor : theme.text,
                              weight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 12,
                            color: theme.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 4. Tasks List (Filtered by Date)
              todosAsync.when(
                data: (allTodos) {
                  final todos = _filterDate == null
                      ? allTodos
                      : allTodos.where((t) => _isSameDay(t.dateCreated, _filterDate!)).toList();

                  final activeTodos = todos.where((t) => !t.isCompleted).toList();
                  final completedTodos = todos.where((t) => t.isCompleted).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (activeTodos.isEmpty && completedTodos.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          decoration: BoxDecoration(
                            color: theme.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: theme.border, width: 0.5),
                          ),
                          child: Center(
                            child: Text(
                              _filterDate != null && _isToday(_filterDate!)
                                  ? 'No tasks for today. Add one above!'
                                  : 'No tasks found for this view.',
                              style: AppFonts.ui(context, size: 13, color: theme.textMuted),
                            ),
                          ),
                        )
                      else ...[
                        if (activeTodos.isNotEmpty) ...[
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: activeTodos.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              return _buildTodoRow(context, db, activeTodos[index], categories, theme);
                            },
                          ),
                          const SizedBox(height: 24),
                        ],

                        if (completedTodos.isNotEmpty) ...[
                          Text(
                            'COMPLETED (${completedTodos.length})',
                            style: AppFonts.mono(context, size: 9.5, color: theme.textMuted, weight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: completedTodos.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              return _buildTodoRow(context, db, completedTodos[index], categories, theme);
                            },
                          ),
                        ],
                      ],
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                error: (err, stack) => Center(
                  child: Text('Error: $err', style: AppFonts.ui(context, color: theme.textMuted)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodoRow(
    BuildContext context,
    AppDatabase db,
    TodoItem item,
    List<Categorie> categories,
    ThemeDetails theme,
  ) {
    final category = categories.firstWhere(
      (c) => c.id == item.categoryId,
      orElse: () => Categorie(id: 0, name: 'General', role: 'copper', weeklyTarget: 0),
    );

    return InkWell(
      onTap: () => _showEditTodoDialog(context, db, item, categories),
      onLongPress: () => _confirmDeleteTodo(context, db, item),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.border, width: 0.6),
        ),
        child: Row(
          children: [
            // Checkbox toggle
            InkWell(
              onTap: () async {
                await db.toggleTodo(item);
                ref.refresh(todosProvider);
                ref.refresh(timelineEntriesProvider);
              },
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: item.isCompleted ? AppColors.getRoleColor(category.role, theme.isDark) : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: item.isCompleted ? AppColors.getRoleColor(category.role, theme.isDark) : theme.textMuted,
                    width: 1.2,
                  ),
                ),
                child: item.isCompleted
                    ? const Icon(Icons.check, size: 13, color: Colors.black)
                    : null,
              ),
            ),
            const SizedBox(width: 10),

            // Title text
            Expanded(
              child: Text(
                item.title,
                style: AppFonts.ui(
                  context,
                  size: 13,
                  color: item.isCompleted ? theme.textMuted : theme.text,
                  weight: item.isCompleted ? FontWeight.normal : FontWeight.w500,
                ).copyWith(
                  decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Task Date if not today
            if (!_isToday(item.dateCreated)) ...[
              Text(
                DateFormat('MMM d').format(item.dateCreated).toUpperCase(),
                style: AppFonts.mono(context, size: 8.5, color: theme.textMuted),
              ),
              const SizedBox(width: 6),
            ],

            // Category Badge Pill
            RoleBadge(text: category.name, role: category.role, isSmall: true),
          ],
        ),
      ),
    );
  }
}
