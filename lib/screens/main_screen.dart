import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/menu_item.dart';
import '../providers/app_provider.dart';
import '../widgets/app_header.dart';
import '../widgets/fulfillment_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_tab.dart';
import 'menu_tab.dart';
import 'promotions_tab.dart';
import 'orders_tab.dart';
import 'loyalty_tab.dart';
import 'brands_tab.dart';
import 'notifications_tab.dart';
import 'account_tab.dart';
import 'food_detail_sheet.dart';
import 'cart_sheet.dart';
import 'branch_picker_dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  void _openFoodDetail(MenuItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FoodDetailSheet(item: item),
    );
  }

  void _openCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CartSheet(),
    );
  }

  void _openBranchPicker() {
    showDialog(
      context: context,
      builder: (ctx) => const BranchPickerDialog(),
    );
  }

  Future<void> _openSearch() async {
    final provider = context.read<AppProvider>();
    final controller = TextEditingController(text: provider.searchQuery);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tìm món ăn'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Tên món, thương hiệu...'),
          onChanged: provider.setSearchQuery,
          onSubmitted: (_) => Navigator.pop(dialogContext),
        ),
        actions: [
          TextButton(onPressed: () { controller.clear(); provider.setSearchQuery(''); }, child: const Text('Xóa')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Tìm kiếm')),
        ],
      ),
    );
    controller.dispose();
    if (mounted) provider.setTabIndex(2);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final currentTab = provider.currentTabIndex;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        onCartPressed: _openCart,
        onSearchPressed: () {
          _openSearch();
        },
      ),
      body: Column(
        children: [
          // Fulfillment Bar (Sticky below Header)
          FulfillmentBar(
            onSelectBranch: _openBranchPicker,
          ),

          // Main Tabs Area
          Expanded(
            child: IndexedStack(
              index: currentTab,
              children: [
                // Tab 0: Home
                HomeTab(
                  onSelectProduct: _openFoodDetail,
                  onSelectBranch: _openBranchPicker,
                  onOpenBrands: () => provider.setTabIndex(5),
                ),

                // Tab 1: Promotions
                const PromotionsTab(),

                // Tab 2: Menu / Ordering
                MenuTab(
                  onSelectProduct: _openFoodDetail,
                ),

                // Tab 3: Orders
                const OrdersTab(),

                // Tab 4: Loyalty & Club
                const LoyaltyTab(),
                const BrandsTab(),
                const NotificationsTab(),
                const AccountTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
