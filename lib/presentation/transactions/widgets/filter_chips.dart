import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FilterChips extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const FilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(context, 'all', 'Tất cả'),
          const SizedBox(width: 8),
          _buildChip(context, 'expense', 'Chi tiêu'),
          const SizedBox(width: 8),
          _buildChip(context, 'income', 'Thu nhập'),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String value, String label) {
    final isSelected = selectedFilter == value;
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onFilterChanged(value);
        }
      },
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected 
            ? Colors.white 
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
