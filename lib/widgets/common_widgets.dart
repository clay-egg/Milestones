import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AppColors {
  // Dark Theme
  static const darkBg = Color(0xff14100b);
  static const darkSurface = Color(0xff1f1811);
  static const darkSurface2 = Color(0xff291f15);
  static const darkBorder = Color(0xff3a2c1c);
  static const darkText = Color(0xfff5ece0);
  static const darkTextMuted = Color(0xffab9a86);

  // Light Theme
  static const lightBg = Color(0xfff7f1e6);
  static const lightSurface = Color(0xfffffbf4);
  static const lightBorder = Color(0xffe3d3ba);
  static const lightText = Color(0xff2b2015);
  static const lightTextMuted = Color(0xff6f6150);

  // Role Colors (same meaning, but tweaked contrast for dark vs light)
  // Dark roles
  static const darkCopper = Color(0xffe08a3e);
  static const darkGold = Color(0xffdda63f);
  static const darkPlum = Color(0xffa2688c);
  static const darkSage = Color(0xff86a878);
  static const darkRose = Color(0xffc9634c);

  // Light roles
  static const lightCopper = Color(0xffc1701f);
  static const lightGold = Color(0xffa97a1e);
  static const lightPlum = Color(0xff8a4d72);
  static const lightSage = Color(0xff5a7c4e);
  static const lightRose = Color(0xffa8492f);

  static Color getRoleColor(String role, bool isDark) {
    switch (role.toLowerCase()) {
      case 'learning':
      case 'copper':
        return isDark ? darkCopper : lightCopper;
      case 'achievement':
      case 'gold':
        return isDark ? darkGold : lightGold;
      case 'goal':
      case 'plum':
        return isDark ? darkPlum : lightPlum;
      case 'neutral':
      case 'success':
      case 'sage':
        return isDark ? darkSage : lightSage;
      case 'destructive':
      case 'rose':
        return isDark ? darkRose : lightRose;
      default:
        return isDark ? darkTextMuted : lightTextMuted;
    }
  }
}

class ThemeDetails {
  final bool isDark;
  final Color bg;
  final Color surface;
  final Color surface2;
  final Color border;
  final Color text;
  final Color textMuted;

  ThemeDetails({
    required this.isDark,
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.text,
    required this.textMuted,
  });

  factory ThemeDetails.dark() => ThemeDetails(
        isDark: true,
        bg: AppColors.darkBg,
        surface: AppColors.darkSurface,
        surface2: AppColors.darkSurface2,
        border: AppColors.darkBorder,
        text: AppColors.darkText,
        textMuted: AppColors.darkTextMuted,
      );

  factory ThemeDetails.light() => ThemeDetails(
        isDark: false,
        bg: AppColors.lightBg,
        surface: AppColors.lightSurface,
        surface2: AppColors.lightBg, // Using lightBg for surface2 as light has fewer surface steps
        border: AppColors.lightBorder,
        text: AppColors.lightText,
        textMuted: AppColors.lightTextMuted,
      );
}

class ThemeProvider extends InheritedWidget {
  final ThemeDetails theme;

  const ThemeProvider({
    Key? key,
    required this.theme,
    required Widget child,
  }) : super(key: key, child: child);

  static ThemeDetails of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
    return provider?.theme ?? ThemeDetails.dark();
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return theme.isDark != oldWidget.theme.isDark;
  }
}

// Custom Font styles helper
class AppFonts {
  static TextStyle heading(BuildContext context, {double size = 20, Color? color, FontWeight? weight}) {
    final theme = ThemeProvider.of(context);
    return GoogleFonts.fraunces(
      fontSize: size,
      fontWeight: weight ?? FontWeight.bold,
      color: color ?? theme.text,
    );
  }

  static TextStyle ui(BuildContext context, {double size = 14, Color? color, FontWeight? weight}) {
    final theme = ThemeProvider.of(context);
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight ?? FontWeight.normal,
      color: color ?? theme.text,
    );
  }

  static TextStyle mono(BuildContext context, {double size = 12, Color? color, FontWeight? weight}) {
    final theme = ThemeProvider.of(context);
    return GoogleFonts.jetBrainsMono(
      fontSize: size,
      fontWeight: weight ?? FontWeight.normal,
      color: color ?? theme.textMuted,
    );
  }
}

// Milestone Card with Hover and Tap Animations
class MilestoneCard extends StatefulWidget {
  final Widget child;
  final String? role; // copper, gold, plum, sage, rose
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const MilestoneCard({
    Key? key,
    required this.child,
    this.role,
    this.onTap,
    this.padding,
  }) : super(key: key);

  @override
  State<MilestoneCard> createState() => _MilestoneCardState();
}

class _MilestoneCardState extends State<MilestoneCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final isDark = theme.isDark;

    Color borderColor = theme.border;
    if (_isHovered) {
      if (widget.role != null) {
        borderColor = AppColors.getRoleColor(widget.role!, isDark);
      } else {
        borderColor = AppColors.getRoleColor('copper', isDark);
      }
    }

    final leftBorderColor = widget.role != null
        ? AppColors.getRoleColor(widget.role!, isDark)
        : null;

    final double translation = _isHovered ? -3.0 : 0.0;
    final double scale = _isPressed ? 0.98 : (_isHovered ? 1.01 : 1.0);

    final double shadowBlur = _isHovered ? 16.0 : 8.0;
    final Offset shadowOffset = _isHovered ? const Offset(0, 8) : const Offset(0, 4);
    final double shadowOpacity = _isHovered
        ? (isDark ? 0.35 : 0.16)
        : (isDark ? 0.25 : 0.10);

    Widget cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      transform: Matrix4.identity()
        ..translate(0.0, translation)
        ..scale(scale),
      padding: widget.padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          top: BorderSide(color: borderColor, width: 1.0),
          right: BorderSide(color: borderColor, width: 1.0),
          bottom: BorderSide(color: borderColor, width: 1.0),
          left: BorderSide(
            color: leftBorderColor ?? borderColor,
            width: widget.role != null ? 3.5 : 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Color.fromRGBO(0, 0, 0, shadowOpacity)
                : Color.fromRGBO(90, 64, 30, shadowOpacity),
            blurRadius: shadowBlur,
            offset: shadowOffset,
          )
        ],
      ),
      child: widget.child,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: cardContent,
      ),
    );
  }
}

// Custom App Background with radial gradient glows
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final isDark = theme.isDark;

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: theme.bg,
          ),
        ),
        // Glow 1: Top-Left Copper Glow
        Positioned(
          left: -200,
          top: -200,
          width: 800,
          height: 800,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    isDark ? const Color(0x1ae08a3e) : const Color(0x14c1701f),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),
        ),
        // Glow 2: Top-Right Plum Glow
        Positioned(
          right: -200,
          top: -100,
          width: 700,
          height: 700,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    isDark ? const Color(0x12a2688c) : const Color(0x0fa2688c),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}

// Stateful Sidebar Navigation Item with hover transitions
class SidebarNavItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const SidebarNavItem({
    Key? key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<SidebarNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final activeColor = AppColors.getRoleColor('copper', theme.isDark);

    Color bgColor = Colors.transparent;
    Color textColor = theme.textMuted;
    Color iconColor = theme.textMuted;

    if (widget.isSelected) {
      bgColor = activeColor.withOpacity(0.12);
      textColor = theme.text;
      iconColor = activeColor;
    } else if (_isHovered) {
      bgColor = theme.isDark ? AppColors.darkSurface2 : AppColors.lightBorder.withOpacity(0.3);
      textColor = theme.text;
      iconColor = theme.text;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isSelected ? activeColor.withOpacity(0.3) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: iconColor,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: AppFonts.ui(
                  context,
                  size: 14,
                  color: textColor,
                  weight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Role Badge
class RoleBadge extends StatelessWidget {
  final String text;
  final String role;
  final bool isSmall;

  const RoleBadge({
    Key? key,
    required this.text,
    required this.role,
    this.isSmall = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final color = AppColors.getRoleColor(role, theme.isDark);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 6 : 10, vertical: isSmall ? 2 : 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.3), width: 1.0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AppFonts.mono(
          context,
          size: isSmall ? 10 : 12,
          color: color,
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Global Minimalist Sleek Calendar Popup Helper with Smooth Animation
Future<DateTime?> showThemedDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  return await showGeneralDialog<DateTime>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Calendar',
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (ctx, anim1, anim2) => MinimalistCalendarDialog(initialDate: initialDate),
    transitionBuilder: (ctx, anim1, anim2, child) {
      final curvedAnim = CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic);
      return ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1.0).animate(curvedAnim),
        child: FadeTransition(
          opacity: curvedAnim,
          child: child,
        ),
      );
    },
  );
}

// Minimalist Sleek Calendar Dialog Widget
class MinimalistCalendarDialog extends StatefulWidget {
  final DateTime initialDate;

  const MinimalistCalendarDialog({
    Key? key,
    required this.initialDate,
  }) : super(key: key);

  @override
  State<MinimalistCalendarDialog> createState() => _MinimalistCalendarDialogState();
}

class _MinimalistCalendarDialogState extends State<MinimalistCalendarDialog> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(widget.initialDate.year, widget.initialDate.month, widget.initialDate.day);
    _focusedMonth = DateTime(widget.initialDate.year, widget.initialDate.month, 1);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.of(context);
    final copperColor = AppColors.getRoleColor('copper', t.isDark);

    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final leadingPadding = (firstDayOfMonth.weekday - 1) % 7;

    final monthLabel = DateFormat('MMMM yyyy').format(_focusedMonth).toUpperCase();
    final weekdays = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];

    return Dialog(
      backgroundColor: t.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: t.border, width: 0.8),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 310,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Header Nav (< AUGUST 2026 >)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    monthLabel,
                    key: ValueKey(monthLabel),
                    style: AppFonts.mono(context, size: 11.5, color: t.text, weight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
                        });
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(Icons.chevron_left_rounded, size: 18, color: t.textMuted),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
                        });
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(Icons.chevron_right_rounded, size: 18, color: t.textMuted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Weekday Headers (MO TU WE TH FR SA SU)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekdays.map((w) {
                return SizedBox(
                  width: 32,
                  child: Center(
                    child: Text(
                      w,
                      style: AppFonts.mono(context, size: 9.5, color: t.textMuted, weight: FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),

            // Days Grid with AnimatedSwitcher for smooth month transitions
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: GridView.builder(
                key: ValueKey('${_focusedMonth.year}-${_focusedMonth.month}'),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: leadingPadding + daysInMonth,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemBuilder: (context, index) {
                  if (index < leadingPadding) {
                    return const SizedBox.shrink();
                  }
                  final dayNumber = index - leadingPadding + 1;
                  final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
                  final isSelected = _isSameDay(date, _selectedDate);
                  final isToday = _isSameDay(date, DateTime.now());

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? copperColor
                            : (isToday ? copperColor.withOpacity(0.12) : Colors.transparent),
                        borderRadius: BorderRadius.circular(6),
                        border: isToday && !isSelected
                            ? Border.all(color: copperColor.withOpacity(0.5), width: 0.8)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$dayNumber',
                          style: AppFonts.mono(
                            context,
                            size: 11.5,
                            color: isSelected
                                ? Colors.black
                                : (isToday ? copperColor : t.text),
                            weight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Bottom Actions Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    final today = DateTime.now();
                    setState(() {
                      _selectedDate = DateTime(today.year, today.month, today.day);
                      _focusedMonth = DateTime(today.year, today.month, 1);
                    });
                  },
                  child: Text('Today', style: AppFonts.mono(context, size: 11, color: t.textMuted)),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: AppFonts.mono(context, size: 11, color: t.textMuted)),
                    ),
                    const SizedBox(width: 4),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: copperColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () => Navigator.pop(context, _selectedDate),
                      child: Text(
                        'Select',
                        style: AppFonts.mono(context, size: 11, color: Colors.black, weight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Inline Calendar Picker Widget (Used inside Bottom Sheets and Dialogs to avoid double popup layering)
class InlineCalendarPicker extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback? onClose;

  const InlineCalendarPicker({
    Key? key,
    required this.initialDate,
    required this.onDateSelected,
    this.onClose,
  }) : super(key: key);

  @override
  State<InlineCalendarPicker> createState() => _InlineCalendarPickerState();
}

class _InlineCalendarPickerState extends State<InlineCalendarPicker> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(widget.initialDate.year, widget.initialDate.month, widget.initialDate.day);
    _focusedMonth = DateTime(widget.initialDate.year, widget.initialDate.month, 1);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final t = ThemeProvider.of(context);
    final copperColor = AppColors.getRoleColor('copper', t.isDark);

    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final leadingPadding = (firstDayOfMonth.weekday - 1) % 7;

    final monthLabel = DateFormat('MMMM yyyy').format(_focusedMonth).toUpperCase();
    final weekdays = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: t.border, width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month Header Nav (< AUGUST 2026 >)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: Text(
                  monthLabel,
                  key: ValueKey(monthLabel),
                  style: AppFonts.mono(context, size: 10.5, color: t.text, weight: FontWeight.bold),
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
                      });
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Icon(Icons.chevron_left_rounded, size: 16, color: t.textMuted),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
                      });
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Icon(Icons.chevron_right_rounded, size: 16, color: t.textMuted),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Weekday Headers (MO TU WE TH FR SA SU)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdays.map((w) {
              return SizedBox(
                width: 28,
                child: Center(
                  child: Text(
                    w,
                    style: AppFonts.mono(context, size: 8.5, color: t.textMuted, weight: FontWeight.bold),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),

          // Days Grid
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: GridView.builder(
              key: ValueKey('${_focusedMonth.year}-${_focusedMonth.month}'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leadingPadding + daysInMonth,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 3,
                crossAxisSpacing: 3,
              ),
              itemBuilder: (context, index) {
                if (index < leadingPadding) {
                  return const SizedBox.shrink();
                }
                final dayNumber = index - leadingPadding + 1;
                final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
                final isSelected = _isSameDay(date, _selectedDate);
                final isToday = _isSameDay(date, DateTime.now());

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                    widget.onDateSelected(date);
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? copperColor
                          : (isToday ? copperColor.withOpacity(0.12) : Colors.transparent),
                      borderRadius: BorderRadius.circular(5),
                      border: isToday && !isSelected
                          ? Border.all(color: copperColor.withOpacity(0.5), width: 0.8)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$dayNumber',
                        style: AppFonts.mono(
                          context,
                          size: 10.5,
                          color: isSelected
                              ? Colors.black
                              : (isToday ? copperColor : t.text),
                          weight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Bottom Action Row (Today + Hide Calendar)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  final today = DateTime.now();
                  setState(() {
                    _selectedDate = DateTime(today.year, today.month, today.day);
                    _focusedMonth = DateTime(today.year, today.month, 1);
                  });
                  widget.onDateSelected(_selectedDate);
                },
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text('Today', style: AppFonts.mono(context, size: 10, color: t.textMuted, weight: FontWeight.bold)),
                ),
              ),
              if (widget.onClose != null)
                InkWell(
                  onTap: widget.onClose,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: t.border.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.keyboard_arrow_up_rounded, size: 12, color: t.textMuted),
                        const SizedBox(width: 2),
                        Text('Hide Calendar', style: AppFonts.mono(context, size: 10, color: t.textMuted)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<TimeOfDay?> showThemedTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) async {
  int hour = initialTime.hourOfPeriod == 0 ? 12 : initialTime.hourOfPeriod;
  int minute = initialTime.minute;
  bool isAm = initialTime.period == DayPeriod.am;

  return showDialog<TimeOfDay>(
    context: context,
    builder: (context) {
      final t = ThemeProvider.of(context);
      final copperColor = AppColors.getRoleColor('copper', t.isDark);
      final hourController = TextEditingController(text: hour.toString().padLeft(2, '0'));
      final minuteController = TextEditingController(text: minute.toString().padLeft(2, '0'));

      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: t.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: t.border, width: 0.8),
            ),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            title: Row(
              children: [
                Icon(Icons.access_time_rounded, size: 18, color: copperColor),
                const SizedBox(width: 8),
                Text('Set Time', style: AppFonts.heading(context, size: 16)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Hour Field
                    SizedBox(
                      width: 65,
                      child: TextField(
                        controller: hourController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: AppFonts.mono(context, size: 22, weight: FontWeight.bold, color: t.text),
                        maxLength: 2,
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: t.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
                            borderSide: BorderSide(color: copperColor, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(':', style: AppFonts.mono(context, size: 22, weight: FontWeight.bold, color: t.textMuted)),
                    ),
                    // Minute Field
                    SizedBox(
                      width: 65,
                      child: TextField(
                        controller: minuteController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: AppFonts.mono(context, size: 22, weight: FontWeight.bold, color: t.text),
                        maxLength: 2,
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: t.isDark ? AppColors.darkSurface2 : AppColors.lightBg,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
                            borderSide: BorderSide(color: copperColor, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // AM / PM Toggle Pill
                    InkWell(
                      onTap: () {
                        setDialogState(() {
                          isAm = !isAm;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                        decoration: BoxDecoration(
                          color: copperColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: copperColor.withOpacity(0.4), width: 0.8),
                        ),
                        child: Text(
                          isAm ? 'AM' : 'PM',
                          style: AppFonts.mono(context, size: 13, color: copperColor, weight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: Text('Cancel', style: AppFonts.ui(context, color: t.textMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: copperColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () {
                  int parsedH = int.tryParse(hourController.text.trim()) ?? 12;
                  int parsedM = int.tryParse(minuteController.text.trim()) ?? 0;
                  parsedH = parsedH.clamp(1, 12);
                  parsedM = parsedM.clamp(0, 59);

                  int hour24 = parsedH;
                  if (isAm) {
                    if (parsedH == 12) hour24 = 0;
                  } else {
                    if (parsedH < 12) hour24 = parsedH + 12;
                  }

                  Navigator.pop(context, TimeOfDay(hour: hour24, minute: parsedM));
                },
                child: Text('Set Time', style: AppFonts.ui(context, color: Colors.white, weight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    },
  );
}
