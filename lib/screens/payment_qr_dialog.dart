import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/app_provider.dart';
import '../services/api_client.dart';

class PaymentQrDialog extends StatefulWidget {
  final Map<String, dynamic> checkout;
  const PaymentQrDialog({super.key, required this.checkout});

  @override
  State<PaymentQrDialog> createState() => _PaymentQrDialogState();
}

class _PaymentQrDialogState extends State<PaymentQrDialog> {
  Timer? _timer;
  String _status = 'Đang chờ thanh toán';
  int _checks = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _checkPayment());
  }

  Future<void> _checkPayment() async {
    final oid = (widget.checkout['mqrOid'] ?? widget.checkout['oid'] ?? '').toString();
    if (oid.isEmpty || _checks >= 60) return;
    _checks++;
    try {
      final provider = context.read<AppProvider>();
      final result = await provider.paymentStatus(oid);
      if (!mounted) return;
      final data = result['data'];
      final state = '${(data is Map ? data['paymentStatus'] ?? data['status'] ?? data['transactionStatus'] : null) ?? result['status'] ?? ''}'.toUpperCase();
      if (state.contains('PAID') || state.contains('SUCCESS') || state == 'COMPLETED') {
        _timer?.cancel();
        if (mounted) setState(() => _status = 'Đã nhận thanh toán');
        await provider.refreshFromApi();
      }
    } catch (_) {}
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final image = ApiClient.resolveUrl(widget.checkout['qrImageUrl'] ?? widget.checkout['qrCodeUrl']);
    final amount = widget.checkout['totalAmount'] ?? widget.checkout['totalBatchAmount'] ?? widget.checkout['totalAmountVnd'];
    final formattedAmount = amount == null ? null : '${amount}đ';
    return AlertDialog(
      title: const Text('Thanh toán QR'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        if (image != null) Image.network(image, width: 220, height: 220, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.qr_code_2, size: 180)) else const Icon(Icons.qr_code_2, size: 180, color: AppColors.darkSurface),
        if (formattedAmount != null) Text('Số tiền: $formattedAmount', style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(_status, style: TextStyle(color: _status.contains('Đã nhận') ? AppColors.badgeGreen : AppColors.textMuted, fontSize: 12)),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))],
    );
  }
}
