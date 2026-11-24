import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/app_provider.dart';
import 'auth_screen.dart';

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final active = provider.orders.where((o) => !{'COMPLETED', 'CANCELLED', 'CANCELED', 'REFUNDED'}.contains('${o['status']}'.toUpperCase())).toList();
    final history = provider.orders.where((o) => !active.contains(o)).toList();
    return RefreshIndicator(
      onRefresh: provider.refreshFromApi,
      child: ListView(padding: const EdgeInsets.all(14), children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Đơn hàng của bạn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textMain)),
          IconButton(onPressed: provider.refreshFromApi, icon: const Icon(Icons.refresh, color: AppColors.primary)),
        ]),
        if (!provider.isAuthenticated) ...[
          const _EmptyOrders(message: 'Đăng nhập để xem trạng thái và lịch sử đơn hàng.'),
          OutlinedButton.icon(onPressed: () => openAuthScreen(context), icon: const Icon(Icons.login), label: const Text('Đăng nhập')),
        ] else if (provider.isLoading && provider.orders.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
        else ...[
          const Text('Đang xử lý', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          if (active.isEmpty) const _EmptyOrders(message: 'Bạn không có đơn hàng nào đang xử lý.') else ...active.map((o) => _OrderCard(order: o)),
          const SizedBox(height: 14),
          const Text('Lịch sử đơn hàng', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          if (history.isEmpty) const _EmptyOrders(message: 'Chưa có đơn hàng hoàn tất.') else ...history.map((o) => _OrderCard(order: o)),
        ],
        if (provider.apiError != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(provider.apiError!, style: const TextStyle(color: Colors.red, fontSize: 11))),
      ]),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  final String message;
  const _EmptyOrders({required this.message});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 22), child: Center(child: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted, fontSize: 12))));
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = (order['status'] ?? 'PENDING').toString().toUpperCase();
    final items = order['items'] is List ? (order['items'] as List) : const [];
    final summary = items.map((item) {
      if (item is! Map) return '';
      return '${item['quantity'] ?? 1}x ${item['productName'] ?? item['name'] ?? 'Món ăn'}';
    }).where((s) => s.isNotEmpty).join(' • ');
    final total = order['finalTotal'] ?? order['finalAmount'] ?? order['totalAmount'] ?? 0;
    final created = DateTime.tryParse('${order['createdAt'] ?? order['date'] ?? ''}');
    final date = created == null ? '' : DateFormat('dd/MM/yyyy HH:mm').format(created.toLocal());
    final branch = (order['branchName'] ?? order['storeName'] ?? '').toString();
    final color = status == 'COMPLETED' ? AppColors.badgeGreen : status == 'CANCELLED' ? Colors.red : AppColors.badgeOrange;
    return Container(
      margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderLight)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text('${order['orderNumber'] ?? order['id'] ?? 'Đơn hàng'}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primary))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(10)), child: Text(_statusName(status), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800))),
        ]),
        if (summary.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(summary, style: const TextStyle(fontSize: 11, color: AppColors.textMain))),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text([branch, date].where((s) => s.isNotEmpty).join(' • '), style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted))),
          Text('${NumberFormat('#,###', 'vi_VN').format(total is num ? total : num.tryParse('$total') ?? 0)}đ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
        ]),
      ]),
    );
  }

  String _statusName(String value) => switch (value) {
        'PENDING' => 'Chờ xác nhận', 'CONFIRMED' => 'Đã xác nhận', 'PREPARING' => 'Đang chuẩn bị',
        'READY' => 'Sẵn sàng', 'DELIVERING' => 'Đang giao', 'COMPLETED' => 'Hoàn tất',
        'CANCELLED' || 'CANCELED' => 'Đã hủy', _ => value,
      };
}
