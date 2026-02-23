import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppCalendar extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const AppCalendar({
    super.key,
    this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<AppCalendar> createState() => _AppCalendarState();
}

class _AppCalendarState extends State<AppCalendar> {
  late DateTime _focusedDate;
  late DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _focusedDate = widget.selectedDate ?? DateTime.now();
    _selectedDate = widget.selectedDate;
  }

  void _onPreviousMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
    });
  }

  void _onNextMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Navigation Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _onPreviousMonth,
                icon: const Icon(Icons.chevron_left_rounded, size: 20),
                visualDensity: VisualDensity.compact,
              ),
              Text(
                DateFormat('MMMM yyyy').format(_focusedDate),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              IconButton(
                onPressed: _onNextMonth,
                icon: const Icon(Icons.chevron_right_rounded, size: 20),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Days List
          _buildDaysGrid(),
        ],
      ),
    );
  }

  Widget _buildDaysGrid() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final weekdayLabels = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

    return Column(
      children: [
        // Weekday Headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekdayLabels.map((day) {
            return SizedBox(
              width: 36,
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    color: Colors.grey[isDark ? 500 : 400],
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Days Grid
        _buildDaysList(),
      ],
    );
  }

  Widget _buildDaysList() {
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final lastDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7; // Sunday starts at 0

    final List<Widget> dayWidgets = [];

    // Add empty slots for previous month days
    for (var i = 0; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 36, height: 36));
    }

    // Add actual days
    for (var i = 1; i <= daysInMonth; i++) {
      final date = DateTime(_focusedDate.year, _focusedDate.month, i);
      final isSelected = _selectedDate != null &&
          date.year == _selectedDate!.year &&
          date.month == _selectedDate!.month &&
          date.day == _selectedDate!.day;
      final isToday = date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day;

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
            widget.onDateSelected(date);
          },
          child: Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).colorScheme.primary : (isToday ? Theme.of(context).colorScheme.primary.withAlpha(26) : Colors.transparent),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                i.toString(),
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? Colors.white : (isToday ? Theme.of(context).colorScheme.primary : null),
                  fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.start,
      children: dayWidgets,
    );
  }
}
