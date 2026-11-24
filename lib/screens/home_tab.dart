import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/menu_item.dart';
import '../providers/app_provider.dart';
import '../widgets/hero_banner_slider.dart';
import '../widgets/best_seller_carousel.dart';
import '../widgets/brand_card.dart';
import '../widgets/branch_card.dart';

class HomeTab extends StatefulWidget {
  final Function(MenuItem) onSelectProduct;
  final VoidCallback onSelectBranch;
  final VoidCallback onOpenBrands;

  const HomeTab({
    Key? key,
    required this.onSelectProduct,
    required this.onSelectBranch,
    required this.onOpenBrands,
  }) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _selectedCity = 'all';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final flashSale = provider.flashSale;
    final cities = provider.branches
        .map((branch) => branch.city)
        .where((city) => city.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final selectedCity = cities.contains(_selectedCity) ? _selectedCity : 'all';
    final visibleBranches = provider.branches
        .where((branch) => selectedCity == 'all' || branch.city == selectedCity)
        .take(2)
        .toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Carousel Slider
          const HeroBannerSlider(),

          // 2. Flash Sale Bar
          if (flashSale != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFAB2F00),
                    Color(0xFFD53E02),
                    Color(0xFFB15F00)
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.bolt, color: Colors.yellow, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              (flashSale['title'] ??
                                      flashSale['name'] ??
                                      'MAXKO FLASH SALE')
                                  .toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if ((flashSale['timeLabel'] ??
                                    flashSale['timeRange'] ??
                                    '')
                                .toString()
                                .isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Text(
                                '• ${(flashSale['timeLabel'] ?? flashSale['timeRange'])}',
                                style: const TextStyle(
                                    color: Colors.amberAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 2),
                        Text(
                          (flashSale['description'] ??
                                  flashSale['message'] ??
                                  '')
                              .toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // 3. Best Seller Section (1 hàng ngang tự động trượt chuẩn web)
          BestSellerCarousel(
            onSelectItem: widget.onSelectProduct,
          ),

          const SizedBox(height: 12),

          // 4. Section Thương hiệu nổi bật
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thương hiệu nổi bật',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textMain,
                      ),
                    ),
                    Text(
                      'Đồng thời tích luỹ điểm thưởng MAXKO Club',
                      style:
                          TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: widget.onOpenBrands,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Xem tất cả',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary),
                      ),
                      Icon(Icons.arrow_forward,
                          size: 14, color: AppColors.primary),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Column(
              children: provider.brands.take(2).map((b) {
                return BrandCard(
                  brand: b,
                  onOrderNow: () {
                    provider.setSelectedBrandFilter(b.id);
                    provider.setTabIndex(2);
                  },
                  onViewBranches: widget.onSelectBranch,
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // 5. Section Cửa hàng gần bạn (Đã fix lỗi bẻ dòng chữ chuẩn mực)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tiêu đề + Dropdown không bị bóp nghẹt
                    Row(
                      children: [
                        const Text(
                          'Cửa hàng gần bạn',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textMain,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCity,
                              isDense: true,
                              icon: const Icon(Icons.expand_more,
                                  size: 14, color: AppColors.primary),
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                              items: [
                                const DropdownMenuItem(
                                    value: 'all', child: Text('Tất cả')),
                                ...cities.map((city) => DropdownMenuItem(
                                    value: city, child: Text(city))),
                              ],
                              onChanged: (val) {
                                if (val != null)
                                  setState(() => _selectedCity = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    GestureDetector(
                      onTap: widget.onSelectBranch,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Xem cơ sở',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary),
                          ),
                          Icon(Icons.arrow_forward,
                              size: 13, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Column(
                  children: visibleBranches.isEmpty
                      ? [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 22),
                            child: Text(
                              provider.apiError ??
                                  'Cơ sở sẽ xuất hiện khi có dữ liệu từ máy chủ.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textMuted),
                            ),
                          ),
                        ]
                      : visibleBranches.map((branch) {
                          final isSelected =
                              provider.activeBranch.id == branch.id;
                          return BranchCard(
                            branch: branch,
                            isSelected: isSelected,
                            onSelect: () => provider.setActiveBranch(branch),
                          );
                        }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
