import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/app_provider.dart';
import '../screens/auth_screen.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onCartPressed;
  final VoidCallback? onSearchPressed;

  const AppHeader({
    Key? key,
    this.onCartPressed,
    this.onSearchPressed,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Container(
      color: AppColors.darkBg,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 6,
        bottom: 8,
        left: 12,
        right: 12,
      ),
      child: Row(
        children: [
          // 1. Logo & Brand Title
          GestureDetector(
            onTap: () => provider.setTabIndex(0),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.amber.withOpacity(0.5), width: 1.5),
                    color: AppColors.darkSurface,
                  ),
                  child: const Icon(Icons.restaurant_menu_rounded,
                      color: AppColors.primaryLight, size: 21),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: const TextSpan(
                        text: 'MAXKO ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                        children: [
                          TextSpan(
                            text: 'F&B',
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'Hospitality Group',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          // 2. Action Buttons (Search, Notifications, Cart, Profile)
          Row(
            children: [
              // Search Button
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white70, size: 22),
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(),
                onPressed: onSearchPressed,
              ),
              const SizedBox(width: 4),

              // Notifications with Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded,
                        color: Colors.white70, size: 22),
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      if (provider.isAuthenticated) {
                        provider.setTabIndex(6);
                      } else {
                        openAuthScreen(context);
                      }
                    },
                  ),
                  if (provider.unreadNotifications > 0)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          '${provider.unreadNotifications}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 4),

              // Cart with Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined,
                        color: Colors.white70, size: 22),
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    onPressed: onCartPressed,
                  ),
                  if (provider.cartCount > 0)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          '${provider.cartCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 6),

              // Profile Avatar
              GestureDetector(
                onTap: () => provider.setTabIndex(7),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
