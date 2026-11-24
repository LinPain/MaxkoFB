import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/app_provider.dart';
import '../widgets/brand_card.dart';

class BrandsTab extends StatelessWidget {
  const BrandsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return RefreshIndicator(
      onRefresh: provider.refreshFromApi,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const Text('Thương hiệu MAXKO', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textMain)),
          const SizedBox(height: 5),
          const Text('Khám phá các thương hiệu và thực đơn yêu thích.', style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 14),
          if (provider.brands.isEmpty)
            const Padding(padding: EdgeInsets.all(28), child: Center(child: Text('Chưa có thương hiệu để hiển thị.')))
          else
            ...provider.brands.map((brand) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: BrandCard(
                    brand: brand,
                    onOrderNow: () {
                      provider.setSelectedBrandFilter(brand.id);
                      provider.setTabIndex(2);
                    },
                    onViewBranches: () => provider.setTabIndex(2),
                  ),
                )),
        ],
      ),
    );
  }
}
