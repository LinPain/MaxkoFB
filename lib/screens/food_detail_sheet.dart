import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/menu_item.dart';
import '../providers/app_provider.dart';

class FoodDetailSheet extends StatefulWidget {
  final MenuItem item;

  const FoodDetailSheet({Key? key, required this.item}) : super(key: key);

  @override
  State<FoodDetailSheet> createState() => _FoodDetailSheetState();
}

class _FoodDetailSheetState extends State<FoodDetailSheet> {
  String _selectedSize = '';
  double _selectedSizePriceAdjustment = 0;
  final List<String> _selectedToppings = [];
  int _quantity = 1;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.item.sizes.isNotEmpty) {
      final option = widget.item.sizes.firstWhere(
        (size) => size['isDefault'] == true,
        orElse: () => widget.item.sizes.first,
      );
      _selectedSize = _sizeKey(option);
      _selectedSizePriceAdjustment = _sizePriceAdjustment(option);
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  double _totalPrice(List<Map<String, dynamic>> toppings) {
    double toppingsTotal = _selectedToppings.fold(0.0, (sum, name) {
      final found = toppings.firstWhere(
          (t) => (t['name'] ?? t['optionName']).toString() == name,
          orElse: () => const {});
      final raw = found['priceAdjustment'] ?? found['price'] ?? 0;
      return sum + (raw is num ? raw.toDouble() : double.tryParse('$raw') ?? 0);
    });
    return (widget.item.price + _selectedSizePriceAdjustment + toppingsTotal) *
        _quantity;
  }

  String _sizeKey(Map<String, dynamic> option) =>
      (option['key'] ?? option['id'] ?? option['name'] ?? '').toString();

  double _sizePriceAdjustment(Map<String, dynamic> option) {
    final adjustment = option['priceDelta'] ?? option['priceAdjustment'];
    if (adjustment is num) return adjustment.toDouble();
    final parsedAdjustment = double.tryParse('$adjustment');
    if (parsedAdjustment != null) return parsedAdjustment;
    final price = option['price'];
    final parsedPrice =
        price is num ? price.toDouble() : double.tryParse('$price');
    return parsedPrice == null ? 0 : parsedPrice - widget.item.price;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat("#,###", "vi_VN");
    final provider = context.watch<AppProvider>();
    final remoteToppings = <Map<String, dynamic>>[];
    for (final group in provider.modifierGroups) {
      final groupLabel =
          '${group['name'] ?? ''} ${group['code'] ?? ''}'.toLowerCase();
      if (!groupLabel.contains('topping')) continue;
      final options = group['options'];
      if (options is List) {
        for (final option in options.whereType<Map>()) {
          if (option['available'] == false || option['isAvailable'] == false)
            continue;
          remoteToppings.add({
            ...Map<String, dynamic>.from(option),
            '__groupId': group['id'] ?? group['_id'] ?? '',
            'groupName': group['name'] ?? group['groupName'] ?? 'Topping',
          });
        }
      }
    }
    final toppingOptions = remoteToppings;
    final sizeOptions = widget.item.sizes;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 1.6,
                      child: widget.item.image != null
                          ? Image.network(
                              widget.item.image!,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, _, __) =>
                                  Container(color: AppColors.chipBackground),
                            )
                          : Container(color: AppColors.chipBackground),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Title & Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textMain,
                          ),
                        ),
                      ),
                      Text(
                        '${currencyFormatter.format(widget.item.price)}đ',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    widget.item.description ?? widget.item.subtitle ?? '',
                    style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                        height: 1.4),
                  ),

                  const Divider(height: 24),

                  // Size options come from product catalog data.
                  if (sizeOptions.isNotEmpty) ...[
                    const Text(
                      'CHỌN KÍCH CỠ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ...sizeOptions.map((option) {
                          final key = _sizeKey(option);
                          final name =
                              (option['name'] ?? option['label'] ?? key)
                                  .toString();
                          final adjustment = _sizePriceAdjustment(option);
                          final extraLabel = adjustment > 0
                              ? ' (+${currencyFormatter.format(adjustment)}đ)'
                              : '';
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _buildSizeOption(
                                  key, '$name$extraLabel', adjustment),
                            ),
                          );
                        }),
                      ],
                    ),
                    const Divider(height: 24),
                  ],

                  // Toppings come from active modifier groups in the catalog.
                  if (toppingOptions.isNotEmpty) ...[
                    const Text(
                      'THÊM TOPPING',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: toppingOptions.map((t) {
                        final name =
                            (t['name'] ?? t['optionName'] ?? '').toString();
                        final rawPrice =
                            t['priceAdjustment'] ?? t['price'] ?? 0;
                        final price = rawPrice is num
                            ? rawPrice.toDouble()
                            : double.tryParse('$rawPrice') ?? 0;
                        final isChecked = _selectedToppings.contains(name);

                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          activeColor: AppColors.primary,
                          title: Text(name,
                              style: const TextStyle(
                                  fontSize: 12.5, fontWeight: FontWeight.w600)),
                          subtitle: Text('+${currencyFormatter.format(price)}đ',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.primary)),
                          value: isChecked,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedToppings.add(name);
                              } else {
                                _selectedToppings.remove(name);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const Divider(height: 20),
                  ],

                  // Quantity & Add button row
                  Row(
                    children: [
                      // Counter
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.chipBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                            ),
                            Text('$_quantity',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 13)),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: () => setState(() => _quantity++),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Add Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final provider = context.read<AppProvider>();
                            provider.addToCart(
                              widget.item,
                              size: _selectedSize,
                              sizePriceAdjustment: _selectedSizePriceAdjustment,
                              toppings: _selectedToppings,
                              quantity: _quantity,
                              note: _noteController.text.trim().isEmpty
                                  ? null
                                  : _noteController.text.trim(),
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Đã thêm $_quantity x "${widget.item.name}" vào giỏ hàng'),
                                backgroundColor: AppColors.primary,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Thêm • ${currencyFormatter.format(_totalPrice(toppingOptions))}đ',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeOption(String code, String label, double extra) {
    final isSelected = _selectedSize == code;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedSize = code;
        _selectedSizePriceAdjustment = extra;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              color: isSelected ? AppColors.primary : AppColors.textMain,
            ),
          ),
        ),
      ),
    );
  }
}
