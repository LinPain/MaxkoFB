import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/app_provider.dart';
import 'auth_screen.dart';

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    if (!provider.isAuthenticated) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.notifications_none_rounded, size: 54, color: AppColors.primary),
            const SizedBox(height: 12),
            const Text('Đăng nhập để xem thông báo', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Cập nhật đơn hàng và ưu đãi của bạn sẽ hiển thị tại đây.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 14),
            FilledButton(onPressed: () => openAuthScreen(context), child: const Text('Đăng nhập')),
          ]),
        ),
      );
    }
    final items = provider.notifications;
    return RefreshIndicator(
      onRefresh: provider.refreshFromApi,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Row(children: [
            const Expanded(child: Text('Thông báo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textMain))),
            if (provider.unreadNotifications > 0)
              TextButton(onPressed: provider.markAllNotificationsRead, child: const Text('Đánh dấu đã đọc')),
          ]),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.notifications_off_outlined, size: 42, color: AppColors.textMuted),
              SizedBox(height: 10),
              Text('Bạn chưa có thông báo mới.', style: TextStyle(color: AppColors.textMuted)),
            ])))
          else
            ...items.map((item) {
              final id = (item['id'] ?? item['_id'] ?? '').toString();
              final read = item['isRead'] == true || item['read'] == true;
              final title = (item['title'] ?? item['subject'] ?? 'Thông báo MAXKO').toString();
              final message = (item['body'] ?? item['message'] ?? item['content'] ?? '').toString();
              final date = (item['createdAt'] ?? item['sentAt'] ?? '').toString();
              return Card(
                color: read ? Colors.white : const Color(0xFFFFF7F3),
                margin: const EdgeInsets.only(bottom: 9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.borderLight)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: read ? null : () => provider.markNotificationRead(id),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(read ? Icons.notifications_none : Icons.notifications_active_outlined, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textMain)),
                        if (message.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(message, style: const TextStyle(color: AppColors.textMuted, height: 1.4))),
                        if (date.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 7), child: Text(date, style: const TextStyle(fontSize: 11, color: AppColors.textMuted))),
                      ])),
                      if (!read) const Padding(padding: EdgeInsets.only(left: 8, top: 5), child: CircleAvatar(radius: 4, backgroundColor: AppColors.primary)),
                    ]),
                  ),
                ),
              );
            }),
          if (provider.apiError != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(provider.apiError!, style: const TextStyle(color: Colors.red, fontSize: 12))),
        ],
      ),
    );
  }
}
