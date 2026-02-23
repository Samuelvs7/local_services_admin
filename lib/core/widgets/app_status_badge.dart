import 'package:flutter/material.dart';

/// Variant for the status badge.
enum StatusBadgeVariant { success, warning, error, info, muted, brand }

/// A styled status badge with optional leading dot indicator.
///
/// Renders a colored pill with text, suitable for showing entity statuses.
///
/// ```dart
/// AppStatusBadge(variant: StatusBadgeVariant.success, label: 'Approved', dot: true)
/// AppStatusBadge(variant: StatusBadgeVariant.warning, label: 'Pending')
/// ```
class AppStatusBadge extends StatelessWidget {
  final StatusBadgeVariant variant;
  final String label;
  final bool dot;

  const AppStatusBadge({
    super.key,
    required this.variant,
    required this.label,
    this.dot = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _variantColors(variant, isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.dot,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.text,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  static _BadgeColors _variantColors(StatusBadgeVariant v, bool isDark) {
    switch (v) {
      case StatusBadgeVariant.success:
        final c = isDark ? const Color(0xFF34D399) : const Color(0xFF10B981);
        return _BadgeColors(
          bg: c.withAlpha(26),
          text: c,
          dot: c,
        );
      case StatusBadgeVariant.warning:
        final c = isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B);
        return _BadgeColors(
          bg: c.withAlpha(26),
          text: c,
          dot: c,
        );
      case StatusBadgeVariant.error:
        final c = isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444);
        return _BadgeColors(
          bg: c.withAlpha(26),
          text: c,
          dot: c,
        );
      case StatusBadgeVariant.info:
        final c = isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6);
        return _BadgeColors(
          bg: c.withAlpha(26),
          text: c,
          dot: c,
        );
      case StatusBadgeVariant.muted:
        final c = isDark ? Colors.grey[500]! : Colors.grey[500]!;
        return _BadgeColors(
          bg: c.withAlpha(26),
          text: c,
          dot: c,
        );
      case StatusBadgeVariant.brand:
        final c = isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED);
        return _BadgeColors(
          bg: c.withAlpha(26),
          text: c,
          dot: c,
        );
    }
  }
}

class _BadgeColors {
  final Color bg;
  final Color text;
  final Color dot;

  const _BadgeColors({
    required this.bg,
    required this.text,
    required this.dot,
  });
}

// ---------------------------------------------------------------------------
// Domain-specific helpers
// ---------------------------------------------------------------------------

/// Returns a status badge for store approval statuses.
///
/// ```dart
/// storeStatusBadge('approved')  // ● Approved (green)
/// storeStatusBadge('pending')   // ● Pending  (yellow)
/// ```
Widget storeStatusBadge(String status) {
  const map = {
    'pending': (StatusBadgeVariant.warning, 'Pending'),
    'approved': (StatusBadgeVariant.success, 'Approved'),
    'rejected': (StatusBadgeVariant.error, 'Rejected'),
    'suspended': (StatusBadgeVariant.muted, 'Suspended'),
  };
  final cfg = map[status];
  return AppStatusBadge(
    variant: cfg?.$1 ?? StatusBadgeVariant.muted,
    label: cfg?.$2 ?? status,
    dot: true,
  );
}

/// Returns a status badge for order statuses.
///
/// ```dart
/// orderStatusBadge('delivered')  // ● Delivered (green)
/// ```
Widget orderStatusBadge(String status) {
  const map = {
    'pending': (StatusBadgeVariant.warning, 'Pending'),
    'accepted': (StatusBadgeVariant.info, 'Accepted'),
    'preparing': (StatusBadgeVariant.brand, 'Preparing'),
    'out_for_delivery': (StatusBadgeVariant.info, 'Out for Delivery'),
    'delivered': (StatusBadgeVariant.success, 'Delivered'),
    'cancelled': (StatusBadgeVariant.error, 'Cancelled'),
  };
  final cfg = map[status];
  return AppStatusBadge(
    variant: cfg?.$1 ?? StatusBadgeVariant.muted,
    label: cfg?.$2 ?? status,
    dot: true,
  );
}

/// Returns a status badge for service types.
///
/// ```dart
/// serviceTypeBadge('food')  // 🍔 Food (green)
/// ```
Widget serviceTypeBadge(String type) {
  const map = {
    'food': (StatusBadgeVariant.success, '🍔 Food'),
    'bike': (StatusBadgeVariant.brand, '🏍 Bike'),
    'parcel': (StatusBadgeVariant.info, '📦 Parcel'),
  };
  final cfg = map[type];
  return AppStatusBadge(
    variant: cfg?.$1 ?? StatusBadgeVariant.muted,
    label: cfg?.$2 ?? type,
  );
}
