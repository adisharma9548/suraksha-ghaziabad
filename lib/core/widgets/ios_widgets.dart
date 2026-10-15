import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/ios_typography.dart';

/// Native iOS Grouped Inset Section
class IosGroupedSection extends StatelessWidget {
  final String? header;
  final String? footer;
  final List<Widget> children;
  final EdgeInsetsGeometry margin;

  const IosGroupedSection({
    super.key,
    this.header,
    this.footer,
    required this.children,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final separatorColor = isDark ? AppColors.separatorDark : AppColors.separatorLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;

    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 6),
              child: Text(
                header!.toUpperCase(),
                style: IosTypography.footnote(
                  color: secondaryTextColor,
                  weight: FontWeight.w600,
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: separatorColor.withOpacity(0.4), width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  for (int i = 0; i < children.length; i++) ...[
                    children[i],
                    if (i < children.length - 1)
                      Divider(
                        height: 0.5,
                        thickness: 0.5,
                        indent: 54,
                        color: separatorColor,
                      ),
                  ],
                ],
              ),
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 6, right: 16),
              child: Text(
                footer!,
                style: IosTypography.footnote(color: secondaryTextColor),
              ),
            ),
        ],
      ),
    );
  }
}

/// Native iOS Inset List Tile with >= 44pt touch target
class IosListTile extends StatefulWidget {
  final Widget? leading;
  final IconData? leadingIcon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool isDestructive;
  final bool? showDivider;

  const IosListTile({
    super.key,
    this.leading,
    this.leadingIcon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = false,
    this.isDestructive = false,
    this.showDivider,
  });

  @override
  State<IosListTile> createState() => _IosListTileState();
}

class _IosListTileState extends State<IosListTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;
    final pressedBg = isDark ? AppColors.secondarySurfaceDark : AppColors.secondarySurfaceLight;

    Widget? leadingWidget = widget.leading;
    if (leadingWidget == null && widget.leadingIcon != null) {
      leadingWidget = Icon(
        widget.leadingIcon,
        color: widget.isDestructive
            ? (isDark ? Colors.white : AppColors.primaryTextLight)
            : primaryTextColor,
        size: 20,
      );
    }

    return Semantics(
      button: widget.onTap != null,
      enabled: widget.onTap != null,
      label: widget.title,
      child: GestureDetector(
        onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: widget.onTap != null ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minHeight: 44),
          color: _isPressed ? pressedBg : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            children: [
              if (leadingWidget != null) ...[
                leadingWidget,
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: IosTypography.body(
                        color: widget.isDestructive
                            ? (isDark ? Colors.white : AppColors.primaryTextLight)
                            : primaryTextColor,
                        weight: widget.isDestructive ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle!,
                        style: IosTypography.footnote(color: secondaryTextColor),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.trailing != null) widget.trailing!,
              if (widget.showChevron && widget.trailing == null)
                Icon(
                  CupertinoIcons.chevron_forward,
                  size: 16,
                  color: isDark ? AppColors.tertiaryTextDark : AppColors.tertiaryTextLight,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Button type enumeration for Apple HIG styling
enum IosButtonType { primary, secondary, destructive }

/// Native iOS Button with spring animation feedback and minimum 44pt target
class IosButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final String? text;
  final IconData? icon;
  final bool isPrimary;
  final bool isDestructive;
  final bool isLoading;
  final double height;
  final EdgeInsetsGeometry padding;
  final IosButtonType? type;

  const IosButton({
    super.key,
    required this.onPressed,
    this.child,
    this.text,
    this.icon,
    this.isPrimary = true,
    this.isDestructive = false,
    this.isLoading = false,
    this.height = 50,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.type,
  });

  @override
  State<IosButton> createState() => _IosButtonState();
}

class _IosButtonState extends State<IosButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final actualType = widget.type ??
        (widget.isDestructive
            ? IosButtonType.destructive
            : (widget.isPrimary ? IosButtonType.primary : IosButtonType.secondary));

    Color bg;
    Color fg;
    Color border;

    switch (actualType) {
      case IosButtonType.primary:
        bg = isDark ? AppColors.primaryActionDark : AppColors.primaryActionLight;
        fg = isDark ? AppColors.onPrimaryActionDark : AppColors.onPrimaryActionLight;
        border = Colors.transparent;
        break;
      case IosButtonType.destructive:
        bg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
        fg = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
        border = isDark ? AppColors.separatorDark : AppColors.separatorLight;
        break;
      case IosButtonType.secondary:
        bg = isDark ? AppColors.secondarySurfaceDark : AppColors.secondarySurfaceLight;
        fg = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
        border = isDark ? AppColors.separatorDark : AppColors.separatorLight;
        break;
    }

    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return Semantics(
      button: true,
      enabled: isEnabled,
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
        onTap: isEnabled ? widget.onPressed : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: !isEnabled ? 0.45 : (_isPressed ? 0.8 : 1.0),
            duration: const Duration(milliseconds: 180),
            child: Container(
              height: widget.height,
              constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
              padding: widget.padding,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border, width: 1.0),
              ),
              alignment: Alignment.center,
              child: widget.isLoading
                  ? CupertinoActivityIndicator(color: fg)
                  : widget.child ??
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, size: 18, color: fg),
                            const SizedBox(width: 8),
                          ],
                          if (widget.text != null)
                            Text(
                              widget.text!,
                              style: IosTypography.headline(color: fg),
                            ),
                        ],
                      ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Native iOS Segmented Control with smooth pill slider
class IosSegmentedControl<T> extends StatelessWidget {
  final Map<T, String> children;
  final T groupValue;
  final ValueChanged<T> onValueChanged;

  const IosSegmentedControl({
    super.key,
    required this.children,
    required this.groupValue,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.secondarySurfaceDark : AppColors.secondarySurfaceLight;
    final selectedBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final activeText = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final inactiveText = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;

    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: children.entries.map((entry) {
          final isSelected = entry.key == groupValue;
          return Expanded(
            child: GestureDetector(
              onTap: () => onValueChanged(entry.key),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? selectedBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  entry.value,
                  style: IosTypography.footnote(
                    color: isSelected ? activeText : inactiveText,
                    weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Badge types for color-blind safe status
enum IosBadgeType { info, success, warning, error }

/// Apple HIG Multi-Cue Accessible Status Badge
/// Combines icon + label + distinct shape + border (NEVER color alone)
class IosBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isFilled;
  final bool isHighlighted;
  final IosBadgeType? type;

  const IosBadge({
    super.key,
    required this.label,
    required this.icon,
    this.isFilled = false,
    this.isHighlighted = false,
    this.type,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    final filled = isFilled || type == IosBadgeType.error;
    final highlighted = isHighlighted || type == IosBadgeType.error || type == IosBadgeType.warning;

    final border = highlighted
        ? (isDark ? Colors.white : Colors.black)
        : (isDark ? AppColors.separatorDark : AppColors.separatorLight);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: filled
            ? (isDark ? AppColors.primaryActionDark : AppColors.primaryActionLight)
            : surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: border,
          width: highlighted ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: filled
                ? (isDark ? Colors.black : Colors.white)
                : primaryTextColor,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: IosTypography.caption2(
              color: filled
                  ? (isDark ? Colors.black : Colors.white)
                  : primaryTextColor,
              weight: highlighted ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Native iOS 16px Squircle Card
class IosCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const IosCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final separatorColor = isDark ? AppColors.separatorDark : AppColors.separatorLight;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: separatorColor.withOpacity(0.5), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
