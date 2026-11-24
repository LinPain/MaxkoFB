import 'menu_item.dart';

class CartItem {
  final MenuItem item;
  int quantity;
  final String? size;
  final List<String> toppings;
  final String? note;
  final Map<String, double> toppingPrices;
  final double sizePriceAdjustment;
  final bool isCombo;

  CartItem({
    required this.item,
    this.quantity = 1,
    this.size = '',
    this.toppings = const [],
    this.note,
    this.toppingPrices = const {},
    this.sizePriceAdjustment = 0,
    this.isCombo = false,
  });

  double get totalPrice {
    double toppingsPrice = toppings.fold<double>(
        0, (sum, name) => sum + (toppingPrices[name] ?? 0));
    return (item.price + sizePriceAdjustment + toppingsPrice) * quantity;
  }
}
