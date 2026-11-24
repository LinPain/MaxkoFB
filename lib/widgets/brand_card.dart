import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/brand.dart';

class BrandCard extends StatelessWidget {
  final Brand brand;
  final VoidCallback onOrderNow;
  final VoidCallback onViewBranches;

  const BrandCard({
    Key? key,
    required this.brand,
    required this.onOrderNow,
    required this.onViewBranches,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Image with Overlay & Tags
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  height: 125,
                  width: double.infinity,
                  child: brand.heroImage != null
                      ? Image.network(
                          brand.heroImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, _, __) => Container(color: AppColors.darkSurface),
                        )
                      : Container(color: AppColors.darkSurface),
                ),
              ),

              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),

              // Fire Badge
              if (brand.badge != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department, size: 12, color: Colors.white),
                        const SizedBox(width: 3),
                        Text(
                          brand.badge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Rating Tag
              if (brand.rating > 0) Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 12, color: AppColors.starGold),
                      const SizedBox(width: 3),
                      Text(
                        '${brand.rating}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textMain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Brand Title & Logo at bottom of Hero
              Positioned(
                bottom: 8,
                left: 10,
                right: 10,
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 1.5),
                        image: brand.logoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(brand.logoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: brand.logoUrl == null
                          ? Center(
                              child: Text(
                                brand.shortName ?? brand.name.substring(0, 2),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        brand.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 2. Info Row (Menu count, Branches, Time)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildMetaItem(Icons.restaurant_menu, '${brand.menuCount} món'),
                    const SizedBox(width: 12),
                    _buildMetaItem(Icons.storefront_outlined, '${brand.branchCount} cơ sở'),
                    const SizedBox(width: 12),
                    _buildMetaItem(Icons.timer_outlined, brand.estimatedTime),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  brand.description ?? '',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 10),

                // 3. Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onViewBranches,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textMain,
                          backgroundColor: AppColors.chipBackground,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(
                          'Xem ${brand.branchCount} cơ sở',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onOrderNow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text(
                          'Đặt món ngay',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.primary),
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
