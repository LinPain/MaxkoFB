import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/app_provider.dart';
import 'auth_screen.dart';

class LoyaltyTab extends StatelessWidget {
  const LoyaltyTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final perks = provider.loyaltyProfile?['perks'] is Map
        ? Map<String, dynamic>.from(provider.loyaltyProfile!['perks'] as Map)
        : const <String, dynamic>{};

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Digital Membership Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E293B),
                  Color(0xFF334155)
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                          child: const Icon(Icons.workspace_premium,
                              color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'MAXKO CLUB',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Colors.amber, Colors.orange]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        provider.memberTier.isEmpty
                            ? 'THÀNH VIÊN'
                            : provider.memberTier,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  provider.memberName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider.memberNumber.isEmpty
                      ? 'Đăng nhập để tạo mã hội viên'
                      : 'ID: ${provider.memberNumber}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ĐIỂM TÍCH LŨY',
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${provider.memberPoints} pts',
                          style: const TextStyle(
                            color: AppColors.primaryLight,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: provider.isAuthenticated
                          ? () => _showQrDialog(context)
                          : () => openAuthScreen(context),
                      icon: const Icon(Icons.badge_outlined, size: 16),
                      label: const Text('Mã thành viên',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          if (!provider.isAuthenticated)
            SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => openAuthScreen(context),
                  icon: const Icon(Icons.login),
                  label: const Text('Đăng nhập / Tạo tài khoản MAXKO'),
                ))
          else
            SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: provider.logout,
                  icon: const Icon(Icons.logout),
                  label: Text('Đăng xuất • ${provider.customerPhone}'),
                )),

          const SizedBox(height: 20),

          Text(
            provider.memberTier.isEmpty
                ? 'Quyền lợi thành viên'
                : 'Quyền lợi hạng ${provider.memberTier}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 10),

          if (perks['cashbackPercent'] != null)
            _buildBenefitItem(Icons.percent,
                'Hoàn ${perks['cashbackPercent']}% giá trị đơn hàng vào ví điểm'),
          if (perks['birthdayGift'] != null)
            _buildBenefitItem(
                Icons.cake_outlined, 'Quà sinh nhật: ${perks['birthdayGift']}'),
          if (perks['freeShippingTrips'] != null)
            _buildBenefitItem(Icons.local_shipping_outlined,
                'Miễn phí giao hàng ${perks['freeShippingTrips']} lượt'),
          if (perks.isEmpty)
            Text(
                provider.isAuthenticated
                    ? 'Máy chủ chưa cung cấp quyền lợi thành viên.'
                    : 'Đăng nhập để xem quyền lợi thành viên.',
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textMuted)),

          const SizedBox(height: 20),

          const Text(
            'Lịch sử giao dịch điểm',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 10),

          if (provider.orders.isEmpty)
            Text(
                provider.isAuthenticated
                    ? 'Chưa có giao dịch điểm.'
                    : 'Đăng nhập để xem lịch sử điểm và đơn hàng.',
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textMuted))
          else
            ...provider.orders.take(5).map((order) => _buildHistoryItem(
                  '+${order['pointsEarned'] ?? 0} điểm',
                  'Đơn hàng ${order['orderNumber'] ?? order['id'] ?? ''}',
                  (order['createdAt'] ?? '').toString(),
                  true,
                )),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: AppColors.primary, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textMain,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String pts, String title, String time, bool isPlus) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain)),
              Text(time,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
          Text(
            pts,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: isPlus ? AppColors.badgeGreen : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _showQrDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Mã thành viên MAXKO Club',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textMain),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Cung cấp mã này để nhân viên tra cứu tài khoản thành viên',
                  style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Center(
                      child: SelectableText(
                          context.read<AppProvider>().memberNumber,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppColors.darkSurface,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1))),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
