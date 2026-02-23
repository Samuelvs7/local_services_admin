import 'package:flutter/material.dart';

enum CarouselOrientation { horizontal, vertical }

class AppCarousel extends StatefulWidget {
  final List<Widget> items;
  final CarouselOrientation orientation;
  final bool showControls;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final double viewportFraction;
  final ValueChanged<int>? onPageChanged;

  const AppCarousel({
    super.key,
    required this.items,
    this.orientation = CarouselOrientation.horizontal,
    this.showControls = true,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.viewportFraction = 1.0,
    this.onPageChanged,
  });

  @override
  State<AppCarousel> createState() => _AppCarouselState();
}

class _AppCarouselState extends State<AppCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _canScrollPrev = false;
  bool _canScrollNext = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: widget.viewportFraction);
    _pageController.addListener(_onScroll);

    if (widget.autoPlay && widget.items.length > 1) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    Future.delayed(widget.autoPlayInterval, () {
      if (!mounted) return;
      if (_currentPage < widget.items.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      _startAutoPlay();
    });
  }

  void _onScroll() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() {
        _currentPage = page;
        _canScrollPrev = page > 0;
        _canScrollNext = page < widget.items.length - 1;
      });
      widget.onPageChanged?.call(page);
    }
  }

  void _scrollPrev() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollNext() {
    if (_currentPage < widget.items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Carousel Content
        PageView.builder(
          controller: _pageController,
          scrollDirection: widget.orientation == CarouselOrientation.horizontal
              ? Axis.horizontal
              : Axis.vertical,
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: widget.items[index],
            );
          },
        ),

        // Previous Button
        if (widget.showControls && widget.items.length > 1)
          Positioned(
            left: widget.orientation == CarouselOrientation.horizontal ? 8 : null,
            top: widget.orientation == CarouselOrientation.vertical ? 8 : null,
            child: _CarouselNavButton(
              icon: widget.orientation == CarouselOrientation.horizontal
                  ? Icons.arrow_back_rounded
                  : Icons.arrow_upward_rounded,
              onPressed: _canScrollPrev ? _scrollPrev : null,
              isDark: isDark,
            ),
          ),

        // Next Button
        if (widget.showControls && widget.items.length > 1)
          Positioned(
            right: widget.orientation == CarouselOrientation.horizontal ? 8 : null,
            bottom: widget.orientation == CarouselOrientation.vertical ? 8 : null,
            child: _CarouselNavButton(
              icon: widget.orientation == CarouselOrientation.horizontal
                  ? Icons.arrow_forward_rounded
                  : Icons.arrow_downward_rounded,
              onPressed: _canScrollNext ? _scrollNext : null,
              isDark: isDark,
            ),
          ),
      ],
    );
  }
}

class _CarouselNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isDark;

  const _CarouselNavButton({
    required this.icon,
    required this.onPressed,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Material(
        color: isDark ? Colors.grey[800] : Colors.white,
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Opacity(
            opacity: onPressed != null ? 1.0 : 0.4,
            child: Icon(
              icon,
              size: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

class AppCarouselDots extends StatelessWidget {
  final int count;
  final int currentIndex;

  const AppCarouselDots({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.primary.withAlpha(51),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
