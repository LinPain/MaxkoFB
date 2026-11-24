import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/app_provider.dart';

class FulfillmentBar extends StatelessWidget {
  final VoidCallback onSelectBranch;

  const FulfillmentBar({
    Key? key,
    required this.onSelectBranch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Container(
      color: AppColors.barBackground,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        children: [
          // Row 1: Branch Selector
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.storefront_outlined, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onSelectBranch,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CƠ SỞ PHỤC VỤ HIỆN TẠI',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              provider.activeBranch.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textMain,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              provider.activeBranch.distance,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textMuted),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Row 2: Service Mode Switcher (Giao tận nơi / Mang đi / Ăn tại quán)
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.chipBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _buildModeTab(
                  context,
                  title: 'Giao tận nơi',
                  icon: Icons.delivery_dining_outlined,
                  isSelected: provider.fulfillmentMode == FulfillmentMode.delivery,
                  onTap: () => provider.setFulfillmentMode(FulfillmentMode.delivery),
                ),
                _buildModeTab(
                  context,
                  title: 'Mang đi',
                  icon: Icons.shopping_bag_outlined,
                  isSelected: provider.fulfillmentMode == FulfillmentMode.pickup,
                  onTap: () => provider.setFulfillmentMode(FulfillmentMode.pickup),
                ),
                _buildModeTab(
                  context,
                  title: 'Ăn tại quán',
                  icon: Icons.table_restaurant_outlined,
                  isSelected: provider.fulfillmentMode == FulfillmentMode.dinein,
                  onTap: () => provider.setFulfillmentMode(FulfillmentMode.dinein),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
