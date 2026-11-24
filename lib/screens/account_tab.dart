import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/app_provider.dart';
import 'auth_screen.dart';

class AccountTab extends StatelessWidget {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;
    final name = (user?['name'] ?? user?['fullName'] ?? provider.memberName).toString();
    final email = (user?['email'] ?? '').toString();
    final phone = provider.customerPhone;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Tài khoản', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textMain)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: AppColors.darkBg, borderRadius: BorderRadius.circular(20)),
          child: Row(children: [
            CircleAvatar(radius: 28, backgroundColor: AppColors.primary, child: Text(name.isEmpty ? 'M' : name.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(provider.isAuthenticated ? name : 'Chào mừng đến MAXKO', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(provider.isAuthenticated ? [phone, email].where((value) => value.isNotEmpty).join(' • ') : 'Đăng nhập để quản lý tài khoản', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ])),
          ]),
        ),
        const SizedBox(height: 16),
        if (!provider.isAuthenticated) ...[
          FilledButton.icon(onPressed: () => openAuthScreen(context), icon: const Icon(Icons.login), label: const Text('Đăng nhập')),
          const SizedBox(height: 8),
          OutlinedButton.icon(onPressed: () => openAuthScreen(context, startWithSignUp: true), icon: const Icon(Icons.person_add_alt_1), label: const Text('Tạo tài khoản MAXKO')),
        ] else ...[
          _AccountAction(icon: Icons.receipt_long_outlined, title: 'Đơn hàng của tôi', subtitle: 'Theo dõi và xem lịch sử đơn', onTap: () => provider.setTabIndex(3)),
          _AccountAction(icon: Icons.workspace_premium_outlined, title: 'MAXKO Club', subtitle: 'Điểm thưởng và quyền lợi thành viên', onTap: () => provider.setTabIndex(4)),
          _AccountAction(icon: Icons.notifications_none, title: 'Thông báo', subtitle: 'Cập nhật đơn hàng và ưu đãi', onTap: () => provider.setTabIndex(6)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              await provider.logout();
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bạn đã đăng xuất.')));
            },
            icon: const Icon(Icons.logout),
            label: const Text('Đăng xuất'),
          ),
        ],
        const SizedBox(height: 24),
        const Center(child: Text('MAXKO F&B • Hospitality Group', style: TextStyle(fontSize: 12, color: AppColors.textMuted))),
      ],
    );
  }
}

class _AccountAction extends StatelessWidget {
  const _AccountAction({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.borderLight)),
        child: ListTile(leading: Icon(icon, color: AppColors.primary), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)), trailing: const Icon(Icons.chevron_right), onTap: onTap),
      );
}
