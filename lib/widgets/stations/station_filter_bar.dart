import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../services/station_filter.dart';
import '../../theme/app_colors.dart';

class StationFilterBar extends StatelessWidget {
  const StationFilterBar({
    super.key,
    required this.controller,
    required this.filter,
    required this.counts,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  final TextEditingController controller;
  final StationFilter filter;
  final Map<StationFilter, int> counts;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<StationFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        controller: controller,
        onChanged: onSearchChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Buscar por estação, rio ou bacia',
          prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.subtle),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Limpar busca',
                  icon: const Icon(LucideIcons.x, size: 18),
                  onPressed: () {
                    controller.clear();
                    onSearchChanged('');
                  },
                ),
        ),
      ),
      const SizedBox(height: 12),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final option in StationFilter.values)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('${option.label} (${counts[option] ?? 0})'),
                  selected: filter == option,
                  showCheckmark: false,
                  onSelected: (_) => onFilterChanged(option),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: filter == option ? AppColors.white : AppColors.navy,
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}
