import 'package:flutter/material.dart';

// การแยก Widget เพื่อให้อ่านง่ายขึ้น
class FilterDropdown extends StatelessWidget {
  final String selectedFilter;
  final List<String> filterItems;
  final ValueChanged<String?> onChanged;

  const FilterDropdown({
    super.key,
    required this.selectedFilter,
    required this.filterItems,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAFF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedFilter,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0D47A1)),
          dropdownColor: const Color(0xFFFCFAFF),
          style: const TextStyle(fontSize: 15, color: Color(0xFF564444)),
          items: filterItems.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
