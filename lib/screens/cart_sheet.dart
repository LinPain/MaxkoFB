import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../providers/app_provider.dart';
import 'auth_screen.dart';
import 'payment_qr_dialog.dart';

class CartSheet extends StatefulWidget {
  const CartSheet({Key? key}) : super(key: key);

  @override
  State<CartSheet> createState() => _CartSheetState();
}

class _CartSheetState extends State<CartSheet> {
  final TextEditingController _voucherController = TextEditingController();
  double _voucherDiscount = 0.0;
  String? _appliedVoucherCode;
  bool _applyingVoucher = false;
  bool _submitting = false;

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  Future<void> _applyVoucher() async {
    final code = _voucherController.text.trim().toUpperCase();
    if (code.isEmpty || _applyingVoucher) return;
    setState(() => _applyingVoucher = true);
    try {
      final result = await context.read<AppProvider>().applyVoucher(code);
      if (!mounted) return;
      final amount = result['discountAmount'] ?? result['discountValue'] ?? 0;
      setState(() {
        _voucherDiscount =
            amount is num ? amount.toDouble() : double.tryParse('$amount') ?? 0;
        _appliedVoucherCode = code;
      });
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Đã áp dụng mã $code (-${NumberFormat('#,###', 'vi_VN').format(_voucherDiscount)}đ)'),
            backgroundColor: AppColors.primary));
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _applyingVoucher = false);
    }
  }

  Future<void> _checkout() async {
    final provider = context.read<AppProvider>();
    if (!provider.isAuthenticated) {
      final loggedIn = await openAuthScreen(context);
      if (loggedIn != true || !mounted) return;
    }
    final name = TextEditingController(
        text: provider.memberName == 'Khách hàng' ? '' : provider.memberName);
    final address = TextEditingController();
    final phone = TextEditingController(text: provider.customerPhone);
    final note = TextEditingController();
    var paymentMethod = 'CASH';
    final data = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
                title: const Text('Thông tin nhận món'),
                content: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextField(
                        controller: name,
                        textCapitalization: TextCapitalization.words,
                        decoration:
                            const InputDecoration(labelText: 'Tên người nhận')),
                    TextField(
                        controller: phone,
                        keyboardType: TextInputType.phone,
                        decoration:
                            const InputDecoration(labelText: 'Số điện thoại')),
                    if (provider.fulfillmentMode == FulfillmentMode.delivery)
                      TextField(
                          controller: address,
                          minLines: 1,
                          maxLines: 3,
                          decoration: const InputDecoration(
                              labelText: 'Địa chỉ giao hàng')),
                    TextField(
                        controller: note,
                        minLines: 1,
                        maxLines: 2,
                        decoration: const InputDecoration(
                            labelText:
                                'Ghi chú cho cửa hàng (không bắt buộc)')),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                        value: paymentMethod,
                        decoration:
                            const InputDecoration(labelText: 'Thanh toán'),
                        items: const [
                          DropdownMenuItem(
                              value: 'CASH', child: Text('Tiền mặt khi nhận')),
                          DropdownMenuItem(
                              value: 'MQR', child: Text('Chuyển khoản / QR')),
                        ],
                        onChanged: (value) => setDialogState(
                            () => paymentMethod = value ?? 'CASH')),
                  ]),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Quay lại')),
                  FilledButton(
                      onPressed: () => Navigator.pop(dialogContext, {
                            'name': name.text,
                            'phone': phone.text,
                            'address': address.text,
                            'note': note.text,
                            'paymentMethod': paymentMethod
                          }),
                      child: const Text('Xác nhận'))
                ],
              )),
    );
    name.dispose();
    address.dispose();
    phone.dispose();
    note.dispose();
    if (data == null || !mounted) return;
    setState(() => _submitting = true);
    try {
      final result = await provider.checkout(
          customerName: data['name'] ?? '',
          address: data['address'] ?? '',
          phone: data['phone'] ?? '',
          note: data['note'] ?? '',
          paymentMethod: data['paymentMethod'] ?? 'CASH',
          voucherCode: _appliedVoucherCode,
          discountAmount: _voucherDiscount);
      if (!mounted) return;
      final code = result['batchCode'] ??
          result['batchId'] ??
          result['id'] ??
          'đã được ghi nhận';
      if (data['paymentMethod'] == 'MQR' &&
          (result['qrImageUrl'] != null || result['mqrOid'] != null)) {
        await showDialog<void>(
            context: context,
            builder: (_) => PaymentQrDialog(checkout: result));
        if (mounted) Navigator.pop(context);
      } else {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);
        messenger.showSnackBar(SnackBar(
            content: Text('Đặt hàng thành công • $code'),
            backgroundColor: AppColors.primary));
      }
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final currencyFormatter = NumberFormat("#,###", "vi_VN");
    final items = provider.cartItems;

    double finalTotal = (provider.cartTotal - _voucherDiscount);
    if (finalTotal < 0) finalTotal = 0;

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

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Giỏ hàng của bạn',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textMain),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${provider.cartCount} món',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Cart Items List
          Flexible(
            child: items.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_bag_outlined,
                            size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        const Text(
                          'Giỏ hàng đang trống',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 48,
                              height: 48,
                              color: AppColors.chipBackground,
                              child: item.item.image != null
                                  ? Image.network(
                                      item.item.image!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.fastfood, size: 20),
                                    )
                                  : const Icon(Icons.fastfood, size: 20),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.item.name,
                                  style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textMain),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if ((item.size ?? '').isNotEmpty ||
                                    item.toppings.isNotEmpty)
                                  Text(
                                    [
                                      if ((item.size ?? '').isNotEmpty)
                                        'Size ${item.size}',
                                      if (item.toppings.isNotEmpty)
                                        '+${item.toppings.length} topping',
                                    ].join(' • '),
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textMuted),
                                  ),
                                const SizedBox(height: 2),
                                Text(
                                  '${currencyFormatter.format(item.totalPrice)}đ',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => provider.updateQuantity(index, -1),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppColors.chipBackground,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.remove, size: 14),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text('${item.quantity}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800)),
                              ),
                              GestureDetector(
                                onTap: () => provider.updateQuantity(index, 1),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.add,
                                      size: 14, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
          ),

          if (items.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Voucher Input
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: AppColors.chipBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _voucherController,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700),
                            decoration: const InputDecoration(
                              hintText: 'Nhập mã ưu đãi (vd: MAXKOFOOD)',
                              hintStyle: TextStyle(
                                  fontSize: 11, color: AppColors.textMuted),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _applyingVoucher ? null : _applyVoucher,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkSurface,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        child: _applyingVoucher
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Áp dụng',
                                style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Bill Breakdown
                  _buildBillRow('Tạm tính món:',
                      '${currencyFormatter.format(provider.cartSubtotal)}đ'),
                  _buildBillRow('Phí giao hàng:',
                      '${currencyFormatter.format(provider.deliveryFee)}đ'),
                  if (_voucherDiscount > 0)
                    _buildBillRow('Mã giảm giá ($_appliedVoucherCode):',
                        '-${currencyFormatter.format(_voucherDiscount)}đ',
                        isDiscount: true),

                  const Divider(height: 16),

                  _buildBillRow('Tổng thanh toán:',
                      '${currencyFormatter.format(finalTotal)}đ',
                      isTotal: true),

                  const SizedBox(height: 14),

                  // Checkout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _checkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_submitting)
                            const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                          else
                            const Icon(Icons.arrow_forward, size: 16),
                          const SizedBox(width: 6),
                          Text(
                              _submitting
                                  ? 'Đang gửi đơn...'
                                  : 'Tiến hành đặt món',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String value,
      {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 13.5 : 11.5,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w500,
              color: isTotal ? AppColors.textMain : AppColors.textMuted,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 15 : 11.5,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
              color: isDiscount
                  ? Colors.green
                  : (isTotal ? AppColors.primary : AppColors.textMain),
            ),
          ),
        ],
      ),
    );
  }
}
