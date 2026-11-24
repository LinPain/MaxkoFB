import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/app_provider.dart';
import 'auth_screen.dart';

class PromotionsTab extends StatelessWidget {
  const PromotionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final voucherEntries = provider.availableVouchers.isNotEmpty ? provider.availableVouchers : provider.savedVouchers;
    final canSave = voucherEntries.isNotEmpty;
    final entries = canSave ? voucherEntries : provider.promotions;
    return RefreshIndicator(
      onRefresh: provider.refreshFromApi,
      child: ListView(padding: const EdgeInsets.all(14), children: [
        _campaignBanner(provider),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Ưu đãi đang áp dụng', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textMain)),
          IconButton(onPressed: provider.refreshFromApi, icon: const Icon(Icons.refresh, color: AppColors.primary)),
        ]),
        if (entries.isEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: 28), child: Center(child: Text(provider.apiError ?? 'Hiện chưa có ưu đãi đang áp dụng.', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted, fontSize: 12))))
        else ...entries.map((entry) => _PromotionCard(entry: entry, provider: provider, canSave: canSave)),
        if (provider.apiError != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(provider.apiError!, style: const TextStyle(color: Colors.red, fontSize: 11))),
      ]),
    );
  }

  Widget _campaignBanner(AppProvider provider) {
    final sale = provider.flashSale;
    final title = (sale?['title'] ?? sale?['name'] ?? 'Chưa có chương trình khuyến mãi').toString();
    final desc = (sale?['description'] ?? sale?['message'] ?? 'Ưu đãi đang áp dụng sẽ được cập nhật tại đây.').toString();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFAB2F00), Color(0xFFD53E02)]), borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        const Icon(Icons.local_offer, color: Colors.white, size: 30), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('MAXKO • ƯU ĐÃI', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5), Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
          Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
        ])),
      ]),
    );
  }
}

class _PromotionCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final AppProvider provider;
  final bool canSave;
  const _PromotionCard({required this.entry, required this.provider, required this.canSave});

  @override
  Widget build(BuildContext context) {
    final code = (entry['code'] ?? entry['voucherCode'] ?? '').toString();
    final title = (entry['title'] ?? entry['name'] ?? entry['voucherTitle'] ?? code).toString();
    final description = (entry['description'] ?? entry['terms'] ?? entry['condition'] ?? '').toString();
    final discount = entry['discountAmount'] ?? entry['discountValue'] ?? entry['value'] ?? '';
    final id = (entry['id'] ?? entry['_id'] ?? '').toString();
    final color = AppColors.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderLight)),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.confirmation_number_outlined, color: color)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textMain)),
          if (discount.toString().isNotEmpty) Text('Giá trị ưu đãi: $discount', style: const TextStyle(fontSize: 10.5, color: AppColors.primary, fontWeight: FontWeight.w800)),
          Text(description.isEmpty ? 'Xem điều kiện áp dụng tại bước đặt hàng.' : description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          if (code.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 3), child: Text('Mã: $code', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: .5))),
        ])),
        const SizedBox(width: 6),
        if (canSave && id.isNotEmpty) TextButton(onPressed: () async {
          if (!provider.isAuthenticated) {
            final ok = await openAuthScreen(context);
            if (ok != true || !context.mounted) return;
          }
          try {
            await provider.redeemVoucher(id);
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu ưu đãi vào tài khoản.')));
          } catch (error) {
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))));
          }
        }, child: const Text('Lưu')),
      ]),
    );
  }
}
