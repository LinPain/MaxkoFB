import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/branch.dart';

class BranchCard extends StatelessWidget {
  final Branch branch;
  final bool isSelected;
  final VoidCallback onSelect;

  const BranchCard({
    Key? key,
    required this.branch,
    required this.isSelected,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image / Theme
            Stack(
              children: [
                Container(
                  height: 90,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(15)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.storefront,
                            color: Colors.white30, size: 30),
                        const SizedBox(height: 2),
                        Text(
                          branch.district.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Selected Check Badge
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, size: 11, color: Colors.white),
                          SizedBox(width: 3),
                          Text(
                            'Đang chọn',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Branch Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    branch.name,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color:
                          isSelected ? AppColors.primary : AppColors.textMain,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      if (branch.distance.isNotEmpty) ...[
                        const Icon(Icons.near_me,
                            size: 12, color: AppColors.primary),
                        const SizedBox(width: 3),
                        Text(branch.distance,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600)),
                      ],
                      if (branch.distance.isNotEmpty && branch.rating > 0)
                        const SizedBox(width: 10),
                      if (branch.rating > 0) ...[
                        const Icon(Icons.star,
                            size: 12, color: AppColors.starGold),
                        const SizedBox(width: 3),
                        Text('${branch.rating} (${branch.reviews})',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.starGold,
                                fontWeight: FontWeight.w800)),
                      ],
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    branch.address,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Service Tags (Giao hàng, Mang đi, Tại quán)
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      if (branch.services.contains('delivery'))
                        _buildServiceChip('Giao hàng', AppColors.badgeGreenBg,
                            AppColors.badgeGreen),
                      if (branch.services.contains('pickup'))
                        _buildServiceChip('Mang đi', AppColors.badgeOrangeBg,
                            AppColors.badgeOrange),
                      if (branch.services.contains('dinein'))
                        _buildServiceChip('Tại quán', const Color(0xFFFEF3C7),
                            const Color(0xFF92400E)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceChip(String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
