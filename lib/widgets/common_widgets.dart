import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        border: Border.all(color: borderColor, width: 1.0),
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
      child: widget.role != null
          ? IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: leftBorderColor,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: widget.child),
                ],
              ),
            )
          : widget.child,
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
