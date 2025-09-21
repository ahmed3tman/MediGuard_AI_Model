import 'package:flutter/material.dart';

class CustomActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bgColor;
  final String? tooltip;
  final bool iconOnly;
  final VoidCallback onPressed;

  const CustomActionButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.bgColor,
    this.tooltip,
    this.iconOnly = false,
    required this.onPressed,
  }) : super(key: key);

  ButtonStyle _outlinedButtonStyle(Color bgColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: bgColor,
      foregroundColor: Colors.black87,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
        side: BorderSide(color: Colors.grey.shade400),
      ),
      textStyle: const TextStyle(fontSize: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final child =
        iconOnly
            ? Icon(icon)
            : Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(icon), const SizedBox(width: 8), Text(label)],
            );

    final button = ElevatedButton(
      style: _outlinedButtonStyle(bgColor),
      onPressed: onPressed,
      child: child,
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: SizedBox(height: 48, child: button),
      );
    }
    return SizedBox(height: 48, child: button);
  }
}
