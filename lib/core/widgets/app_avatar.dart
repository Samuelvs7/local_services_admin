import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? fallbackText;
  final Widget? fallbackIcon;
  final double size;
  final Color? backgroundColor;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.fallbackText,
    this.fallbackIcon,
    this.size = 40.0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color bgColor = backgroundColor ?? (isDark ? theme.colorScheme.surface : Colors.grey[200]!);
    final Color textColor = isDark ? Colors.grey[300]! : Colors.grey[700]!;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildAvatar(textColor),
    );
  }

  Widget _buildAvatar(Color textColor) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(textColor),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
      );
    }
    return _buildFallback(textColor);
  }

  Widget _buildFallback(Color textColor) {
    if (fallbackText != null && fallbackText!.isNotEmpty) {
      // Get initials if it's a name
      final initials = _getInitials(fallbackText!);
      return Center(
        child: Text(
          initials,
          style: TextStyle(
            color: textColor,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return Center(
      child: fallbackIcon ?? Icon(Icons.person_rounded, color: textColor, size: size * 0.6),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }
}
