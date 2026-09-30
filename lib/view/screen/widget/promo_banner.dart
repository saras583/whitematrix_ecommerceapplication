import 'dart:async';
import 'package:flutter/material.dart';

class _Promo {
  final String title, subtitle, slug;
  final List<Color> colors;
  final IconData icon;
  const _Promo(this.title, this.subtitle, this.slug, this.colors, this.icon);
}

const _promos = [
  _Promo('Glow up', 'Skincare, makeup & more', 'beauty',
      [Color(0xFFFF6B4A), Color(0xFFFF9A6B)], Icons.auto_awesome),
  _Promo('Tech corner', 'Latest smartphones', 'smartphones',
      [Color(0xFF1F1B2E), Color(0xFF4A4370)], Icons.phone_iphone),
  _Promo('Home refresh', 'Furniture for every room', 'furniture',
      [Color(0xFF2E7D6B), Color(0xFF57B39C)], Icons.chair_alt),
];

class PromoBanner extends StatefulWidget {
  final ValueChanged<String> onSelect; // receives a category slug
  const PromoBanner({super.key, required this.onSelect});
  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  final _ctrl = PageController(viewportFraction: 0.9);
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_ctrl.hasClients) return;
      _ctrl.animateToPage((_page + 1) % _promos.length,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _ctrl,
            itemCount: _promos.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) {
              final p = _promos[i];
              return GestureDetector(
                onTap: () => widget.onSelect(p.slug),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: p.colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Positioned(
                        right: -10,
                        bottom: -20,
                        child: Icon(p.icon,
                            size: 120,
                            color: Colors.white.withValues(alpha: 0.18)),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(p.subtitle,
                              style: const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Shop now',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _promos.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: i == _page ? 18 : 6,
                decoration: BoxDecoration(
                  color: i == _page ? Colors.black87 : Colors.black26,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ],
    );
  }
}