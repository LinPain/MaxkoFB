import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/app_provider.dart';

class BranchPickerDialog extends StatefulWidget {
  const BranchPickerDialog({Key? key}) : super(key: key);

  @override
  State<BranchPickerDialog> createState() => _BranchPickerDialogState();
}

class _BranchPickerDialogState extends State<BranchPickerDialog> {
  String _selectedCity = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final cities = provider.branches
        .map((branch) => branch.city)
        .where((city) => city.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final selectedCity =
        _selectedCity == 'all' || cities.contains(_selectedCity)
            ? _selectedCity
            : 'all';
    final branches = provider.branches.where((b) {
      if (selectedCity != 'all' && b.city != selectedCity) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return b.name.toLowerCase().contains(q) ||
            b.address.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 520),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chọn cơ sở phục vụ',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textMain),
                      ),
                      Text(
                        'Chọn cơ sở đang hoạt động',
                        style: TextStyle(
                            fontSize: 10.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Search Bar & City Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.chipBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        icon: Icon(Icons.search,
                            size: 18, color: AppColors.textMuted),
                        hintText: 'Tìm theo tên cơ sở hoặc đường...',
                        hintStyle:
                            TextStyle(fontSize: 11, color: AppColors.textMuted),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // City Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCityChip('all', 'Tất cả'),
                        ...cities.expand((city) => [
                              const SizedBox(width: 6),
                              _buildCityChip(city, city),
                            ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Branches List
            Expanded(
              child: branches.isEmpty
                  ? Center(
                      child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                              provider.apiError ??
                                  'Chưa có dữ liệu cơ sở từ máy chủ.',
                              textAlign: TextAlign.center,
                              style:
                                  const TextStyle(color: AppColors.textMuted))))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: branches.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final branch = branches[index];
                        final isSelected =
                            provider.activeBranch.id == branch.id;

                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 4),
                          onTap: () {
                            provider.setActiveBranch(branch);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã chọn cơ sở: ${branch.name}'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : AppColors.chipBackground,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.storefront,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            branch.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textMain,
                            ),
                          ),
                          subtitle: Text(
                            '${branch.address} • ${branch.distance}',
                            style: const TextStyle(
                                fontSize: 10.5, color: AppColors.textMuted),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: AppColors.primary, size: 20)
                              : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityChip(String code, String label) {
    final isSelected = _selectedCity == code;

    return GestureDetector(
      onTap: () => setState(() => _selectedCity = code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.chipBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textMain,
          ),
        ),
      ),
    );
  }
}
