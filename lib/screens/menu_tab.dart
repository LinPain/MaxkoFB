import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/menu_item.dart';
import '../models/combo.dart';
import '../providers/app_provider.dart';
import '../widgets/best_seller_carousel.dart';
import '../widgets/food_card.dart';

class MenuTab extends StatefulWidget {
  final Function(MenuItem) onSelectProduct;

  const MenuTab({
    Key? key,
    required this.onSelectProduct,
  }) : super(key: key);

  @override
  State<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final brands = provider.brands;
    final selectedBrand = provider.selectedBrandFilter;
    final selectedCategory = provider.selectedCategoryFilter;

    // Filter products
    List<MenuItem> items = provider.products;
    if (selectedBrand != null && selectedBrand != 'all') {
      items = items.where((p) => p.brandId == selectedBrand).toList();
    }
    if (selectedCategory != null) {
      items = items
          .where((p) =>
              p.categoryId == selectedCategory ||
              p.categoryName == selectedCategory)
          .toList();
    }
    if (provider.searchQuery.trim().isNotEmpty) {
      final query = provider.searchQuery.trim().toLowerCase();
      items = items
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              (p.brandName ?? '').toLowerCase().contains(query) ||
              (p.categoryName ?? '').toLowerCase().contains(query))
          .toList();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Horizontal Multi-Brand Ribbon (Sticky-like)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  // Button Tất cả
                  GestureDetector(
                    onTap: () {
                      provider.setSelectedBrandFilter(null);
                      provider.setSelectedCategoryFilter(null);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selectedBrand == null
                            ? AppColors.darkSurface
                            : AppColors.chipBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 15,
                            color: selectedBrand == null
                                ? Colors.white
                                : AppColors.textMain,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Tất cả món ngon',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: selectedBrand == null
                                  ? Colors.white
                                  : AppColors.textMain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Brand Buttons
                  ...brands.map((b) {
                    final isSelected = selectedBrand == b.id;
                    return GestureDetector(
                      onTap: () {
                        provider
                            .setSelectedBrandFilter(isSelected ? null : b.id);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.chipBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.primaryLight,
                              ),
                              child: Center(
                                child: Text(
                                  b.shortName?.substring(0, 1) ?? 'M',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.primaryDark,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              b.name,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w900
                                    : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textMain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          if (provider.categories.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                children: [
                  _categoryChip(
                    label: 'Tất cả danh mục',
                    selected: selectedCategory == null,
                    onTap: () => provider.setSelectedCategoryFilter(null),
                  ),
                  ...provider.categories.map((category) {
                    final id = (category['id'] ??
                            category['_id'] ??
                            category['name'] ??
                            category['categoryName'] ??
                            '')
                        .toString();
                    final name = (category['name'] ??
                            category['categoryName'] ??
                            category['label'] ??
                            id)
                        .toString();
                    return _categoryChip(
                      label: name,
                      selected: selectedCategory == id,
                      onTap: () => provider.setSelectedCategoryFilter(
                          selectedCategory == id ? null : id),
                    );
                  }),
                ],
              ),
            ),

          if (provider.combos.isNotEmpty && selectedCategory == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Combo tiết kiệm',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textMain)),
                    const SizedBox(height: 8),
                    ...provider.combos.map((combo) =>
                        _ComboCard(combo: combo, provider: provider)),
                  ]),
            ),

          // 2. Best Seller 1 hàng Carousel
          BestSellerCarousel(
            onSelectItem: widget.onSelectProduct,
          ),

          const SizedBox(height: 8),

          // 3. Section Title & Product Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 3.5,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Thực đơn món ngon',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textMain,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${items.length} món',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 4. Products Grid (2 Cột chuẩn mobile)
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(28),
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(provider.isLoading ? Icons.sync : Icons.no_food_outlined,
                      size: 36, color: AppColors.textMuted),
                  const SizedBox(height: 9),
                  Text(
                    provider.isLoading
                        ? 'Đang tải thực đơn từ MAXKO…'
                        : provider.apiError ??
                            'Không có món phù hợp trong thực đơn hiện tại.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                  ),
                  if (!provider.isLoading)
                    TextButton(
                        onPressed: provider.refreshFromApi,
                        child: const Text('Tải lại')),
                ]),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.68,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return FoodCard(
                    item: item,
                    onTap: () => widget.onSelectProduct(item),
                  );
                },
              ),
            ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _categoryChip(
          {required String label,
          required bool selected,
          required VoidCallback onTap}) =>
      Padding(
        padding: const EdgeInsets.only(right: 7),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
          selectedColor: AppColors.primaryLight,
          labelStyle: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.primaryDark : AppColors.textMain),
          side: BorderSide(
              color: selected ? AppColors.primaryLight : AppColors.borderLight),
          visualDensity: VisualDensity.compact,
        ),
      );
}

class _ComboCard extends StatelessWidget {
  const _ComboCard({required this.combo, required this.provider});
  final Combo combo;
  final AppProvider provider;

  @override
  Widget build(BuildContext context) {
    final brandName = provider.brands
        .where((brand) => combo.brandIds.contains(brand.id))
        .map((brand) => brand.name)
        .join(' • ');
    final fallbackBrandName = brandName.isEmpty ? 'MAXKO F&B' : brandName;
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 9),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.borderLight)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
                width: 76,
                height: 76,
                child: combo.image == null
                    ? Container(
                        color: AppColors.chipBackground,
                        child: const Icon(Icons.restaurant,
                            color: AppColors.primary))
                    : Image.network(combo.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            color: AppColors.chipBackground,
                            child: const Icon(Icons.restaurant,
                                color: AppColors.primary)))),
          ),
          const SizedBox(width: 11),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(combo.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textMain)),
                if ((combo.subtitle ?? '').isNotEmpty)
                  Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(combo.subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.textMuted))),
                const SizedBox(height: 5),
                Text('${NumberFormat('#,###', 'vi_VN').format(combo.price)}đ',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary)),
              ])),
          IconButton.filledTonal(
            tooltip: 'Thêm combo vào giỏ',
            onPressed: () {
              provider.addToCart(combo.toMenuItem(fallbackBrandName),
                  isCombo: true);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Đã thêm "${combo.name}" vào giỏ hàng'),
                  duration: const Duration(seconds: 1)));
            },
            icon: const Icon(Icons.add_shopping_cart_rounded),
          ),
        ]),
      ),
    );
  }
}
