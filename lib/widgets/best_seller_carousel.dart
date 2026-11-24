import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/menu_item.dart';
import '../providers/app_provider.dart';

class BestSellerCarousel extends StatefulWidget {
  final Function(MenuItem) onSelectItem;

  const BestSellerCarousel({
    Key? key,
    required this.onSelectItem,
  }) : super(key: key);

  @override
  State<BestSellerCarousel> createState() => _BestSellerCarouselState();
}

class _BestSellerCarouselState extends State<BestSellerCarousel> {
  int _currentIndex = 0;
  Timer? _autoSlideTimer;
  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
      if (!_isInteracting && mounted) {
        final provider = context.read<AppProvider>();
        final list = provider.bestSellers;
        if (list.isNotEmpty) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % list.length;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  void _prevItem(int length) {
    setState(() {
      _currentIndex = (_currentIndex - 1 + length) % length;
    });
  }

  void _nextItem(int length) {
    setState(() {
      _currentIndex = (_currentIndex + 1) % length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final items = provider.bestSellers;

    if (items.isEmpty) return const SizedBox.shrink();
    if (_currentIndex >= items.length) _currentIndex = 0;

    final currentItem = items[_currentIndex];
    final currencyFormatter = NumberFormat("#,###", "vi_VN");

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header with Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 3.5,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Món Best Seller',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${items.length}',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),

              // Control Chevron Buttons
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _prevItem(items.length),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.chevron_left, size: 18, color: AppColors.textMain),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _nextItem(items.length),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.chevron_right, size: 18, color: AppColors.textMain),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 2. Single Active Card (1 Hàng ngang bám sát Web)
          GestureDetector(
            onTap: () => widget.onSelectItem(currentItem),
            child: Container(
              padding: const EdgeInsets.all(12),
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left Image with Badge
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 105,
                          height: 105,
                          color: AppColors.chipBackground,
                          child: currentItem.image != null
                              ? Image.network(
                                  currentItem.image!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, _, __) => const Center(
                                    child: Icon(Icons.fastfood, color: Colors.black26),
                                  ),
                                )
                              : const Center(
                                  child: Icon(Icons.fastfood, color: Colors.black26),
                                ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            currentItem.discountPercent != null
                                ? '-${currentItem.discountPercent}%'
                                : 'BEST SELLER',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  // Right Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'BÁN CHẠY NHẤT',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                currentItem.brandName ?? '',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Text(
                          currentItem.name,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textMain,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 3),

                        Text(
                          currentItem.description ?? currentItem.subtitle ?? '',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.textMuted,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${currencyFormatter.format(currentItem.price)}đ',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                                ),
                                if (currentItem.originalPrice != null) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    '${currencyFormatter.format(currentItem.originalPrice)}đ',
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      color: AppColors.textMuted,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            GestureDetector(
                              onTap: () {
                                provider.addToCart(currentItem);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Đã thêm "${currentItem.name}" vào giỏ hàng'),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.add, color: Colors.white, size: 14),
                                    SizedBox(width: 3),
                                    Text(
                                      'Thêm',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
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
            ),
          ),

          const SizedBox(height: 8),

          // 3. Dot Indicators to Switch / Active
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(items.length, (idx) {
              return GestureDetector(
                onTap: () => setState(() => _currentIndex = idx),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentIndex == idx ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentIndex == idx ? AppColors.primary : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
