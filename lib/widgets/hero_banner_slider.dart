import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/app_provider.dart';
import '../services/api_client.dart';

class HeroBannerSlider extends StatefulWidget {
  const HeroBannerSlider({Key? key}) : super(key: key);

  @override
  State<HeroBannerSlider> createState() => _HeroBannerSliderState();
}

class _HeroBannerSliderState extends State<HeroBannerSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _slideCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_slideCount > 1 && _pageController.hasClients) {
        int nextPage = (_currentPage + 1) % _slideCount;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final slides = provider.banners
        .map((banner) => <String, String>{
              'title': (banner['title'] ?? banner['name'] ?? '').toString(),
              'subtitle': (banner['subtitle'] ?? banner['description'] ?? '')
                  .toString(),
              'image': ApiClient.resolveUrl(banner['imageUrl'] ??
                      banner['image'] ??
                      banner['bannerUrl']) ??
                  '',
              'badge':
                  (banner['badge'] ?? banner['label'] ?? 'MAXKO').toString(),
            })
        .where((slide) => slide['image']!.isNotEmpty)
        .toList();
    final visibleSlides = slides;
    if (visibleSlides.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
              colors: [AppColors.darkBg, AppColors.darkSurface]),
        ),
        child: const Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.restaurant_menu_rounded,
                color: AppColors.primaryLight, size: 32),
            SizedBox(height: 8),
            Text('MAXKO F&B',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900)),
            Text('Thông tin món mới sẽ được cập nhật tại đây',
                style: TextStyle(color: Colors.white70, fontSize: 11)),
          ]),
        ),
      );
    }
    _slideCount = visibleSlides.length;
    if (_currentPage >= _slideCount) _currentPage = 0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      height: 185,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // PageView Images
            PageView.builder(
              controller: _pageController,
              onPageChanged: (idx) => setState(() => _currentPage = idx),
              itemCount: visibleSlides.length,
              itemBuilder: (context, index) {
                final slide = visibleSlides[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      slide['image']!,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, __) =>
                          Container(color: AppColors.darkSurface),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.2),
                            Colors.black.withOpacity(0.85),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              slide['badge']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            slide['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            slide['subtitle']!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            // Dot Indicators
            Positioned(
              right: 16,
              bottom: 16,
              child: Row(
                children: List.generate(visibleSlides.length, (idx) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(left: 4),
                    width: _currentPage == idx ? 16 : 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: _currentPage == idx
                          ? AppColors.primaryLight
                          : Colors.white54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
