import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/app_provider.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final currentTab = provider.currentTabIndex;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        border: const Border(
          top: BorderSide(color: AppColors.borderLight, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              // Tab 1: Trang chủ
              _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Trang chủ',
                isActive: currentTab == 0,
                onTap: () => provider.setTabIndex(0),
              ),

              // Tab 2: Ưu đãi
              _buildNavItem(
                icon: Icons.confirmation_number_outlined,
                activeIcon: Icons.confirmation_number,
                label: 'Ưu đãi',
                isActive: currentTab == 1,
                badgeCount: provider.unreadNotifications,
                onTap: () => provider.setTabIndex(1),
              ),

              // Tab 3: Đặt món (Floating Center Action Button)
              Expanded(
                child: GestureDetector(
                  onTap: () => provider.setTabIndex(2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -8),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: currentTab == 2 ? AppColors.primaryDark : AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: currentTab == 2 ? AppColors.primaryLight : Colors.white,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.restaurant_menu,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -4),
                        child: Text(
                          'Đặt món',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: currentTab == 2 ? FontWeight.w900 : FontWeight.w700,
                            color: currentTab == 2 ? AppColors.primary : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab 4: Đơn hàng
              _buildNavItem(
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long,
                label: 'Đơn hàng',
                isActive: currentTab == 3,
                onTap: () => provider.setTabIndex(3),
              ),

              // Tab 5: Điểm thưởng
              _buildNavItem(
                icon: Icons.loyalty_outlined,
                activeIcon: Icons.loyalty,
                label: 'Điểm thưởng',
                isActive: currentTab == 4,
                onTap: () => provider.setTabIndex(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 22,
                  color: isActive ? AppColors.primary : AppColors.textMuted,
                ),
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    top: -3,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.textMuted,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }
}
